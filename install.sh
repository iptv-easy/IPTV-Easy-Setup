#!/bin/bash
# IPTV Easy-Setup – instalátor (hotový obraz z GitHub Container Registry)
# Použití:
#   curl -sSL https://raw.githubusercontent.com/iptv-easy/IPTV-Easy-Setup/main/install.sh | bash
#
# Na rozdíl od staré verze NESTAHUJE zdrojové soubory ani nesestavuje obraz
# u uživatele – jen stáhne hotový obraz z ghcr.io a spustí ho.

set -e
IMAGE="ghcr.io/iptv-easy/iptv-easy-setup:latest"

cat << "EOF"
--------------------------------------------------------------------------------
 IPTV Easy-Setup  –  instalace
--------------------------------------------------------------------------------
EOF

# 1. Volba jazyka
echo "Vyberte jazyk / Choose your language:"
echo "1) Cesky"
echo "2) English"
read -p "Volba / Option [1 = Cesky -- 2 = English]: " JAZYK_VOLBA < /dev/tty
if [ "$JAZYK_VOLBA" == "2" ]; then APP_LANG="EN"; else APP_LANG="CZ"; fi

# 2. Docker
if ! [ -x "$(command -v docker)" ]; then
    [ "$APP_LANG" == "CZ" ] && echo "Docker nenalezen, instaluji..." || echo "Docker not found, installing..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo systemctl enable --now docker
else
    [ "$APP_LANG" == "CZ" ] && echo "Docker je pripraven." || echo "Docker is ready."
fi

# 3. Slozka pro data
sudo mkdir -p /DATA
sudo chmod -R 777 /DATA

# 4. Stazeni a spusteni
[ "$APP_LANG" == "CZ" ] && echo "Stahuji nejnovejsi obraz..." || echo "Pulling latest image..."
sudo docker pull "$IMAGE"

sudo docker stop iptv-easy-setup 2>/dev/null || true
sudo docker rm iptv-easy-setup 2>/dev/null || true

# HWID pro licenci (jen pro cteni) – kdyby soubor neexistoval, Docker by
# misto nej vytvoril prazdnou slozku, proto podminka.
MACHINE_ID_MOUNT=""
if [ -f /etc/machine-id ]; then
  MACHINE_ID_MOUNT="-v /etc/machine-id:/etc/host-machine-id:ro"
fi

[ "$APP_LANG" == "CZ" ] && echo "Spoustim aplikaci na portu 5660..." || echo "Starting application on port 5660..."
sudo docker run -d \
  --name iptv-easy-setup \
  --restart always \
  -p 5660:5660 \
  -v /DATA:/DATA \
  -v /etc/localtime:/etc/localtime:ro \
  $MACHINE_ID_MOUNT \
  -e DATA_ROOT="/DATA" \
  -e APP_LANG="$APP_LANG" \
  "$IMAGE"

IP_ADRESA=$(hostname -I | awk '{print $1}')
echo "--------------------------------------------------------------------------------"
if [ "$APP_LANG" == "CZ" ]; then
    echo "HOTOVO!  Webove rozhrani:  http://$IP_ADRESA:5660"
    echo "Ochrana: 10 dni zkusebni verze, pote vyzadovana aktivace."
    echo "Aktualizace:  curl -sSL https://raw.githubusercontent.com/iptv-easy/IPTV-Easy-Setup/main/install.sh | bash"
else
    echo "DONE!  Web interface:  http://$IP_ADRESA:5660"
    echo "Protection: 10-day trial, then activation required."
    echo "Update:  curl -sSL https://raw.githubusercontent.com/iptv-easy/IPTV-Easy-Setup/main/install.sh | bash"
fi
echo "--------------------------------------------------------------------------------"
