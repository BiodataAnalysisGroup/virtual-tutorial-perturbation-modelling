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

Follow the steps for **your operating system only**. Everything is copy‑&‑paste‑ready.

### Windows 10 / 11 (Pro or Home)

> The commands below work in the standard **PowerShell** that ships with Windows. Press <kbd>⊞ Win</kbd>, type “PowerShell” and hit ⏎ *enter*.

1. **Install Git** – required to download this repository.

   ```powershell
   winget install --id Git.Git -e --source winget
   ```

   Close & reopen PowerShell once it finishes.

2. **Clone the repository** (creates a new folder `virtual‑tutorial‑perturbation‑modelling`).

   ```powershell
   git clone https://github.com/BiodataAnalysisGroup/virtual-tutorial-perturbation-modelling.git
   cd virtual-tutorial-perturbation-modelling
   ```

   > No Git? Grab a ZIP instead: [https://github.com/BiodataAnalysisGroup/virtual-tutorial-perturbation-modelling/archive/refs/heads/main.zip](https://github.com/BiodataAnalysisGroup/virtual-tutorial-perturbation-modelling/archive/refs/heads/main.zip), then **right‑click ▸ Extract All…** and continue in that folder.

3. **Download the data (≈850 MB)** into the `data/` directory.

   ```powershell
    Invoke-WebRequest `
    "https://zenodo.org/records/15745452/files/zenodo_perturbations_ECCB2025.zip?download=1" `
    -OutFile .\data\perturbations.zip
    Expand-Archive -Path .\data\perturbations.zip -DestinationPath .\data -Force
    Remove-Item     .\data\perturbations.zip
   ```
    If you run into an error, you can also download the data manually from [https://zenodo.org/records/15745452](https://zenodo.org/records/15745452) and unpack it into the `data/` folder.

4. **Install Miniconda** (light‑weight Python distribution).

   ```powershell
   curl -L -o miniconda.exe "https://repo.anaconda.com/miniconda/Miniconda3-latest-Windows-x86_64.exe"
   Start-Process .\miniconda.exe -ArgumentList "/S /D=%UserProfile%\Miniconda3" -Wait
   Remove-Item miniconda.exe
   # initialise Conda for PowerShell
   & "%UserProfile%\Miniconda3\Scripts\conda.exe" init powershell
   exit   # close PowerShell, then reopen it so 'conda' is on your PATH
   ```

5. **Create the two tutorial environments.**  Each takes \~2–4 min.

   ```powershell
   cd virtual-tutorial-perturbation-modelling  # if you are not already inside
   conda env create -f envs\environment_scgen.yml
   conda env create -f envs\environment_scpram.yml
   ```

6. **Run the notebooks.**  Open *one* environment at a time:

   ```powershell
   # to explore the scGen notebook
   conda activate scgen
   jupyter notebook
   # a browser tab opens – double‑click notebooks/scGen_Tutorial_ECCB2025.ipynb
   ```

   Use <kbd>Ctrl+↵ Enter</kbd> to execute a cell. When done, close Jupyter, `conda deactivate`, then `conda activate scpram` to try the second tool.

---

### macOS (12 Monterey +) & Linux (Ubuntu 20.04 +)

These systems can run an *automated* script that installs everything in one shot.

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

   The script will

   1. install **Miniconda** (locally under `~/miniconda3`),
   2. create the **`scgen`** and **`scpram`** environments,
   3. **download & unpack** the Kang 2018 data into `data/`.
      Answer **Y** when prompted to launch Jupyter automatically; otherwise run:

   ```bash
   conda activate scgen   # or: conda activate scpram
   jupyter notebook
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