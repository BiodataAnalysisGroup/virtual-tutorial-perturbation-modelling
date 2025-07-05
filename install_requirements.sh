#!/usr/bin/env bash

# Exit immediately on errors, unset variables, and pipe failures
set -euo pipefail

# Clone repository (uncomment to use)
#git clone https://github.com/BiodataAnalysisGroup/virtual-tutorial-perturbation-modelling.git
#cd virtual-tutorial-perturbation-modelling/ || { echo "Failed to enter directory"; exit 1; }

# -------------------------------------------------------------------
# Download and prepare data
# -------------------------------------------------------------------
echo "📦 Downloading data from Zenodo..."
mkdir -p data

DATA_URL="https://zenodo.org/records/15745452/files/zenodo_perturbations_ECCB2025.zip"
ZIP_PATH="./data/perturbations_data.zip"

if ! curl -L -o "$ZIP_PATH" "$DATA_URL"; then
    echo "❌ Failed to download data"
    exit 1
fi

if ! unzip -u "$ZIP_PATH" -d data/; then
    echo "❌ Failed to unzip data"
    exit 1
fi

echo "✅ Data successfully downloaded and extracted!"

# -------------------------------------------------------------------
# Verify Python and pip
# -------------------------------------------------------------------
echo "🐍 Verifying Python and pip installations..."
if ! command -v python &> /dev/null; then
    echo "❌ Python not found! Please install: https://www.python.org/downloads/"
    exit 1
fi

if ! command -v pip &> /dev/null; then
    echo "❌ pip not found! Please install pip."
    exit 1
fi

echo "✔️ $(python --version) is installed"
echo "✔️ $(pip --version) is installed"

# -------------------------------------------------------------------
# Install Miniconda
# -------------------------------------------------------------------
echo "🐍 Installing Miniconda..."
MINICONDA_DIR="$HOME/miniconda3"

# Remove existing installation if needed
if [ -d "$MINICONDA_DIR" ]; then
    echo "⚠️ Miniconda already exists at $MINICONDA_DIR"
    read -rp "Overwrite existing installation? [y/N] " response
    if [[ "$response" =~ ^[Yy] ]]; then
        rm -rf "$MINICONDA_DIR"
    else
        echo "Using existing Miniconda installation"
    fi
fi

# Determine OS and architecture
OS=$(uname -s)
case "$OS" in
    Darwin)
        if [ "$(uname -m)" = "arm64" ]; then
            URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-arm64.sh"
        else
            URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-x86_64.sh"
        fi
        ;;
    Linux)
        URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh"
        ;;
    *)
        echo "❌ Unsupported OS: $OS"
        echo "For Windows setup, please see README.md"
        exit 1
        ;;
esac

# Download and install Miniconda
INSTALLER="miniconda_installer.sh"
curl -fsSL "$URL" -o "$INSTALLER"
bash "$INSTALLER" -b -p "$MINICONDA_DIR"
rm "$INSTALLER"

# Initialize conda
source "$MINICONDA_DIR/bin/activate"
conda init bash

echo "✅ Miniconda installed successfully!"

# -------------------------------------------------------------------
# Setup Conda environments
# -------------------------------------------------------------------
echo "🛠️ Creating conda environments..."
conda clean --all -y

# Create environments sequentially for better error handling
conda env create -f envs/environment_scgen.yml -n scgen
conda env create -f envs/environment_scpram.yml -n scpram

echo "🎉 Environment setup complete! (ﾉ◕ヮ◕)ﾉ*:･ﾟ✧"

# -------------------------------------------------------------------
# Run tutorials
# -------------------------------------------------------------------
run_notebook() {
    env_name="$1"
    notebook_path="$2"
    
    if conda activate "$env_name"; then
        echo "🚀 Starting Jupyter for $env_name..."
        jupyter notebook "$notebook_path"
    else
        echo "❌ Failed to activate $env_name environment"
    fi
}

echo "\n-------------------------------------------"
read -rp "Run scGen tutorial? [y/N] " run_scgen
if [[ "$run_scgen" =~ ^[Yy] ]]; then
    run_notebook "scgen" "1_scGen/scGen_Tutorial_ECCB2025.ipynb"
fi

echo "\n-------------------------------------------"
read -rp "Run scPRAM tutorial? [y/N] " run_scpram
if [[ "$run_scpram" =~ ^[Yy] ]]; then
    run_notebook "scpram" "1_scPRAM/scPRAM_Tutorial_ECCB2025.ipynb"
fi

echo "\n✨ Have lots of fun exploring! (^_^) ✨"
