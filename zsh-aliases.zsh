alias b="bat --theme=\$(defaults read -globalDomain AppleInterfaceStyle &> /dev/null && echo default || echo GitHub)"
alias spell="just --justfile=justfile"

alias br="broot"
alias c="clear"
alias e="eza --icons=always --group-directories-first"
alias l="eza --long --icons=always --group-directories-first"
alias ls="eza --icons=always --group-directories-first"

alias gb="git checkout -b"
alias gc="git commit"
alias gco="git checkout"

alias j="just"
alias calcure="uvx calcure"

newsrc() {
  if tmux list-windows -F "#{window_name}" | grep -qx "$1"; then
    tmux select-window -t "=$1"
    return
  fi
  tmux new-window -n "$1" -c "$HOME/src/$1"
}
