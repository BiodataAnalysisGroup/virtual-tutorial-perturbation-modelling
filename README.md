# virtual-tutorial-perturbation-modelling
This tutorial walks you through, environment setup and running  `scGen` and `scPRAM` to perform perturbation analysis on scRNAseq datasets
### Installation
#### cloning the repository
- using `git` 
```shell
git clone https://github.com/BiodataAnalysisGroup/virtual-tutorial-perturbation-modelling.git
```
-  or download it as [zip file](https://github.com/BiodataAnalysisGroup/virtual-tutorial-perturbation-modelling/archive/refs/heads/main.zip)  📦 here and unzip it
#### Data
Step 1: 📥 Download the Data for this tutorial is available on Zenodo:
https://doi.org/10.5281/zenodo.15745452
Download the data and unzip in the `/data` 📁 directory. 
#### For Windows
For **Windows** users, please paste the following command in the `PowerShell\Terminal`
```PowerShell
curl -L -o .\data\Kang.zip "https://zenodo.org/records/15745452/files/zenodo_perturbations_ECCB2025.zip?download=1"
Expand-Archive -Path .\data\Kang.zip -DestinationPath .\data\ -Force
```
Step 2:  Install `Miniconda` by running these commands in the Terminal:
```PowerShell
wget "https://repo.anaconda.com/miniconda/Miniconda3-latest-Windows-x86_64.exe" -outfile ".\miniconda.exe"
Start-Process -FilePath ".\miniconda.exe" -ArgumentList "/S" -Wait
del .\miniconda.exe
```
Step 3: Prior to running the tools, setup the environment for scGen and scPRAM:
```PowerShell
Start-Job { conda env create -f envs/environment_scgen.yml }
Start-Job { conda env create -f envs/environment_scpram.yml }
```
Step 4: Run the tools
Open the Anaconda Prompt (search for "Anaconda Prompt" in your Start menu), then start typing Open Anaconda Prompt → Activate environment → jupyter notebook
```Anaconda Promt
conda activate scgen && Jupyter Notebook
```
Navigate to the respective folders and run the scripts by selecting it. Replace scgen with scpram for running scPRAM.
#### For MacOS/Linux
Run  `install_requirenments.sh` script from the repository in your terminal, after cloning the repo:
```shell
chmod +x install_requirements.sh && ./install_requirements.sh
```
In Linux/MacOS it is pretty easy to run, the script will ask you whether you want to run the scripts while installation, just give Yes/Y.
