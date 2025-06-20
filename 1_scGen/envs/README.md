# scGen

## Introduction

scGen is a generative model to predict single-cell perturbation response across cell types, studies and species
[(Nature Methods, 2019)](https://www.nature.com/articles/s41592-019-0494-8). scGen is implemented using the [scvi-tools framework](https://scvi-tools.org/).

## Getting Started

What you can do with scGen:

-   Train on a dataset with multiple cell types and conditions and predict the perturbation effect on the cell type
    which you only have in one condition. This scenario can be extended to multiple species where you want to predict
    the effect of a specific species using another or all the species.

-   Train on a dataset where you have two conditions (e.g. control and perturbed) and predict on second dataset
    with similar genes.

-   Remove batch effect on labeled data. In this scenario you need to provide cell_type and batch labels to
    the method. Note that `batch_removal` does not require all cell types to be present in all datasets (batches). If
    you have dataset specific cell type it will preserved as before.

-   We assume there exist two conditions in you dataset (e.g. control and perturbed). You can train the model and with
    your data and predict the perturbation for the cell type/species of interest.

-   We recommend to use normalized data for the training. A simple example for normalization pipeline using scanpy:

```python
import scanpy as sc

adata = sc.read(data)
sc.pp.normalize_total(adata)
sc.pp.log1p(adata)
```

-   We further recommend to use highly variable genes (HVG). For the most examples in the paper we used top ~7000
    HVG. However, this is optional and highly depend on your application and computational power.

## Installation

### Installation with pip

To install the latest version `scGen` via pip:

```bash
pip install scgen
```
Optionally, you can install `pertpy`, and load scgen

```bash
pip install pertpy
```
scGen via pertpy
```python
import pertpy as pt

pt.tl.Scgen()
```

or install the development version via pip:

```bash
pip install git+https://github.com/theislab/scgen.git
```

### Installation with conda

To install scGen with conda:

```bash
conda env create -f environment.yml
```

Then, activate conda environemnt:

```bash
conda activate scgen
```

### Installation with Docker

To install and use scGen via Docker:

```bash
sudo docker build -t scgen .
```

And, run the docker container:

```bash
sudo docker run --rm -ti scgen
```

## Examples

See examples at our [documentation site](https://scgen.readthedocs.io/).

## Reproducing paper results

In order to reproduce paper results visit [here](https://github.com/M0hammadL/scGen_reproducibility).

## References

Lotfollahi, Mohammad and Wolf, F. Alexander and Theis, Fabian J.
**"scGen predicts single-cell perturbation responses."**
Nature Methods, 2019. [pdf](https://rdcu.be/bMlbD)
