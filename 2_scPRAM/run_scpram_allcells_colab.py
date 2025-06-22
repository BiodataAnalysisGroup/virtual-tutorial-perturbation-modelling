# run_scpram_full_benchmark.py

import os
import time
import scanpy as sc
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

from scpram import models
from scipy import stats, sparse
from scipy.spatial.distance import cosine as cosine_dist, cdist
from sklearn.metrics import pairwise_distances, silhouette_score, roc_auc_score
from sklearn.neighbors import KernelDensity
from sklearn.decomposition import PCA
from sklearn.linear_model import LogisticRegression
from collections import OrderedDict

# === CONFIG ===
OUTDIR = '/content/scpram_outputs_full'
os.makedirs(OUTDIR, exist_ok=True)

adata = sc.read('train_pbmc.h5ad')

# === Prep ===
norm_data = adata
norm_data.obs.rename(columns={"condition": "label"}, inplace=True)
norm_data.obs['label'] = norm_data.obs['label'].cat.rename_categories({'control': 'ctrl', 'stimulated': 'stim'})

# === Parameters ===
USE_CSR = True
K = 100
TARGET_CELLS = 1000

# Downsample
idx = np.random.choice(norm_data.obs_names, size=TARGET_CELLS, replace=False)
norm_data = norm_data[idx].copy()

if USE_CSR and sparse.issparse(norm_data.X):
    norm_data.X = norm_data.X.tocsr()

celltype_col = "cell_type"

# === Metric helpers ===
def mean_var_kde_distance(X1, X2, bandwidth=1.0, grid_size=50):
    m1, v1 = X1.mean(0), X1.var(0)
    m2, v2 = X2.mean(0), X2.var(0)
    pts1, pts2 = np.vstack([m1, v1]).T, np.vstack([m2, v2]).T
    mins, maxs = np.minimum(pts1.min(0), pts2.min(0)), np.maximum(pts1.max(0), pts2.max(0))
    xs = np.linspace(mins[0], maxs[0], grid_size)
    ys = np.linspace(mins[1], maxs[1], grid_size)
    grid = np.vstack(np.meshgrid(xs, ys)).reshape(2, -1).T
    kde1 = KernelDensity(bandwidth=bandwidth).fit(pts1)
    kde2 = KernelDensity(bandwidth=bandwidth).fit(pts2)
    d1 = np.exp(kde1.score_samples(grid))
    d2 = np.exp(kde2.score_samples(grid))
    dx, dy = xs[1]-xs[0], ys[1]-ys[0]
    return float(np.abs(d1 - d2).sum() * dx * dy)

def bootstrap_metrics(X, real_mask, pred_mask, pca_coords, n_boot=100, frac=0.8, seed=0):
    rng = np.random.default_rng(seed)
    r_idx = np.where(real_mask)[0]
    p_idx = np.where(pred_mask)[0]
    s_r, s_p = max(1, int(frac*len(r_idx))), max(1, int(frac*len(p_idx)))
    keys = ["R2","MSE","RMSE","MAE","L2","Pearson","Cosine","Edist","MMD","Euc"]
    vals = {k: [] for k in keys}
    for _ in range(n_boot):
        r = rng.choice(r_idx, s_r, replace=True)
        p = rng.choice(p_idx, s_p, replace=True)
        Y = X[r].mean(0)
        Xp = X[p].mean(0)
        d = Xp - Y
        vals["MSE"].append(np.mean(d**2))
        vals["RMSE"].append(np.sqrt(np.mean(d**2)))
        vals["MAE"].append(np.mean(np.abs(d)))
        vals["L2"].append(np.linalg.norm(d))
        vals["Pearson"].append(stats.pearsonr(Xp, Y)[0])
        vals["Cosine"].append(1 - cosine_dist(Xp, Y))
        ss_res = ((Y - Xp)**2).sum()
        ss_tot = ((Y - Y.mean())**2).sum()
        vals["R2"].append(1 - ss_res/ss_tot if ss_tot > 0 else np.nan)
        Pr, Pp = pca_coords[r], pca_coords[p]
        vals["Euc"].append(np.linalg.norm(Pr.mean(0) - Pp.mean(0)))
        d_rr = pairwise_distances(Pr, Pr)
        d_pp = pairwise_distances(Pp, Pp)
        d_rp = pairwise_distances(Pr, Pp)
        vals["Edist"].append(2*d_rp.mean() - d_rr.mean() - d_pp.mean())
        Krr = np.exp(-cdist(Pr, Pr,'sqeuclidean')/2)
        Kpp = np.exp(-cdist(Pp, Pp,'sqeuclidean')/2)
        Krp = np.exp(-cdist(Pr, Pp,'sqeuclidean')/2)
        vals["MMD"].append(Krr.mean() + Kpp.mean() - 2*Krp.mean())
    stats_out = {}
    for k in keys:
        arr = np.array(vals[k])
        stats_out[f"{k}_mean"] = arr.mean()
        stats_out[f"{k}_std"] = arr.std()
    return stats_out

