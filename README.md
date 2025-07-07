# Generative AI for Single-Cell Perturbation Modeling: Theoretical and Practical Considerations (ISMB/ECCB 2025 - Virtual Tutorial 8)

Welcome! This repository accompanies the **ECCB 2025 virtual tutorial** on perturbation modelling with [**scGen**](https://github.com/theislab/scgen) and [**scPRAM**](https://github.com/jiang-q19/scPRAM). It contains:
* step‑by‑step hands-on **Jupyter notebooks** that reproduce all analyses shown live,
* ready‑made **Conda environments** (`envs/`) for both tools,
* a one‑click installer script (`install_requirements.sh`) for macOS and Linux, 
* a PDF file of the presentation shown live and
* a `data/` directory that will contain the datasets used in the tutorial.

Absolute beginners are welcome — the instructions below assume **zero prior experience** with Git, the terminal or Python.

---

## 🛠️ Step-by-Step Installation

Follow **only the block that matches your operating system**. In the end you will have two ready‑to‑run Conda environments – **`scgen`** and **`scpram`** – plus the Kang 2018 demo dataset in a local `data/` folder. It is recommended that we have **at least 40 GB of free disk space** available.

> **How to paste commands**
>
> *Windows / WSL*: click anywhere inside the terminal ▸ **Right‑click** ▸ the command appears ▸ press **⏎ Enter**.
> *macOS / Linux*: click ▸ **⌘ V** or **Ctrl Shift V** ▸ **⏎ Enter**.
> Run **one command at a time** and wait until it finishes before moving on.

### 1. Windows 10/11 (Home or Pro) — use **WSL 2 + Ubuntu**

The simplest path on Windows is to let Microsoft’s **Windows Subsystem for Linux 2
(WSL 2)** run a tiny Ubuntu Linux under the hood and then follow the same
one‑click installer we use on macOS & Linux.

> **Which Windows versions are OK?**  
> ◼︎ **Windows 11** (any edition) – WSL 2 ships out-of-the-box  
> ◼︎ **Windows 10 21H2 or newer** (build 19044 or later) – also fine  
> ◼︎ Older Windows 10? Update to the latest feature release or use a different computer, otherwise Linux containers will not work.

#### 1.1. Turn on WSL 2 and fetch Ubuntu

1. Press **⊞ Start**, type **PowerShell**, right‑click **«Windows PowerShell»** ▸ **Run as administrator**.
2. Paste the one‑liner below **exactly** as shown and press **⏎ Enter**:

   ```powershell
   wsl --install
   ```

   *What happens next?*  Windows enables Virtual Machine Platform, downloads Ubuntu automatically and asks you to **reboot**.  Do so.

3. After the reboot a black window titled **«Ubuntu»** pops up automatically. Choose a **user name** (e.g. `tutorial`) and a **password** (type and hit ⏎ Enter – the characters stay invisible, that is normal).

> If *PowerShell* says the above command is unknown you are on an outdated Windows build. Follow [Microsoft’s manual guide](https://learn.microsoft.com/en-us/windows/wsl/install-manual) instead.

#### 1.2. Install Git inside Ubuntu

1. Click **⊞ Start**, type **Ubuntu**, hit **⏎ Enter**. A terminal opens with a prompt like `tutorial@PC:~$`.
2. Copy & paste:

   ```bash
   sudo apt update && sudo apt install git -y
   ```
   Enter your password (the one you just created) when prompted (again, it stays invisible) then press ⏎ Enter.

#### 1.3. Clone the repository & run the auto‑installer inside WSL

```bash
# still inside the Ubuntu terminal
git clone https://github.com/BiodataAnalysisGroup/virtual-tutorial-perturbation-modelling.git
cd virtual-tutorial-perturbation-modelling
chmod +x install_requirements.sh
```

```bash
./install_requirements.sh
```

This will take a while - the script will:
* download **six 〈\*.h5ad〉 files** (\~850 MB) into `data/`,
* install **Miniconda** (skipped if **any** Conda-compatible tool – Conda, Mamba or Micromamba – is already on your system) and
* build the **`scgen`** and **`scpram`** envs

At the end answer **Y** to start Jupyter right away **or** press **N** and read “Usage once installed” below.

---

### 2. macOS (12 Monterey +) & native Linux (Ubuntu 20.04 +)

1. **Open the terminal** …

   * macOS: press **⌘ Space**, type **Terminal**, hit **⏎**
   * Linux: press **Ctrl Alt T**

2. **Install Git** (only the first time):

   ```bash
   # macOS
   brew install git              # installs Homebrew first if needed
   ```

   ```bash
   # Linux (Ubuntu/WSL)
   sudo apt update && sudo apt install git -y
   ```

3. **Clone & install**:

   ```bash
   git clone https://github.com/BiodataAnalysisGroup/virtual-tutorial-perturbation-modelling.git
   cd virtual-tutorial-perturbation-modelling
   chmod +x install_requirements.sh
   ```

   ```bash
   ./install_requirements.sh
   ```

   The script behaves the same as on Windows/WSL (see above).
---

### 3. Manual step‑by‑step alternative (macOS / Linux / WSL)

If you prefer to **see every step** or your network blocks large scripts:

```bash
# 1) prerequisites --------------------------------------------------
#    (Git + curl + unzip already present on most systems)

sudo apt update && sudo apt install git curl unzip -y   # Debian/Ubuntu/WSL
# macOS: brew install git curl unzip
```

```bash
# 2) clone the repo -------------------------------------------------

git clone https://github.com/BiodataAnalysisGroup/virtual-tutorial-perturbation-modelling.git
cd virtual-tutorial-perturbation-modelling
```

```bash
# 3) download ONLY the 6 .h5ad files (≈ 850 MB) ---------------------

mkdir -p data
ZIP=data/zenodo_perturbations_ECCB2025.zip
curl -L -o "$ZIP" \
  "https://zenodo.org/records/15745452/files/zenodo_perturbations_ECCB2025.zip?download=1"

unzip -j -qq "$ZIP" 'zenodo_perturbations_ECCB2025/*.h5ad' -d data/
find data -type f -name '._*' -delete
rm "$ZIP"
```

```bash
# 4) install Miniconda (skip if you already have conda / mamba / micromamba) ----

if ! (command -v conda || command -v mamba || command -v micromamba) &>/dev/null; then
  # no package-manager found  →  install a *fresh* Miniconda under ~/miniconda3
  case "$(uname -s)-$(uname -m)" in
    Darwin-arm64*) URL=https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-arm64.sh ;;
    Darwin-*)      URL=https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-x86_64.sh ;;
    Linux-*)       URL=https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh  ;;
  esac
  curl -fsSL "$URL" -o miniconda.sh
  bash miniconda.sh -b -p "$HOME/miniconda3"
  rm miniconda.sh
  source "$HOME/miniconda3/etc/profile.d/conda.sh"
else
  # something is already installed – reuse it
  PKG_MGR=$(command -v conda || command -v mamba || command -v micromamba)
  echo "✔️  Re-using existing tool: $PKG_MGR"
  if [[ $(basename "$PKG_MGR") == micromamba ]]; then
    eval "$($PKG_MGR shell hook -s bash)"      # Micromamba
  else
    source "$($PKG_MGR info --base)/etc/profile.d/conda.sh"   # Conda / Mamba
  fi
fi

# automatically pick the right binary for later steps
PKG_MGR=$(command -v conda || command -v mamba || command -v micromamba)
```

```bash
# 5a) create the scGen environment ----------------------------------

$PKG_MGR env create -f envs/environment_scgen.yml
```

```bash
# 5b) create the scPRAM environment --------------------------------

$PKG_MGR env create -f envs/environment_scpram.yml
```

```bash
# 6) run Jupyter ------------------------------------------------------

$PKG_MGR activate scgen      # swap to scpram for the other notebook
jupyter-lab                  # opens in your browser – navigate to notebooks
```

---

## ▶️ Usage once installed

| task                       | command                                                    |
| -------------------------- | ---------------------------------------------------------- |
| Launch **scGen** notebook  | `<conda / mamba / micromamba> activate scgen && jupyter-lab`¹ |
| Launch **scPRAM** notebook | `<conda / mamba / micromamba> activate scpram && jupyter-lab`¹ |
| Stop Jupyter               | press <kbd>Ctrl</kbd>+<kbd>C</kbd> in the terminal         |

¹ **Use the same front-end the installer reported** (`conda`, `mamba` or `micromamba`). For example:

```bash
mamba activate scgen   # or: micromamba activate scgen
jupyter-lab
```

Navigate in the Jupyter file‑browser to `1_scGen/`, `2_scPRAM/` or `3_Benchrmaking/`, open a notebook and execute cells from top to bottom. Each notebook is **stand‑alone** – you can jump directly to benchmarking if you prefer.

---

## ❓ Troubleshooting

* **`conda: command not found`** – close & reopen the terminal; the installer added the correct shell hook for Conda / Mamba / Micromamba.
* **Port 8888 already in use** – run `jupyter-lab --port 8889` (any free port works).
* **Web‑browser does not open automatically** – copy the full `http://localhost:8888/?token=…` link printed in the terminal into your browser.
* **WSL says «kernel needs to be updated»** – open PowerShell as Admin ▸ `wsl --update`.
* **“Download from Zenodo fails or is very slow”** –  
  1. Open a terminal **inside the repository root** (where you already see the `install_requirements.sh` script).  
  2. Install the tiny Google-Drive helper once:  
     ```bash
     python -m pip install --quiet --upgrade gdown
     ```  
  3. Fetch the pre-zipped tutorial data (≈ 850 MB) from the temporary ECCB Drive mirror **directly into `data/`** and unzip it:  
     ```bash
     gdown --id 1wWd7hBaFbP3CHjsGrnwVEHN84pId6nbo \
           --output data/ECCB2025_material_2025.zip --no-cookies
     unzip -q data/ECCB2025_material_2025.zip -d data/
     rm    data/ECCB2025_material_2025.zip        # free the space
     ```  

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