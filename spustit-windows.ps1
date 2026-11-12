# === IPTV Easy-Setup - spousteni na Windows (Docker Desktop) ===
# Precte hardwarove ID pocitace (MachineGuid) a preda ho kontejneru,
# aby se licence spravne navazala na tento stroj.
#
# Pouziti: pravy klik na soubor -> "Run with PowerShell"
#          (nebo v PowerShellu:  .\spustit-windows.ps1)

$ErrorActionPreference = "Stop"

# Jazyk rozhrani: "CZ" nebo "EN"
$APP_LANG = "EN"

# Hardwarove ID z registru Windows
$hwid = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Cryptography').MachineGuid

if (-not $hwid) {
    Write-Host "CHYBA: nepodarilo se zjistit MachineGuid." -ForegroundColor Red
    exit 1
}

# Smazat predchozi kontejner, pokud existuje (kvuli opakovanemu spusteni)
docker rm -f iptv-easy-setup 2>$null | Out-Null

docker run -d --name iptv-easy-setup --restart always `
  -p 5660:5660 -v iptv-easy-data:/DATA `
  -e DATA_ROOT=/DATA -e APP_LANG=$APP_LANG -e IES_HOST_HWID=$hwid `
  iptveasysetup/iptv-easy-setup:latest

Write-Host ""
Write-Host "Hotovo! Webove rozhrani: http://localhost:5660" -ForegroundColor Green
