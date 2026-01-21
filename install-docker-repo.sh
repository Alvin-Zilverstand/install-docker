#!/usr/bin/env bash
set -e

# Ensure script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script as root (use sudo)"
  exit 1
fi

# Detect the non-root user (important when running via sudo)
REAL_USER="${SUDO_USER:-$USER}"

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

echo "[+] Installing Docker Engine and plugins..."
apt install -y \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin

echo "[+] Enabling Docker service..."
systemctl enable docker
systemctl start docker

echo "[+] Adding user '${REAL_USER}' to docker group..."
usermod -aG docker "${REAL_USER}"

echo
echo "[✓] Docker installation complete."
echo
echo "⚠️  IMPORTANT:"
echo "You must log out and log back in for docker group changes to take effect."
echo "Alternatively, run: newgrp docker"
