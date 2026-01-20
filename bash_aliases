
#alias code=codium

alias clc='clear'

alias ls='eza --icons -F -H --group-directories-first --git -1'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

alias cat='batcat'
alias cd='z'
alias wiztree='ncdu'
# alias rm='echo "This is not the command you are looking for."; false'
alias rm='trash' # This is not recommended since the flags are different, but I rarely use flags with rm

alias sysupdate='sudo apt update; sudo apt upgrade -y; sudo apt autoremove -y; sudo apt autoclean -y'
# List ports used by docker containers
alias lsps='docker container ls --format "table {{.ID}}\t{{.Names}}\t{{.Ports}}" -a'

alias matlab='matlab -desktop'
alias matlab-cli='command matlab -nodesktop'

alias python="python3"

alias bambu='flatpak run com.bambulab.BambuStudio'

alias h='history | grep '
alias mx='chmod a+x'

alias neofetch='fastfetch'