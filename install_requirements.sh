#!/usr/bin/env bash
set -euo pipefail

# ────────────────────────────────
# helper: coloured echo
# ────────────────────────────────
info () { printf "\e[1;34m%s\e[0m\n" "$*"; }
warn () { printf "\e[1;33m%s\e[0m\n" "$*"; }
err  () { printf "\e[1;31m%s\e[0m\n" "$*"; }

# ────────────────────────────────
# 0) download Kang 2018 dataset
# ────────────────────────────────
info "📥  Downloading tutorial data from Zenodo …"
mkdir -p data
ZIP_PATH="data/zenodo_perturbations_ECCB2025.zip"

curl -L -o "$ZIP_PATH" \
     "https://zenodo.org/records/15745452/files/zenodo_perturbations_ECCB2025.zip?download=1"

# extract *only* .h5ad files from the inner folder, strip path (-j)
info "📂  Extracting .h5ad files …"
unzip -j -qq "$ZIP_PATH" 'zenodo_perturbations_ECCB2025/*.h5ad' -d data/

# drop macOS resource forks such as ._kang_2018.h5ad
find data -type f -name '._*' -delete

rm "$ZIP_PATH"
info "   ✔️  data/ now contains: $(ls data/*.h5ad | wc -l)  H5AD files."

# ────────────────────────────────
# 1) check system Python / Pip
# ────────────────────────────────
info "$(python --version) @ $(which python)"
info "$(pip    --version) @ $(which pip)"

# ────────────────────────────────
# 2) (maybe) install Miniconda
# ────────────────────────────────
MINICONDA_DIR="$HOME/miniconda3"
INSTALL_MINICONDA=true

if command -v conda >/dev/null; then
    warn "⚠️  A Conda installation already exists at:  $(command -v conda)"
    read -rp "   Re-use this Conda? [Y/n] " ans
    if [[ ! $ans =~ ^[Nn]$ ]]; then
        INSTALL_MINICONDA=false
        # shell-init for bash/zsh – works for both mamba & conda
        source "$(conda info --base)/etc/profile.d/conda.sh"
        info "   👍  Re-using existing Conda."
    else
        warn "   Will install a fresh Miniconda under $MINICONDA_DIR"
    fi
fi

if [[ $INSTALL_MINICONDA == true ]]; then
    info "🚀  Installing Miniconda …"
    OS=$(uname -s)
    ARCH=$(uname -m)
    case "$OS" in
        Darwin)
            URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-${ARCH}.sh"
            ;;
        Linux)
            URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh"
            ;;
        *)
            err  "This OS is unsupported. Windows users: see README (use WSL)."
            exit 1
            ;;
    esac
    mkdir -p "$MINICONDA_DIR"
    curl -fsSL "$URL" -o "$MINICONDA_DIR/miniconda.sh"
    bash "$MINICONDA_DIR/miniconda.sh" -b -u -p "$MINICONDA_DIR"
    rm  "$MINICONDA_DIR/miniconda.sh"
    source "$MINICONDA_DIR/etc/profile.d/conda.sh"
    info "   ✔️  Miniconda ready."
fi

# ────────────────────────────────
# 3) create tutorial environments
# ────────────────────────────────
info "⏳  Creating Conda environments (scgen & scpram) … this may take a while."
conda clean --all -y
conda env create -f envs/environment_scgen.yml &
conda env create -f envs/environment_scpram.yml &
wait
info "   ✔️  Environments created."

# ────────────────────────────────
# 4) auto-install GPU PyTorch if an NVIDIA card is present
# ────────────────────────────────
if command -v nvidia-smi &>/dev/null; then
    info "⚙️  NVIDIA GPU detected – installing CUDA-enabled PyTorch …"
    # Pick the toolkit version that matches the driver (12.x → CUDA 12, else 11.8)
    DRIVER_MAJOR=$(nvidia-smi --query-gpu=driver_version --format=csv,noheader | head -n1 | cut -d. -f1)
    if (( DRIVER_MAJOR >= 525 )); then
        CUDA_VER="12.1"
    else
        CUDA_VER="11.8"
    fi
    for ENV in scgen scpram; do
        conda activate "$ENV"
        conda install -y pytorch pytorch-cuda=$CUDA_VER -c pytorch -c nvidia
        conda deactivate
    done
    info "   ✔️  GPU acceleration ready (CUDA $CUDA_VER)."
else
    warn "ℹ️  No NVIDIA GPU found – keeping CPU-only PyTorch."
fi

# ────────────────────────────────
# 5) optional: launch notebooks
# ────────────────────────────────
read -rp "▶️  Launch scGen notebook now? [y/N] " run
if [[ $run =~ ^[Yy]$ ]]; then
    conda activate scgen
    jupyter-lab 1_scGen/scGen_Tutorial_ECCB2025.ipynb
    conda deactivate
fi

read -rp "▶️  Launch scPRAM notebook now? [y/N] " run
if [[ $run =~ ^[Yy]$ ]]; then
    conda activate scpram
    jupyter-lab 2_scPRAM/scPRAM_Tutorial_ECCB2025.ipynb
    conda deactivate
fi

info "🥳  Setup finished – happy analysing!"