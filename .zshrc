# ============================================================
#  ZSHRC — Configuration du shell
# ============================================================

# ---- Prompt -----------------------------------------------
# oh-my-posh : prompt personnalisé avec icônes et infos git
# Changer de thème : https://ohmyposh.dev/docs/themes
eval "$(oh-my-posh init zsh)"

# ---- Historique -------------------------------------------
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_DUPS      # ignore les doublons consécutifs
setopt HIST_IGNORE_ALL_DUPS  # supprime les anciens doublons
setopt SHARE_HISTORY         # partage l'historique entre tous les terminaux ouverts

# ---- Complétion -------------------------------------------
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'  # insensible à la casse

# ---- Navigation -------------------------------------------
# jump : aller rapidement vers un dossier déjà visité — usage : j <nom>
eval "$(jump shell)"

# ---- Aliases ----------------------------------------------
alias nv='nvim'
alias cl='clear'
alias bat='bat --paging=never'   # cat avec coloration syntaxique

# ls → eza si installé (icônes + git status), sinon ls classique
# Pour installer : brew install eza
# Couleurs identiques au ls macOS classique
export EZA_COLORS="di=94:ln=96:ex=92:fi=0:pi=33:so=95:bd=33:cd=33:or=91"
if command -v eza &>/dev/null; then
  alias ls='eza --icons'
  alias l='eza -l --icons'
  alias la='eza -la --icons'
  alias ll='eza -la --icons --git'   # liste détaillée avec statut git
  alias tree='eza --tree --icons'    # arbre de dossiers
else
  alias l='ls -lA'
  alias la='ls -A'
  alias ll='ls -alF'
fi

# ---- Go ---------------------------------------------------
export GOPATH="$HOME/go"
export PATH="$GOPATH/bin:$PATH"

# ---- Java -------------------------------------------------
export JAVA_HOME=/opt/homebrew/opt/openjdk@11/libexec/openjdk.jdk/Contents/Home

# ---- NVM (Node Version Manager) ---------------------------
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"

# ---- Plugins zsh ------------------------------------------
# Coloration syntaxique des commandes (toujours en dernier)
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Suggestions basées sur l'historique — taper → pour accepter
# Pour installer : brew install zsh-autosuggestions
[ -f /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ] && \
  source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
