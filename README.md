# Generative AI for Single-Cell Perturbation Modeling: Theoretical and Practical Considerations (ISMB/ECCB 2025 - Virtual Tutorial 8)

Welcome! This repository accompanies the **ECCB 2025 virtual tutorial** on perturbation modelling with [**scGen**](https://github.com/theislab/scgen) and [**scPRAM**](https://github.com/jiang-q19/scPRAM). It contains:
* step‑by‑step hands-on **Jupyter notebooks** that reproduce all analyses shown live,
* ready‑made **Conda environments** (`envs/`) for both tools,
* a one‑click installer script (`install_requirements.sh`) for macOS and Linux, 
* a PDF file of the presentation shown live and
* a `data/` directory that will contain the datasets used in the tutorial.

Absolute beginners are welcome — the instructions below assume **zero prior experience** with Git, the terminal or Python.

---

## 🛠️ Installation

Follow the steps for **your operating system only** — you will end up with two ready‑to‑use Conda environments called **`scgen`** and **`scpram`** plus a local copy of the tutorial data.

> **Tip for first‑timers:**
> Copy a command → click inside your terminal → **right‑click → paste** → hit ⏎ *enter*.
> Run the commands **one at a time** and wait until each finishes.

### 1. Windows 10/11 (Home or Pro) — via **WSL 2**

The simplest path on Windows is to let Microsoft’s **Windows Subsystem for Linux 2
(WSL 2)** run a tiny Ubuntu Linux under the hood and then follow the same
one‑click installer we use on macOS & Linux.

1. **Enable WSL 2 and install Ubuntu (one‑off, ≈3 min)**

   Open *PowerShell as Administrator* and paste:

   ```powershell
   wsl --install
   ```

   Reboot when prompted.
   After the reboot Windows finishes downloading Ubuntu; choose a **username**
   (e.g. `tutorial`) and **password** when the black “Ubuntu” window appears.

2. **Open Ubuntu** (look for *“Ubuntu”* in the Start menu) and install **Git**:

   ```bash
   sudo apt update && sudo apt install git -y
   ```

3. **Clone the repository & run the auto‑installer inside WSL:**

   ```bash
   git clone https://github.com/BiodataAnalysisGroup/virtual-tutorial-perturbation-modelling.git
   cd virtual-tutorial-perturbation-modelling
   chmod +x install_requirements.sh
   ./install_requirements.sh
   ```

   The script

   * installs **Miniconda** under `~/miniconda3`,
   * creates the **`scgen`** and **`scpram`** environments,
   * downloads & unpacks the Kang 2018 tutorial data into `data/`.

   When it finishes you can already launch Jupyter (answer **Y** when asked) or
   see *Usage* further below.

---

### 2. macOS (12 Monterey +) & native **Linux** (Ubuntu 20.04 +)

Exactly the same steps as inside WSL:

1. **Open Terminal** (⌘‑Space ▸ Terminal on macOS; <kbd>Ctrl</kbd>+<kbd>Alt</kbd>+<kbd>T</kbd> on Linux).
2. **Install Git** if missing:
   *macOS*: `brew install git`  (install Homebrew first from [https://brew.sh](https://brew.sh))
   *Ubuntu*: `sudo apt update && sudo apt install git -y`
3. **Clone the repository** & run the installer:

   ```bash
    git clone https://github.com/BiodataAnalysisGroup/virtual-tutorial-perturbation-modelling.git
    cd virtual-tutorial-perturbation-modelling
    chmod +x install_requirements.sh
    ./install_requirements.sh
   ```

   Answer **Y** when prompted to launch Jupyter automatically; otherwise run:

   ```bash
    conda activate scgen   # or: conda activate scpram
    jupyter notebook
   ```

---

### 3. Manual step‑by‑step alternative (macOS / Linux / WSL)

If you prefer to install everything yourself:

```bash
# A) install Git if missing
sudo apt update && sudo apt install git -y          # Ubuntu / WSL
# macOS: brew install git

# B) clone the repo
git clone https://github.com/BiodataAnalysisGroup/virtual-tutorial-perturbation-modelling.git
cd virtual-tutorial-perturbation-modelling

# C) download *only* the .h5ad files from Zenodo  (≈ 850 MB → 6 files)
mkdir -p data
ZIP=data/zenodo_perturbations_ECCB2025.zip
curl -L -o "$ZIP" \
  "https://zenodo.org/records/15745452/files/zenodo_perturbations_ECCB2025.zip?download=1"

#   -j  = ‘junk’ the paths (flatten)
#   '*.h5ad' inside the inner folder only
unzip -j -qq "$ZIP" 'zenodo_perturbations_ECCB2025/*.h5ad' -d data/
find data -type f -name '._*' -delete        # drop macOS resource forks
rm "$ZIP"

# D) install Miniconda *unless you already have conda / mamba*
if ! command -v conda &> /dev/null; then
  wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh
  bash miniconda.sh -b -p $HOME/miniconda3
  rm miniconda.sh
  source "$HOME/miniconda3/etc/profile.d/conda.sh"
else
  echo "✔️  Re-using existing Conda at: $(command -v conda)"
  source "$(conda info --base)/etc/profile.d/conda.sh"
fi

# E) create the two tutorial environments
conda env create -f envs/environment_scgen.yml
conda env create -f envs/environment_scpram.yml

# F) launch Jupyter
conda activate scgen   # swap to scpram to explore the other notebook
jupyter-lab
```

---

## ▶️ Usage once installed

| task                       | command                                                    |
| -------------------------- | ---------------------------------------------------------- |
| Launch **scGen** notebook  | `conda activate scgen && jupyter notebook`                 |
| Launch **scPRAM** notebook | `conda activate scpram && jupyter notebook`                |
| Stop Jupyter               | press <kbd>Ctrl</kbd>+<kbd>C</kbd> in the terminal         |
| Update envs later          | `conda env update -n scgen  -f envs/environment_scgen.yml` |

Navigate in the Jupyter file‑browser to `notebooks/`, open a tutorial and execute cells from top to bottom. Each notebook is **stand‑alone** – you can jump directly to benchmarking if you prefer.

---

## ❓ Troubleshooting

* **`conda: command not found`** – close & reopen the terminal (Conda adds itself to your shell profile).
* **Port 8888 already in use** – run `jupyter notebook --port 8889` (any free port works).
* **Web‑browser does not open automatically** – copy the full `http://localhost:8888/?token=…` link printed in the terminal into your browser.

If you are stuck, open an issue on the GitHub page or ask during the workshop (on July 14th 2025) – we are happy to help!

---

## 📚 References

1. Lotfollahi et al. *scGen predicts single-cell perturbation response.s* **Nat Methods** 16, 715‑721 (2019) [https://www.nature.com/articles/s41592-019-0494-8](https://www.nature.com/articles/s41592-019-0494-8)
2. Jiang et al. *scPRAM accurately predicts single-cell gene expression perturbation response based on attention mechanism.* **Bioinformatics** 40, btae265 (2024) [https://academic.oup.com/bioinformatics/article/40/5/btae265/7646141](https://academic.oup.com/bioinformatics/article/40/5/btae265/7646141)
3. Rood et al. *Toward a foundation model of causal cell and tissue biology with a Perturbation Cell and Tissue Atlas.* **Cell** (2024) [https://www.cell.com/cell/fulltext/S0092-8674(24)00829-8](https://www.cell.com/cell/fulltext/S0092-8674%2824%2900829-8)
4. Gavriilidis et al. *A mini-review on perturbation modelling across single-cell omic modalities.* **Computational and Structural Biotechnology Journal** 22, 1891‑1913 (2024) [https://www.sciencedirect.com/science/article/pii/S2001037024001417](https://www.sciencedirect.com/science/article/pii/S2001037024001417)
5. Ji et al. *Machine learning for perturbational single-cell omics.* **Cell Systems** 2021 [https://www.sciencedirect.com/science/article/pii/S2405471221002027](https://www.sciencedirect.com/science/article/pii/S2405471221002027)
6. Heumos et al. *Pertpy: an end-to-end framework for perturbation analysis.* **bioRxiv** (2024) [https://www.biorxiv.org/content/10.1101/2024.08.04.606516v1](https://www.biorxiv.org/content/10.1101/2024.08.04.606516v1)
7. Akiba et al. *Optuna: A Next‑generation Hyperparameter Optimization Framework.* **arXiv** (2019) [https://arxiv.org/abs/1907.10902](https://arxiv.org/abs/1907.10902)

---