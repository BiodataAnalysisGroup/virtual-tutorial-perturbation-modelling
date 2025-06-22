# run_scpram_scatter_r2.py

import os
import scanpy as sc
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

from scpram import models, evaluate

# === CONFIG ===
OUTDIR = '/content/scpram_outputs'
os.makedirs(OUTDIR, exist_ok=True)

adata = sc.read('train_pbmc.h5ad')

# Setup model
model = models.SCPRAM(input_dim=adata.n_vars, device='cuda:0')
model = model.to(model.device)

# Keys
key_dic = {
    'condition_key': 'condition',
    'cell_type_key': 'cell_type',
    'ctrl_key': 'control',
    'stim_key': 'stimulated',
    'pred_key': 'predict',
}

# What cell to predict
cell_to_pred = 'CD4T'

# Filter training set
train = adata[~((adata.obs[key_dic['cell_type_key']] == cell_to_pred) &
                (adata.obs[key_dic['condition_key']] == key_dic['stim_key']))]

# === TRAIN ===
model.train_SCPRAM(train, epochs=100)

# === PREDICT ===
pred = model.predict(train_adata=train,
                     cell_to_pred=cell_to_pred,
                     key_dic=key_dic,
                     ratio=0.005)

# === Prepare ctrl/stim/pred with correct labels ===
pred.obs['label'] = key_dic['pred_key']
ctrl = adata[(adata.obs[key_dic['cell_type_key']] == cell_to_pred) & (adata.obs[key_dic['condition_key']] == key_dic['ctrl_key'])].copy()
stim = adata[(adata.obs[key_dic['cell_type_key']] == cell_to_pred) & (adata.obs[key_dic['condition_key']] == key_dic['stim_key'])].copy()
ctrl.obs['label'] = key_dic['ctrl_key']
stim.obs['label'] = key_dic['stim_key']

# Build eval_adata
eval_adata = ctrl.concatenate(stim, pred)
eval_adata.obs['label'] = eval_adata.obs['label'].astype('category').cat.remove_unused_categories()

# PCA (optional)
sc.tl.pca(eval_adata)

# === Compute DEGs ===
K = 100
sc.tl.rank_genes_groups(
    eval_adata,
    groupby="label",
    reference=key_dic['ctrl_key'],
    groups=[key_dic['stim_key']],
    method="t-test",
    n_genes=eval_adata.n_vars
)
stim_de = eval_adata.uns['rank_genes_groups']['names'][key_dic['stim_key']][:K].tolist()

# === Compute mean expression ===
Xp_mean = np.asarray(pred.X.mean(0)).ravel()
Y_mean = np.asarray(stim.X.mean(0)).ravel()

# === R2 for all genes ===
ss_res_all = np.sum((Y_mean - Xp_mean)**2)
ss_tot_all = np.sum((Y_mean - Y_mean.mean())**2)
R2_all = 1 - ss_res_all / ss_tot_all if ss_tot_all > 0 else np.nan

plt.figure(figsize=(6,6))
plt.scatter(Y_mean, Xp_mean, alpha=0.6)
plt.plot([Y_mean.min(), Y_mean.max()], [Y_mean.min(), Y_mean.max()], 'r--')
plt.xlabel("True Mean Expression (stim)")
plt.ylabel("Predicted Mean Expression")
plt.title(f"All genes R² = {R2_all:.3f}")
plt.tight_layout()
plt.savefig(os.path.join(OUTDIR, 'R2_scatter_all_genes.png'))
print(f"✅ Saved R2 scatter for all genes")

# === R2 for top 100 DEGs ===
X_de = [eval_adata.var_names.get_loc(g) for g in stim_de if g in eval_adata.var_names]
Xp_mean_de = Xp_mean[X_de]
Y_mean_de = Y_mean[X_de]

ss_res_de = np.sum((Y_mean_de - Xp_mean_de)**2)
ss_tot_de = np.sum((Y_mean_de - Y_mean_de.mean())**2)
R2_de = 1 - ss_res_de / ss_tot_de if ss_tot_de > 0 else np.nan

plt.figure(figsize=(6,6))
plt.scatter(Y_mean_de, Xp_mean_de, alpha=0.6)
plt.plot([Y_mean_de.min(), Y_mean_de.max()], [Y_mean_de.min(), Y_mean_de.max()], 'r--')
plt.xlabel("True Mean Expression (stim)")
plt.ylabel("Predicted Mean Expression")
plt.title(f"Top 100 DEGs R² = {R2_de:.3f}")
plt.tight_layout()
plt.savefig(os.path.join(OUTDIR, 'R2_scatter_top100_DEGs.png'))
print(f"✅ Saved R2 scatter for top 100 DEGs")

# === Run scpram.evaluate ===
ground_truth = adata[(adata.obs[key_dic['cell_type_key']] == cell_to_pred)]
eval_adata_eval = ground_truth.concatenate(pred)
evaluate.evaluate_adata(eval_adata=eval_adata_eval,
                        cell_type=cell_to_pred,
                        key_dic=key_dic)

print(f"\n✨ All done! Outputs saved in: {OUTDIR}")