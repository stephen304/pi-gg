#!/usr/bin/env bash

# Exit on error
set -e

# Check for superuser
if [ $EUID != 0 ]; then
    echo "Please run this script in an elevated shell."
    echo "Example: su -c \"curl -sSL https://raw.githubusercontent.com/stephen304/pi-gg/master/bootstrap.sh | bash\""
    exit $?
fi

# Packages
echo -e "\e[1m\e[32m==>\e[0m Bootstrapping Pacman"
echo -e "  \e[1m\e[34m->\e[0m Init..."
pacman-key --init >/dev/null 2>&1
echo -e "  \e[1m\e[34m->\e[0m Populate..."
pacman-key --populate archlinuxarm >/dev/null 2>&1
echo -e "\e[1m\e[32m==>\e[0m Installing Packages"
echo -e "  \e[1m\e[34m->\e[0m Updates..."
pacman -Syu --noconfirm >/dev/null 2>&1
echo -e "  \e[1m\e[34m->\e[0m Essentials..."
pacman -S --noconfirm --needed git go base-devel zsh grml-zsh-config rxvt-unicode-terminfo >/dev/null 2>&1

# System
echo -e "\e[1m\e[32m==>\e[0m Configuring System"
echo -e "  \e[1m\e[34m->\e[0m Setting default shell..."
useradd -D -s /bin/zsh >/dev/null
chsh -s /bin/zsh root >/dev/null
if id massmesh >/dev/null 2>&1; then
    echo -e "  \e[1m\e[34m->\e[0m Using existing user 'massmesh'..."
else
    echo -e "  \e[1m\e[34m->\e[0m Creating user 'massmesh'..."
    useradd -m massmesh >/dev/null
fi

# Mesh
echo -e "\e[1m\e[32m==>\e[0m Installing Yggdrasil"
echo -e "  \e[1m\e[34m->\e[0m Compiling..."
# this works but it's weird
sudo -u massmesh -s -- <<EOF >/dev/null 2>&1
git clone https://aur.archlinux.org/yggdrasil-git.git /tmp/build/ygg/
cd /tmp/build/ygg
makepkg
EOF
echo -e "  \e[1m\e[34m->\e[0m Installing..."
pacman -U --noconfirm /tmp/build/ygg/*.pkg.tar.xz >/dev/null

echo -e "\e[1m\e[32m==>\e[0m Enabling Services"
echo -e "  \e[1m\e[34m->\e[0m yggdrasil.service..."
systemctl enable yggdrasil.service >/dev/null 2>&1
