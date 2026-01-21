#!/usr/bin/env bash
set -e

# Ensure script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script as root (use sudo)"
  exit 1
fi

echo "[+] Updating apt and installing dependencies..."
apt update
apt install -y ca-certificates curl

echo "[+] Creating keyrings directory..."
install -m 0755 -d /etc/apt/keyrings

echo "[+] Downloading Docker GPG key..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

echo "[+] Adding Docker APT repository..."
CODENAME="$(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")"

cat > /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: ${CODENAME}
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

echo "[+] Updating apt repositories..."
apt update

echo "[✓] Docker repository setup complete."
