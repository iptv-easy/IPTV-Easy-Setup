#!/bin/bash
# IPTV Easy-Setup – odinstalace
# Použití:
#   curl -sSL https://raw.githubusercontent.com/iptv-easy/IPTV-Easy-Setup/main/uninstall.sh | bash
#
# Zastaví a odstraní kontejner i stažený obraz. Data ve složce /DATA
# (nastavení, playlisty, aktivovaná licence) ve výchozím stavu PONECHÁ –
# na jejich smazání se zeptá.

set -e
IMAGE="ghcr.io/iptv-easy/iptv-easy-setup"

cat << "EOF"
--------------------------------------------------------------------------------
 IPTV Easy-Setup  –  odinstalace / uninstall
--------------------------------------------------------------------------------
EOF

# Jazyk / language
echo "Vyberte jazyk / Choose your language:"
echo "1) Cesky"
echo "2) English"
read -p "Volba / Option [1 = Cesky -- 2 = English]: " JAZYK_VOLBA < /dev/tty
if [ "$JAZYK_VOLBA" == "2" ]; then APP_LANG="EN"; else APP_LANG="CZ"; fi

if ! [ -x "$(command -v docker)" ]; then
    [ "$APP_LANG" == "CZ" ] && echo "Docker nenalezen – zdá se, že program není nainstalovaný." \
                            || echo "Docker not found – the program does not seem to be installed."
    exit 0
fi

# 1. Zastaveni a odstraneni kontejneru
[ "$APP_LANG" == "CZ" ] && echo "Zastavuji a odstranuji kontejner..." || echo "Stopping and removing the container..."
sudo docker rm -f iptv-easy-setup 2>/dev/null || true

# 2. Odstraneni obrazu
[ "$APP_LANG" == "CZ" ] && echo "Odstranuji stazeny obraz..." || echo "Removing the downloaded image..."
sudo docker rmi "$IMAGE:latest" 2>/dev/null || true
# pro jistotu i pripadne verzovane tagy
for img in $(sudo docker images "$IMAGE" -q 2>/dev/null | sort -u); do
    sudo docker rmi -f "$img" 2>/dev/null || true
done

# 3. Data (volitelne)
echo
if [ "$APP_LANG" == "CZ" ]; then
    echo "Chcete smazat i data ve slozce /DATA (nastaveni, playlisty, licence)?"
    echo "POZOR: smazani je nevratne. Pokud budete chtit program pozdeji znovu"
    echo "pouzivat, data i aktivaci si ponechte."
    read -p "Smazat /DATA? [a = ano -- N = ne, ponechat] (vychozi: N): " SMAZAT < /dev/tty
else
    echo "Do you also want to delete the data in /DATA (settings, playlists, license)?"
    echo "WARNING: this is irreversible. Keep it if you might reinstall later."
    read -p "Delete /DATA? [y = yes -- N = no, keep] (default: N): " SMAZAT < /dev/tty
fi

case "$SMAZAT" in
    a|A|y|Y)
        sudo rm -rf /DATA
        [ "$APP_LANG" == "CZ" ] && echo "Slozka /DATA smazana." || echo "/DATA deleted."
        ;;
    *)
        [ "$APP_LANG" == "CZ" ] && echo "Slozka /DATA ponechana." || echo "/DATA kept."
        ;;
esac

echo "--------------------------------------------------------------------------------"
[ "$APP_LANG" == "CZ" ] && echo "Odinstalace dokoncena. Docker zustava nainstalovany." \
                        || echo "Uninstall complete. Docker itself was left installed."
echo "--------------------------------------------------------------------------------"
