# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="agnosterzak"

plugins=( 
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh


# Display Pokemon-colorscripts
# Project page: https://gitlab.com/phoneybadger/pokemon-colorscripts#on-other-distros-and-macos
#pokemon-colorscripts --no-title -s -r #without fastfetch
#pokemon-colorscripts --no-title -s -r | fastfetch -c $HOME/.config/fastfetch/config-pokemon.jsonc --logo-type file-raw --logo-height 10 --logo-width 5 --logo -

# fastfetch. Will be disabled if above colorscript was chosen to install
fastfetch -c $HOME/.config/fastfetch/config-compact.jsonc

# Set-up icons for files/directories in terminal using lsd
alias ls='lsd'
alias l='ls -l'
alias la='ls -a'
alias lla='ls -la'
alias lt='ls --tree'



# ==============================================================================
# GLOBAL EXECUTION PATHS & ENVIRONMENT
# ==============================================================================
export PATH="$HOME/.local/bin:/usr/games:$PATH"
export EDITOR="nvim"

# Load Cargo / Rust Environment
[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"

# Terminal Interrupt Mapping
stty intr '^\'
stty quit '^]'

# ==============================================================================
# INDUSTRIAL HARDENED WORKFLOW SHORTCUTS
# ==============================================================================

# 1. Bluetooth Infrastructure Control
alias blueon='sudo systemctl start bluetooth.service && sudo rfkill unblock bluetooth && echo "[✓] Bluetooth hardware stack initialized."'
alias blueoff='sudo rfkill block bluetooth && sudo systemctl stop bluetooth.service 2>/dev/null && echo "[✗] Bluetooth system service killed and radio module suspended."'

# 2. Advanced Compute Container & Virtual Network Teardown
alias dockeron='sudo systemctl start docker.socket docker && echo "[✓] Docker daemon infrastructure online."'
alias dockeroff='
if systemctl is-active --quiet docker; then
    CONTAINERS=$(docker ps -q 2>/dev/null)
    if [ -n "$CONTAINERS" ]; then
        echo "Terminating active container workloads..."
        sudo docker stop $CONTAINERS >/dev/null 2>&1
    fi
    if command -v docker-compose &>/dev/null; then
        sudo docker-compose down --remove-orphans 2>/dev/null
    fi
    echo "Stopping core container infrastructure..."
    sudo systemctl stop docker.socket docker 2>/dev/null
    if ip link show docker0 &>/dev/null; then
        sudo ip link set dev docker0 down 2>/dev/null
        sudo ip link delete docker0 2>/dev/null
    fi
    echo "[✗] All container runtimes cleared and virtual networks destroyed."
else
    echo "[-] Docker is already completely inactive."
fi'

# ==============================================================================
# THE GARAGE UNDERGROUND DUNGEON COMPUTE CONTROLS
# ==============================================================================

# 1. Conda Environment Activation
CONDA_SH_PATH="$HOME/.miniconda3/etc/profile.d/conda.sh"

alias garage='
if [ -f "$CONDA_SH_PATH" ]; then
    source "$CONDA_SH_PATH"
    conda activate Sublevel-B10
    echo "[⚡️] Booger Aids V2 is ONLINE. Structural data, matrix arrays, and physics modules fully loaded."
else
    echo "[✗] Error: Conda core path missing in home partition."
fi'

alias reese='
if command -v conda &>/dev/null; then
    conda deactivate 2>/dev/null
fi
echo "[🌌] Environment suspended. Returning shell to standard dimension."'

# 2. OpenFOAM Dictionaries Activation
alias foam="source \$HOME/OpenFOAM/OpenFOAM-v2512/etc/bashrc && export PATH=\$PATH:/home/karahanli/OpenFOAM/cfMesh-1.2.0/Mesher/bin:/home/karahanli/OpenFOAM/cfMesh-1.2.0/Application" 

# 3. Dedicated Odysseus Instance Control & Health Validation
alias ody='
if ! systemctl is-active --quiet docker; then
    echo "[!] Docker daemon is offline. Initializing engine..."
    sudo systemctl start docker.socket docker
fi
echo "[🚀] Launching Odysseus container stack..."
(cd ~/odysseus && sudo docker compose up -d)

echo -n "[⏳] Waiting for Odysseus web server to stabilize..."
until sudo docker exec odysseus-odysseus-1 python -c "import urllib.request; urllib.request.urlopen(\"http://localhost:7000/api/version\", timeout=2)" >/dev/null 2>&1; do
    echo -n "."
    sleep 1
done
echo ""
echo "[✓] Odysseus core is completely online! Interface ready at http://localhost:7000"'

# ==============================================================================
# MISCELLANEOUS MISCHIEF & TOOLS
# ==============================================================================
alias hollywood='docker run -it --rm --init cgr.dev/chainguard/hollywood'
alias zzz='sudo systemctl suspend'
alias blender='~/blender/blender &'
alias agy='$HOME/.local/bin/agy'

# code_saturne CLI alias
alias saturne="$HOME/code-saturne-edf/install/bin/code_saturne"

# Enable automatic bash/zsh command completion support
source $HOME/code-saturne-edf/install/etc/bash_completion.d/code_saturne 2>/dev/null || true

# cfMesh-1.2.0 configuration
export PATH="$PATH:/home/karahanli/OpenFOAM/cfMesh-1.2.0/Mesher/bin:/home/karahanli/OpenFOAM/cfMesh-1.2.0/Application"

# ==============================================================================
# KEYBOARD NAVIGATION, EDITING, & DELETION BINDS
# ==============================================================================
# Standard arrow keys history navigation & cursor movement (Normal & Application modes)
bindkey '^[[A' up-history
bindkey '^[OA' up-history
bindkey '^[[B' down-history
bindkey '^[OB' down-history
bindkey '^[[C' forward-char
bindkey '^[OC' forward-char
bindkey '^[[D' backward-char
bindkey '^[OD' backward-char

# Ctrl+Left / Ctrl+Right to move cursor word-by-word
bindkey '^[[1;5D' backward-word
bindkey '^[[1;5C' forward-word

# Word deletion shortcuts
bindkey '^H' backward-kill-word          # Ctrl+Backspace
bindkey '^[^?' backward-kill-word        # Alt+Backspace
bindkey '^[[3;5~' kill-word              # Ctrl+Delete
bindkey '^[[3~' delete-char              # Normal Delete
