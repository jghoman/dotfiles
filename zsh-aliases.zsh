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
alias jx="uvx justx"
alias calcure="uvx calcure"

inpane() {
  local chan="inpane-$$-$RANDOM"
  local current_pane=$(tmux display-message -p '#{pane_id}')
  local pane_count=$(tmux list-panes | wc -l | tr -d ' ')
  if [ "$pane_count" -eq 1 ]; then
    tmux split-window -h "$*; tmux wait-for -S $chan"
  else
    tmux split-window -v -t '{right}' "$*; tmux wait-for -S $chan"
  fi
  tmux select-pane -t "$current_pane"
  { tmux wait-for $chan; sleep 0.1; tmux select-pane -t "$current_pane"; } &!
}

newsrc() {
  if tmux list-windows -F "#{window_name}" | grep -qx "$1"; then
    tmux select-window -t "=$1"
    return
  fi
  tmux new-window -n "$1" -c "$HOME/src/$1"
}
