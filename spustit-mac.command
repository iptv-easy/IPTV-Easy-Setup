#!/bin/bash
# === IPTV Easy-Setup - spousteni na macOS (Docker Desktop) ===
# Precte hardwarove ID pocitace (IOPlatformUUID) a preda ho kontejneru,
# aby se licence spravne navazala na tento stroj.
#
# Pouziti: dvojklik na soubor (poprve muze byt nutne povolit v
#          Nastaveni -> Soukromi a zabezpeceni), nebo v Terminalu:
#          chmod +x spustit-mac.command && ./spustit-mac.command

set -e

# Jazyk rozhrani: "CZ" nebo "EN"
APP_LANG="EN"

# Hardwarove ID z IORegistry
HWID=$(ioreg -rd1 -c IOPlatformExpertDevice | awk -F'"' '/IOPlatformUUID/{print $4}')

if [ -z "$HWID" ]; then
  echo "CHYBA: nepodarilo se zjistit IOPlatformUUID."
  exit 1
fi

# Smazat predchozi kontejner, pokud existuje (kvuli opakovanemu spusteni)
docker rm -f iptv-easy-setup 2>/dev/null || true

docker run -d --name iptv-easy-setup --restart always \
  -p 5660:5660 -v iptv-easy-data:/DATA \
  -e DATA_ROOT=/DATA -e APP_LANG="$APP_LANG" -e IES_HOST_HWID="$HWID" \
  iptveasysetup/iptv-easy-setup:latest

echo ""
echo "Hotovo! Webove rozhrani: http://localhost:5660"
