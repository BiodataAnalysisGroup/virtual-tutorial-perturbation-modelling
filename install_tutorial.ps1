<#
install_tutorial.ps1 ─────────────────────────────────────────────────
All-in-one installer for the ECCB 2025 perturbation-modelling tutorial
using **micromamba** (fast, zero-admin Conda-compatible tool).

Tested on Windows 10 / 11 PowerShell (no admin rights required).
#>

#──────── helpers ───────────────────────────────────────────────────
function Has-Command ($cmd) { Get-Command $cmd -EA SilentlyContinue }
function Section ($msg)    { Write-Host "`n─── $msg ───" -ForegroundColor Cyan }

$ErrorActionPreference = 'Stop'        # die on first error
$repoURL  = 'https://github.com/BiodataAnalysisGroup/virtual-tutorial-perturbation-modelling.git'
$dataURL  = 'https://zenodo.org/records/15745452/files/zenodo_perturbations_ECCB2025.zip?download=1'
$dataZip  = 'zenodo_perturbations_ECCB2025.zip'
$repoDir  = 'virtual-tutorial-perturbation-modelling'

$mambaRoot = "$env:USERPROFILE\micromamba"           # C:\Users\<you>\micromamba
$mambaExe  = "$mambaRoot\micromamba.exe"
$envScgen  = 'scgen'
$envScpram = 'scpram'

#────────────────────────────────────────────────────────────────────
Section '1) Install Git (winget, if missing)'
if (-not (Has-Command git)) {
    if (-not (Has-Command winget)) {
        throw "Winget not found ⇒ please install Git manually from https://git-scm.com and re-run."
    }
    winget install --id Git.Git -e --source winget `
        --accept-package-agreements --accept-source-agreements
    $env:Path += ";$([Environment]::GetEnvironmentVariable('ProgramFiles') + '\Git\cmd')"
}
Write-Host "Git ✔️  $((git --version) -join ' ')"

#────────────────────────────────────────────────────────────────────
Section '2) Clone tutorial repository'
if (-not (Test-Path $repoDir)) { git clone $repoURL }
Set-Location $repoDir

#────────────────────────────────────────────────────────────────────
Section '3) Download & extract data (≈850 MB)'
New-Item -ItemType Directory -Path .\data -Force | Out-Null
Invoke-WebRequest $dataURL -OutFile ".\data\$dataZip"

$temp = ".\data\_tmp_zip"
Expand-Archive ".\data\$dataZip" -DestinationPath $temp -Force
Move-Item "$temp\zenodo_perturbations_ECCB2025\*" .\data -Force
Remove-Item $temp, ".\data\$dataZip" -Recurse -Force
Remove-Item ".\data\__MACOSX" -Recurse -Force -EA SilentlyContinue
Write-Host "Data extracted to  .\data ✔️"

#────────────────────────────────────────────────────────────────────
Section '4) Install micromamba (static binary, 5 MB)'
if (-not (Test-Path $mambaExe)) {
    New-Item -ItemType Directory -Path $mambaRoot -Force | Out-Null
    $archURL = 'https://micro.mamba.pm/api/micromamba/win-64/latest'
    Invoke-WebRequest $archURL -OutFile "$mambaRoot\micromamba.tar.bz2"
    # extract micromamba.exe from tar.bz2  (PowerShell ≥5 supports –J & –x):
    tar -xvjf "$mambaRoot\micromamba.tar.bz2" -C $mambaRoot micromamba.exe
    Remove-Item "$mambaRoot\micromamba.tar.bz2"
}
# add to current PATH
$env:Path += ";$mambaRoot"

# initialise PowerShell hook (creates $PROFILE entry if needed)
& $mambaExe shell init -s powershell -p $mambaRoot | Out-Null
# load the hook now (so mamba activate works inside this script)
. ([Environment]::GetEnvironmentVariable('MICROMAMBA_ROOT', 'User') + '\etc\profile.d\micromamba_hook.ps1')

Write-Host "micromamba ✔️  $(& micromamba --version)"

#────────────────────────────────────────────────────────────────────
Section '5) Create tutorial environments (fast!)'
micromamba env create -f envs\environment_scgen.yml   -y
micromamba env create -f envs\environment_scpram.yml  -y
Write-Host "Environments  $envScgen  &  $envScpram  created ✔️"

#────────────────────────────────────────────────────────────────────
Section '6) Launch Jupyter?'
$launch = Read-Host "Open JupyterLab now?  (Y/N)"
if ($launch -match '^[Yy]') {
    micromamba activate $envScgen
    Start-Process jupyter-lab
    Write-Host "`nJupyterLab opened in default browser."
    Write-Host "When finished, close the Lab tab, return here and press  Ctrl+C  to exit."
    Wait-Process -Name "jupyter-lab" -EA SilentlyContinue
}
else {
    Write-Host "`nDone!  Later you can:"
    Write-Host "  micromamba activate $envScgen  &&  jupyter-lab"
    Write-Host "or"
    Write-Host "  micromamba activate $envScpram &&  jupyter-lab"
}

#────────────────────────────────────────────────────────────────────
Write-Host "`n🎉  Tutorial installation complete – happy analysing!" -ForegroundColor Green