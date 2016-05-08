# random time savers
alias fucking "sudo"
alias gcm "git checkout master"
alias gco "git checkout"
alias gp "git pull"
alias gl "git lg"
alias gca "git commit -a"
alias gpom "git push origin master"
alias gcdf "git clean -d -f"
alias gd "git diff --no-prefix"

alias gti git

set normal (set_color normal)
set magenta (set_color magenta)
set yellow (set_color yellow)
set green (set_color green)
set red (set_color red)
set gray (set_color -o black)

# Fish git prompt stuff
set __fish_git_prompt_showdirtystate 'yes'
set __fish_git_prompt_showstashstate 'yes'
set __fish_git_prompt_showuntrackedfiles 'yes'
set __fish_git_prompt_showupstream 'verbose'
set __fish_git_prompt_color_branch yellow
set __fish_git_prompt_color_upstream_ahead green
set __fish_git_prompt_color_upstream_behind red
set __fish_git_prompt_show_informative_status 'yes'

# venv
function venv
  if test -d "venv"
     source venv/bin/activate.fish
  end
end

function fish_prompt
  set last_status $status

  set_color $fish_color_cwd
  printf '%s' (prompt_pwd)
  set_color normal

  printf '%s ' (__fish_git_prompt)

  set_color normal
end


