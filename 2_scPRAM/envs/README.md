# scPRAM

## Introduction

scPRAM is a predictive model for single-cell gene expression responses to perturbations, built on an attention mechanism. Leveraging variational autoencoders and optimal transport, scPRAM aligns cellular states before and after perturbation and then uses attention to accurately predict expression responses in unseen cell types, species, or individuals ([Bioinformatics, 2024](https://pubmed.ncbi.nlm.nih.gov/38625746/); [GitHub](https://github.com/jiang-q19/scPRAM)).

## Features

- **Predict perturbation effects** on cell types or species with limited or no direct perturbed data.
- **Capture cellular heterogeneity** in response distributions, beyond average effects.
- **Identify differentially expressed genes** under various perturbation conditions.
- **Robust performance** in the presence of data noise and varying sample sizes.

## Installation

### 1. Via pip

```bash
pip install scpram
```

### 2. Via conda (using `environment.yml`)

```bash
conda env create -f environment.yml
conda activate scpram
```

> **Tip:** Adjust the `prefix` in `environment.yml` if needed to point to your local Conda environments directory.


## Quick Start

Follow these three steps to run a basic perturbation prediction pipeline:

### 1. Data preprocessing

If your single-cell dataset is already preprocessed (QC, normalization) with Scanpy, skip this step. Otherwise:

```python
from scpram.data_process import adata_process
adata = adata_process(
    adata,
    min_genes=200,
    min_cells=10,
    n_top_genes=6000
)
```

### 2. Model training

Define a `key_dic` dictionary specifying cell type and condition keys, then train the model:

```python
from scpram.model import scPRAM

model = scPRAM(n_latent=20, learning_rate=1e-3)

# Example key_dic:
#key_dic = {
#    'condition_key': 'label',
#    'cell_type_key': 'cell_type',
#    'ctrl_key': 'ctrl',
#    'stim_key': 'stim',
#    'pred_key': 'pred'
#}

model.fit(adata, key_dic)
```

### 3. Prediction and evaluation

Apply the trained model to held-out (unseen) cells and evaluate performance evaluations metrics available in scPRAM.
replace the evaluate.py by which one provide in the git repository in the directory: “anaconda3”/envs/scPRAM/lib/python3.8/site-packages/scpram/ 

```python
preds = model.predict(adata_test, key_dic)
ground_truth = adata[(adata.obs[key_dic['cell_type_key']] == cell_to_pred)]
eval_adata = ground_truth.concatenate(pred)
eval_adata.obs[key_dic['condition_key']] = eval_adata.obs[key_dic['condition_key']].astype('category').cat.remove_unused_categories()
eval_adata_dict[cell_to_pred] = eval_adata

from scpram import evaluate
# Optional quick evaluation 
evaluate.evaluate_adata(eval_adata=eval_adata,
                        cell_type=cell_to_pred,
                        key_dic=key_dic)
```

## Tutorial

See the detailed Jupyter notebook (`scPRAM_tutorial.ipynb`) for a full walkthrough of the pipeline using a PBMC dataset.

## Files

- `environment.yml`: Conda environment configuration
- `evaluate.py`: evaluate script to replace in scPRAM env
- `scPRAM_tutorial_GGversion.ipynb`: Interactive tutorial notebook
- `README.md`: This file

## References

1. Qun Jiang, Shengquan Chen, Xiaoyang Chen, Rui Jiang. "scPRAM accurately predicts single-cell gene expression perturbation response based on attention mechanism." *Bioinformatics*, 2024. DOI:10.1093/bioinformatics/btae265
2. scPRAM GitHub repository: [https://github.com/jiang-q19/scPRAM](https://github.com/jiang-q19/scPRAM)

