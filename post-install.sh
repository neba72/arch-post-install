#!/usr/bin/env bash

# Zaustavi izvršavanje ako dođe do greške
set -e

echo "=== Arch Linux Post-Installation Script ==="
echo ""

# 1. Osigurati da nismo root korisnik (AUR pomoćnici poput yay ne smiju raditi kao root)
if [ "$EUID" -eq 0 ]; then
  echo "[-] Nemojte pokretati ovu skriptu kao root/sudo direktno."
  echo "    Pokrenite je kao običan korisnik. Skripta će sama tražiti sudo kada zatreba."
  exit 1
fi

# 2. Definisanje liste oficijelnih Arch paketa (pacman)
# ---> Dodajte ili izbacite pakete po vašoj želji <---
PACMAN_PKGS=(
    # Osnovni sistemski alati
    git
    curl
    wget
    fastfetch
    htop
    unzip
    zip
    
    # Grafičko okruženje / Display Manager (Primjer: Hyprland / KDE / XFCE - otkomentarišite po izboru)
    # xorg-server
    # sddm
    
    # Mreža i Zvuk
    networkmanager
    pipewire
    pipewire-pulse
    pipewire-alsa
    wireplumber
    
    # Aplikacije i Radno okruženje
    kitty               # Terminal
    firefox             # Web preglednik
    neovim              # Tekstualni editor
    vlc                 # Media player
    thunar              # Fajl menadžer
    ttf-jet-brains-mono # Fontovi
)

# 3. Definisanje liste AUR paketa (yay)
# ---> Dodajte ili izbacite AUR pakete po želji <---
AUR_PKGS=(
    visual-studio-code-bin
    spotify
    brave-bin
)

# 4. Ažuriranje sistema
echo "[+] Ažuriranje baze podataka i postojećih paketa..."
sudo pacman -Syu --noconfirm

# 5. Instalacija baznih alata za izgradnju paketa (base-devel i git)
echo "[+] Provjera i instalacija 'base-devel' i 'git'..."
sudo pacman -S --needed --noconfirm base-devel git

# 6. Instalacija oficijelnih paketa
echo "[+] Instalacija odabranih Pacman paketa..."
sudo pacman -S --needed --noconfirm "${PACMAN_PKGS[@]}"

# 7. Instalacija yay (AUR pomoćnika) ako već nije instaliran
if ! command -v yay &> /dev/null; then
    echo "[+] 'yay' nije pronađen. Započinjem instalaciju yay-a iz AUR-a..."
    BUILD_DIR=$(mktemp -d)
    git clone https://aur.archlinux.org/yay.git "$BUILD_DIR/yay"
    cd "$BUILD_DIR/yay"
    makepkg -si --noconfirm
    cd ~
    rm -rf "$BUILD_DIR"
else
    echo "[+] 'yay' je već instaliran."
fi

# 8. Instalacija AUR paketa
if [ ${#AUR_PKGS[@]} -gt 0 ]; then
    echo "[+] Instalacija odabranih AUR paketa putem yay-a..."
    yay -S --needed --noconfirm "${AUR_PKGS[@]}"
fi

# 9. Omogućavanje i pokretanje ključnih sistemskih servisa
echo "[+] Omogućavanje sistemskih servisa..."
sudo systemctl enable --now NetworkManager.service
sudo systemctl enable --now PipeWire.service 2>/dev/null || true

echo ""
echo "=== Instalacija je uspješno završena! ==="
echo "Preporučuje se da ponovo pokrenete sistem (reboot)."
