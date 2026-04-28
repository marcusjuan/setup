#!/bin/bash
set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "starting config..."

# -------- CLI SETUP --------
echo "setting global command 'dot'..."

mkdir -p "$HOME/.local/bin"

if [ ! -f "$HOME/.local/bin/dot" ]; then
    ln -s "$REPO_DIR/bin/dot" "$HOME/.local/bin/dot"
    chmod +x "$REPO_DIR/bin/dot"
    echo "'dot' command set."
fi

COMPLETION_DIR="$HOME/.config/dotfiles"
COMPLETION_FILE="$COMPLETION_DIR/dot-completion.sh"

mkdir -p "$COMPLETION_DIR"

cat > "$COMPLETION_FILE" << 'EOF'
_dot_completion() {
    local cur

    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"

    COMPREPLY=( $(compgen -W "install update upload" -- "$cur") )
}

complete -F _dot_completion dot
EOF

chmod 644 "$COMPLETION_FILE"

if ! grep -q "dot-completion.sh" "$HOME/.bashrc"; then
    echo "source $COMPLETION_FILE" >> "$HOME/.bashrc"
    echo " Autocomplete added to .bashrc"
fi

# -------- DCONF --------
echo "setting dconf..."

[ -f "$REPO_DIR/dconf/interface.ini" ] && \
dconf load /org/gnome/desktop/interface/ < "$REPO_DIR/dconf/interface.ini"

[ -f "$REPO_DIR/dconf/wm.ini" ] && \
dconf load /org/gnome/desktop/wm/preferences/ < "$REPO_DIR/dconf/wm.ini"
echo "interface set."

echo "reseting dock..."

dconf reset /org/gnome/shell/favorite-apps

echo "applaing new dock..."

dconf load /org/gnome/shell/ < "$REPO_DIR/dconf/shell.ini"


# keybinds
# reseting original keybinds to overwrite mine
echo "reseting keybinds..."
dconf reset -f /org/gnome/settings-daemon/plugins/media-keys/
dconf reset -f /org/gnome/desktop/wm/keybindings/
echo "done."

# setting my keybinds
[ -f "$REPO_DIR/dconf/keybindings.ini" ] && \
dconf load /org/gnome/settings-daemon/plugins/media-keys/ < "$REPO_DIR/dconf/keybindings.ini"
dconf load /org/gnome/desktop/wm/keybindings/ < "$REPO_DIR/dconf/wm-keybindings.ini"
echo "keybinds set."


# terminal reset
echo "reseting terminal..."
dconf reset -f /org/gnome/terminal/

[ -f "$REPO_DIR/dconf/terminal.ini" ] && \
dconf load /org/gnome/terminal/ < "$REPO_DIR/dconf/terminal.ini"
echo "GNOME terminal set."

[ -f "$REPO_DIR/dconf/mouse.ini" ] && \
dconf load /org/gnome/desktop/peripherals/mouse/ < "$REPO_DIR/dconf/mouse.ini"

[ -f "$REPO_DIR/dconf/touchpad.ini" ] && \
dconf load /org/gnome/desktop/peripherals/touchpad/ < "$REPO_DIR/dconf/touchpad.ini"
echo "mouse set."




echo "dconf done."

echo "setting vscode"

# ------- FIREFOX --------

echo "setting firefox..."
FIREFOX_DIR="$HOME/.mozilla/firefox"
PROFILE=$(find "$FIREFOX_DIR" -maxdepth 1 -type d -name "*.default-release" | head -n 1)

if [ -n "$PROFILE" ]; then
    cp "$REPO_DIR/firefox/user.js" "$PROFILE/" 2>/dev/null || true

    echo "installing language-packs"
    EXT_DIR="$PROFILE/extensions"
    mkdir -p "$EXT_DIR"

    cp "$REPO_DIR/firefox/extensions/"*.xpi "$EXT_DIR/" 2>/dev/null || true
    

fi


echo "firefox set."

# --------- DEFAULT APPS ---------
mkdir -p "$HOME/.config"

cp "$REPO_DIR/mime/mimeapps.list" "$HOME/.config/" 2>/dev/null || true
echo "default apps done."

# -------- VSCODE --------
VSCODE_DIR="$HOME/.config/Code/User"

if [ -d "$HOME/.config/Code" ]; then
    mkdir -p "$VSCODE_DIR"


    cp "$REPO_DIR/vscode/keybindings.json" "$VSCODE_DIR/" 2>/dev/null || true
    echo "keybinds set."

    cp "$REPO_DIR/vscode/settings.json" "$VSCODE_DIR/" 2>/dev/null || true
    echo "user settings set."
fi

echo "vscode done."

# -------- PROJECTS --------
if [ ! -d "$HOME/projetos/" ]; then
    PROJECTS_FOLDER="$HOME/projetos"
    mkdir -p "$PROJECTS_FOLDER"

    GITHUB_REPO="https://github.com/marcusjuan"
    echo -n "clonning projetos_ip..."
    git clone "$GITHUB_REPO"/projetos_ip.git "$PROJECTS_FOLDER"/projetos_ip
    echo "done."

fi



# garantir PATH
if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
    echo "PATH updated (reload the terminal)"
else
    echo "perhaps the machine needs to logout/login"
fi
