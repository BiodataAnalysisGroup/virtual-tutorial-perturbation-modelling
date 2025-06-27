### Installation

### clone the repo
Either using `git` 
```shell
git clone https://github.com/BiodataAnalysisGroup/virtual-tutorial-perturbation-modelling.git
```
or download it as zip file and unzip it
#### For Windows
Open PowerShell/Terminal and type:
```
python --version
pip --version
```
Install `python3`, if not available on your system
```PowerShell
winget install -e --id Python.Python.3.11
```
Install `Miniconda` by running these commands in the Terminal:
```PowerShell
wget "https://repo.anaconda.com/miniconda/Miniconda3-latest-Windows-x86_64.exe" -outfile ".\miniconda.exe"
Start-Process -FilePath ".\miniconda.exe" -ArgumentList "/S" -Wait
del .\miniconda.exe
```
After installing Miniconda, setup the environment for scGen and scPRAM:
```PowerShell
Start-Job { conda env create -f envs/environment_scgen.yml }
Start-Job { conda env create -f envs/environment_scpram.yml }
```
#### For MacOS/Linux
Use the `install_requirenments.sh` script from the repository:
```shell
chmod +x install_requirements.sh && ./install_requirements.sh
```