def compute_dist_scaled(X, ctrl_mask, stim_mask, pred_mask, eps=1e-8):
    m_ctrl = X[ctrl_mask].mean(0)
    m_stim = X[stim_mask].mean(0)
    m_pred = X[pred_mask].mean(0)
    ok = ~np.isnan(m_ctrl) & ~np.isnan(m_stim) & ~np.isnan(m_pred)
    d_in = np.linalg.norm(m_ctrl[ok] - m_stim[ok])
    d_pr = np.linalg.norm(m_pred[ok] - m_stim[ok])
    return d_pr / (d_in + eps)

# === MAIN LOOP ===
t0 = time.perf_counter()
results = []
all_attention_results = []

key_dic = {
    'condition_key': 'label',
    'cell_type_key': 'cell_type',
    'ctrl_key': 'ctrl',
    'stim_key': 'stim',
    'pred_key': 'pred'
}

print("✅ norm_data.obs['label'] head:")
print(norm_data.obs['label'].value_counts())

for cell_type in norm_data.obs[celltype_col].unique():
    counts = norm_data.obs['label'][norm_data.obs[celltype_col] == cell_type].value_counts()
    if counts.get('stim', 0) < 3 or counts.get('ctrl', 0) < 3:
        print(f"Skipping {cell_type}: too few cells")
        continue

    print(f"=== Running scPRAM for {cell_type} ===")

    train_adata = norm_data[~((norm_data.obs[celltype_col] == cell_type) &
                              (norm_data.obs['label'] == 'stim'))].copy()
    if USE_CSR and sparse.issparse(train_adata.X):
        train_adata.X = train_adata.X.tocsr()

    model = models.SCPRAM(input_dim=norm_data.n_vars, device='cuda:0')
    model = model.to(model.device)
    model.train_SCPRAM(train_adata, epochs=100)

    input_adata = norm_data[(norm_data.obs[celltype_col] == cell_type) &
                            (norm_data.obs['label'] == 'ctrl')].copy()
    pred = model.predict(train_adata=train_adata,
                         cell_to_pred=cell_type,
                         key_dic=key_dic,
                         ratio=0.005)
    pred.obs['label'] = 'pred'

    ctrl = norm_data[(norm_data.obs[celltype_col] == cell_type) & (norm_data.obs['label'] == 'ctrl')]
    stim = norm_data[(norm_data.obs[celltype_col] == cell_type) & (norm_data.obs['label'] == 'stim')]
    eval_adata = ctrl.concatenate(stim, pred)
    eval_adata.obs['label'] = eval_adata.obs['label'].astype('category').cat.remove_unused_categories()

    sc.tl.pca(eval_adata)

    X_full = eval_adata.X.toarray() if sparse.issparse(eval_adata.X) else eval_adata.X
    pca_full = eval_adata.obsm['X_pca']
    masks = {k: eval_adata.obs['label'] == k for k in ['ctrl', 'stim', 'pred']}

    sc.tl.rank_genes_groups(eval_adata, groupby="label", reference="ctrl", groups=["stim"], method="t-test", n_genes=eval_adata.n_vars)
    stim_de = eval_adata.uns['rank_genes_groups']['names']['stim'][:K].tolist()

    sc.tl.rank_genes_groups(eval_adata, groupby="label", reference="ctrl", groups=["pred"], method="t-test", n_genes=eval_adata.n_vars)
    pred_de = eval_adata.uns['rank_genes_groups']['names']['pred'][:K].tolist()

    shared = set(stim_de).intersection(pred_de)
    jaccard = len(shared) / (len(stim_de) + len(pred_de) - len(shared)) if (stim_de or pred_de) else 0

    for label_name, (X_mat, pca_coords) in [
        ('all_genes', (X_full, pca_full)),
        (f'top{K}DEGs', (
            X_full[:, [eval_adata.var_names.get_loc(g) for g in stim_de]],
            PCA().fit_transform(X_full[:, [eval_adata.var_names.get_loc(g) for g in stim_de]])
        ))
    ]:
        boot_stats = bootstrap_metrics(X_mat, masks['stim'], masks['pred'], pca_coords)
        dist_scaled = compute_dist_scaled(X_mat, masks['ctrl'], masks['stim'], masks['pred'])
        kde_dist = mean_var_kde_distance(X_mat[masks['stim']], X_mat[masks['pred']])

        combined = masks['stim'] | masks['pred']
        lbls = eval_adata.obs['label'][combined].map({'stim': 1, 'pred': 0}).values
        emb = pca_full[combined]
        sil = silhouette_score(emb, lbls)
        clf = LogisticRegression(max_iter=1000)
        clf.fit(emb, lbls)
        auc = roc_auc_score(lbls, clf.predict_proba(emb)[:, 1])

        results.append({
            'cell_type': cell_type,
            'gene_set': label_name,
            'jaccard_topK': jaccard,
            'dist_scaled': dist_scaled,
            'mean_var_distn': kde_dist,
            'silhouette': sil,
            'auc': auc,
            **boot_stats
        })

    # === ATTENTION EXTRACTION ===
    ctrl_to_pred = input_adata
    ctrl_adata = train_adata[train_adata.obs['label'] == 'ctrl']

    test_z = model.get_latent_adata(ctrl_to_pred).to_df().values
    ctrl_z = model.get_latent_adata(ctrl_adata).to_df().values

    cos_sim = pairwise_distances(test_z, ctrl_z, metric='cosine')
    attention_scores = pd.DataFrame(1 - cos_sim.mean(axis=0), index=ctrl_adata.obs_names, columns=['mean_attention'])
    attention_scores['ref_cell_type'] = ctrl_adata.obs[celltype_col].values

    attention_per_type = attention_scores.groupby('ref_cell_type')['mean_attention'].mean().sort_values(ascending=False)

    all_attention_results.append({
        'cell_type': cell_type,
        'attention': attention_per_type
    })

