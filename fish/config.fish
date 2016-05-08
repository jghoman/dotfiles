
if test -d "/opt/local/bin"
  set -gx PATH /opt/local/bin/ $PATH
end

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

function zmvn
  mvn -DskipTests=true clean dependency:go-offline verify package
end

function tl
  tree -nhs | less
end

function dockerenv
  eval (docker-machine env --shell fish)
end

function zdcleancreated
  docker ps -a | tail -n +2 | sed -n 's/  */ /gp' | cut -d " " -f 1 | xargs docker rm
end

function zdcleanimages
  docker images | grep "<none>" | sed -n 's/  */ /gp' | cut -d " " -f 3 | xargs docker rmi
end

function jarsinm2
  find ~/.m2 -name "*.jar" | wc -l
end

function f
  find . -name $argv
end

function fish_prompt
  set last_status $status

  set_color $fish_color_cwd
  printf '%s' (prompt_pwd)
  set_color normal

  printf '%s ' (__fish_git_prompt)

  set_color normal
end


