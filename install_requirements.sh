#!/usr/bin/env bash
# git clone https://github.com/BiodataAnalysisGroup/virtual-tutorial-perturbation-modelling.git
# cd virtual-tutorial-pereturbation-modelling/

# Environmental setup script for MacOS/Linux
# For Windows, please refer the README section

# Python3 and Pip
python --version		# verify your python installation
pip --version
which python
which pip
# if you get an error, try installing latest version of python from the (official website)[https://www.python.org/downloads/]

## install Miniconda
# Please refer this (site)[https://www.anaconda.com/docs/getting-started/miniconda/install] for any quries

set -e

OS=$(uname -s)
ARCH=$(uname -m)
MINICONDA_DIR="$HOME/miniconda3"

case "$OS" in
    Darwin)
        if [ "$ARCH" = "arm64" ]; then
            URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-arm64.sh"
        else
            URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-x86_64.sh"
        fi
        ;;
    Linux)
        URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh"
        ;;
    *)
        echo "This OS is currently unsupported"
        exit 1
        ;;
esac

mkdir -p "$MINICONDA_DIR"
curl -fsSL "$URL" -o "$MINICONDA_DIR/miniconda.sh"
bash "$MINICONDA_DIR/miniconda.sh" -b -u -p "$MINICONDA_DIR"
rm "$MINICONDA_DIR/miniconda.sh"
source "$MINICONDA_DIR/bin/activate"

# Parallel environment creation (may cause cache conflicts if environments share packages)
conda env create -f envs/environment_scgen.yml &
conda env create -f envs/environment_scpram.yml &
wait