# === SAVE ===
results_df = pd.DataFrame(results)
results_df.to_csv(f"{OUTDIR}/scpram_metrics.csv")

metrics = [
    ("R2_mean", "R2_std"), ("MSE_mean", "MSE_std"), ("RMSE_mean", "RMSE_std"), ("MAE_mean", "MAE_std"),
    ("Pearson_mean", "Pearson_std"), ("Cosine_mean", "Cosine_std"), ("Edist_mean", "Edist_std"),
    ("MMD_mean", "MMD_std"), ("Euc_mean", "Euc_std"), ("jaccard_topK", None), ("silhouette", None), ("auc", None)
]

cell_types = results_df['cell_type'].unique()
x = np.arange(len(cell_types))
fig, axes = plt.subplots(nrows=3, ncols=4, figsize=(20, 12))
axes = axes.ravel()

for ax, (mean_col, std_col) in zip(axes, metrics):
    for gs in results_df['gene_set'].unique():
        sub = results_df[results_df['gene_set'] == gs].set_index('cell_type')
        y = sub[mean_col].reindex(cell_types)
        yerr = sub[std_col].reindex(cell_types) if std_col else None
        ax.bar(
            x + (0 if gs == 'all_genes' else 0.4),
            y.values,
            0.4,
            yerr=(yerr.values if yerr is not None else None),
            capsize=3,
            label=gs
        )
    ax.set_xticks(x + 0.2)
    ax.set_xticklabels(cell_types, rotation=45, ha='right')
    ax.set_title(mean_col.replace('_mean', ''))

for ax in axes[len(metrics):]:
    ax.axis('off')

handles, labels = axes[0].get_legend_handles_labels()
by_label = OrderedDict(zip(labels, handles))
fig.legend(by_label.values(), by_label.keys(), loc='center right')
fig.tight_layout(rect=[0, 0, 0.85, 1])
fig.savefig(f"{OUTDIR}/metrics_barplot.png")

attention_summary_df = pd.DataFrame({
    d['cell_type']: d['attention']
    for d in all_attention_results
}).T.fillna(0)

attention_summary_df.to_csv(f"{OUTDIR}/scpram_attention.csv")

plt.figure(figsize=(12, 8))
sns.heatmap(attention_summary_df, cmap='viridis')
plt.title("Attention heatmap: Target vs Ref cell types")
plt.ylabel("Target cell type (predicted)")
plt.xlabel("Reference cell type")
plt.tight_layout()
plt.savefig(f"{OUTDIR}/attention_heatmap.png")

print("✅ Done! Outputs saved in", OUTDIR)

# === END ===
