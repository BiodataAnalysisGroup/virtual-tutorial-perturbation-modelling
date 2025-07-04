#!/usr/bin/env bash
set -euo pipefail

# ────────────────────────────────
# helper: coloured echo
# ────────────────────────────────
info () { printf "\e[1;34m%s\e[0m\n" "$*"; }
warn () { printf "\e[1;33m%s\e[0m\n" "$*"; }
err  () { printf "\e[1;31m%s\e[0m\n" "$*"; }

# ────────────────────────────────
# 0) make sure basic CLI tools are present
# ────────────────────────────────
REQUIRED=(curl unzip tar bzip2)        # extend here if you hit new gaps
MISSING=()
for cmd in "${REQUIRED[@]}"; do
    command -v "$cmd" &>/dev/null || MISSING+=("$cmd")
done
if ((${#MISSING[@]})); then
    warn "🔧  Installing missing system packages: ${MISSING[*]}"
    sudo apt-get update -qq
    sudo apt-get install -y "${MISSING[@]}"
fi

# ────────────────────────────────
# 1) download Kang 2018 dataset
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
# 2) (optional) show system Python / Pip
# ────────────────────────────────
if command -v python >/dev/null; then
    info "$(python --version) @ $(which python)"
else
    warn "No system Python found (that’s fine, Miniconda will provide one)."
fi
if command -v pip >/dev/null;   then
    info "$(pip --version) @ $(which pip)"
fi

# ────────────────────────────────
# 3) install  ▸ or ▸  reuse  Miniconda / Anaconda
# ────────────────────────────────
MINICONDA_DIR="$HOME/miniconda3"     # target if we must install a *new* one
CONDA_BASE=""                        # will point to the true base afterwards
NEED_FRESH_INSTALL=false

if command -v conda &>/dev/null; then               # ---------------- reuse
    CONDA_BASE=$(conda info --base)
    info "👍  Re-using existing Conda at:  $CONDA_BASE"
else                                                # ---------------- install
    NEED_FRESH_INSTALL=true
    info "🚀  No Conda found – installing Miniconda under  $MINICONDA_DIR …"

    # pick the right installer for the host OS / arch
    case "$(uname -s)-$(uname -m)" in
        Darwin-arm64*)  URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-arm64.sh"  ;;
        Darwin-*)       URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-x86_64.sh" ;;
        Linux-*)        URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh"  ;;   # Linux & WSL
        *)              err "❌  Unsupported platform.  Windows users: run via WSL 2."; exit 1 ;;
    esac

    curl -fsSL "$URL" -o /tmp/miniconda.sh
    bash /tmp/miniconda.sh -b -u -p "$MINICONDA_DIR"
    rm  /tmp/miniconda.sh
    CONDA_BASE="$MINICONDA_DIR"
fi

# ── make Conda available *now* and for future shells ─────────────────
source "$CONDA_BASE/etc/profile.d/conda.sh"

# add to ~/.bashrc  (only once)
grep -qxF "source \"$CONDA_BASE/etc/profile.d/conda.sh\"" "$HOME/.bashrc" \
  || echo "source \"$CONDA_BASE/etc/profile.d/conda.sh\"" >>"$HOME/.bashrc"

conda activate base

# ────────────────────────────────
# 4) create tutorial environments *sequentially*
# ────────────────────────────────
info "⏳  Creating Conda environments (scgen & scpram) …"
for YAML in envs/environment_scgen.yml envs/environment_scpram.yml; do
    ENV_NAME=$(grep '^name:' "$YAML" | awk '{print $2}')
    info "   ➡️  Creating environment: $ENV_NAME"
    if conda info --envs | grep -qE "^\s*$ENV_NAME\s"; then
        info "   ✔️  Environment $ENV_NAME already exists – skipping."
    else
        conda env create -f "$YAML" || { err "Environment $ENV_NAME failed."; exit 1; }
    fi
done
info "   ✔️  Environments ready."

# ────────────────────────────────
# 5) optional: install CUDA-enabled PyTorch
# ────────────────────────────────
if command -v nvidia-smi &>/dev/null; then
    info "⚙️  NVIDIA GPU detected – installing CUDA-enabled PyTorch …"

    # pick the highest CUDA toolkit that your driver supports
    DRIVER_MAJOR=$(nvidia-smi --query-gpu=driver_version --format=csv,noheader \
                   | head -n1 | cut -d. -f1)

    if   (( DRIVER_MAJOR >= 550 )); then CUDA_VER="12.4"
    elif (( DRIVER_MAJOR >= 545 )); then CUDA_VER="12.3"
    elif (( DRIVER_MAJOR >= 535 )); then CUDA_VER="12.2"
    elif (( DRIVER_MAJOR >= 525 )); then CUDA_VER="12.1"
    else                                CUDA_VER="11.8"
    fi

    for ENV in scgen scpram; do
        conda run -n "$ENV" \
          conda install -y pytorch pytorch-cuda="$CUDA_VER" \
                          torchvision torchaudio           \
                          -c pytorch -c nvidia
    done

    info "   ✔️  GPU acceleration ready (CUDA $CUDA_VER) for both envs."
else
    warn "ℹ️  No NVIDIA GPU found – keeping CPU-only PyTorch."
fi

# ────────────────────────────────
# 6) optional: launch notebooks
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