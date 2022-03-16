#
# Executes commands at the start of an interactive session.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# Customize to your needs...

fpath=(path/to/zsh-completions/src $fpath)

autoload -Uz compinit
compinit

function peco-history-selection() {
  BUFFER=$(history 1 | sort -k1,1nr | perl -ne 'BEGIN { my @lines = (); } s/^\s*\d+\*?\s*//; $in=$_; if (!(grep {$in eq $_} @lines)) { push(@lines, $in); print $in; }' | peco --query "$LBUFFER")
  CURSOR=${#BUFFER}
  zle reset-prompt
}
zle -N peco-history-selection
bindkey '^R' peco-history-selection

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# z
. $(brew --prefix)/etc/profile.d/z.sh

# -------
# alias
# -------
alias pr="gh pr list | peco | xargs gh pr view"
alias sw="git branch | peco | xargs git switch"
alias rebase-develop="git switch develop; git pull upstream develop --ff-only; git switch - ;git rebase develop"
alias rebase-i='git log --oneline --color | fzf --ansi --reverse | cut -d " " -f 1 | xargs git rebase -i'
alias delete-branch="git branch --merged | egrep -v '\*|develop|master' | xargs git branch -d"
alias code="code-insiders"

source <(kubectl completion zsh)
export GOPATH=${HOME}/go
export GO111MODULE=on
export PATH=$PATH:$(npm bin -g)
export GOENV_ROOT=$HOME/.goenv
export PATH=$GOENV_ROOT/bin:$PATH
export PATH=$GOPATH/bin:$PATH
export GOENV_DISABLE_GOPATH=1
eval "$(goenv init -)"
eval "$(rbenv init -)"

zstyle ':prezto:load' pmodule \
  'environment' \
  'terminal' \
  'editor' \
  'history' \
  'directory' \
  'spectrum' \
  'utility' \
  'syntax-highlighting' \
  'completion' \
  'prompt' \
  'history-substring-search' \
  'autosuggestions'

zstyle ':prezto:module:editor' key-bindings 'vi'
zstyle ':prezto:module:prompt' theme 'pure'

export PATH="/usr/local/opt/mysql@5.7/bin:$PATH"
export PATH=/Users/satoyu/.local/bin:$PATH

alias c='clear'

export NVM_DIR="$HOME/.nvm"
[ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh"                                       # This loads nvm
[ -s "/usr/local/opt/nvm/etc/bash_completion.d/nvm" ] && . "/usr/local/opt/nvm/etc/bash_completion.d/nvm" # This loads nvm bash_completion

# for gcloud
source "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc"
source "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc"
export PATH="/usr/local/opt/openssl@1.1/bin:$PATH"
[ -f "/Users/satoyu/.ghcup/env" ] && source "/Users/satoyu/.ghcup/env" # ghcup-env
