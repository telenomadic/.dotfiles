# Paths
#  binary, etc
PATH=$PATH:/sbin/:/usr/sbin:/usr/local/sbin:/usr/local/bin:/bin:$HOME/bin:$HOME/bin/synergy:/opt/local/bin:$HOME/
## disable stop in shell so forward search works (ctl+s)
# http://nathanpowell.org/blog/archives/632
stty stop undef
PAGER=less 

export CLICOLOR=1
export LSCOLORS=cxFxCxDxBxegedabagaced

# Setup tab-completion
autoload -U compinit
compinit
#  get hostnames to autocomplete on from known_hosts
local _myhosts
_myhosts=( ${${${${(f)"$(<$HOME/.ssh/known_hosts)"}:#[0-9]*}%%\ *}%%,*} )
zstyle ':completion:*' hosts $_myhosts
# Setup CD stack options
#  cd to a dir without "cd" command
setopt autocd
#  push dirs to the stack
setopt autopushd 
#  don't push dirs if they are dups
setopt pushdignoredups 
# Setup command history
# Number of lines of history kept within the shell.
HISTSIZE=100000
HISTFILE=~/.zhistory
# Number of lines of history to save to $HISTFILE.
SAVEHIST=100000
# Don't overwrite, append!
setopt APPEND_HISTORY
#  csh-style sometimes
setopt banghist
#  no dups
setopt histignoredups
#  no blanks
setopt histreduceblanks
# Setup job control
#  long job listing
setopt longlistjobs
# other options
#  spell correct things
setopt correct
#  export everything
setopt allexport
#  vi mode
#setopt vi
#  no flow-control
setopt flowcontrol
#  remember where commands are
setopt hashcmds
#  remember where dirs are
setopt hashdirs
EDITOR=vim
alias mv='nocorrect mv'       # no spelling correction on mv
alias cp='nocorrect cp'    # no spelling correction on cp
alias mkdir='nocorrect mkdir' # no spelling correction on mkdir
alias ls='ls -G'
alias cls='clear'
alias grep='grep --color'
alias bt=“wget http://cachefly.cachefly.net/400mb.test”

# whats hogging disk 
alias hogs='sudo du -skx * | sort -rn | head'
# cool rfc822 date thing
# function utcconv { date -d "${@}" "+%s"; }
function precmd {

    local TERMWIDTH
    (( TERMWIDTH = ${COLUMNS} - 1 ))

    ###
    # Truncate the path if it's too long.
    
    PR_FILLBAR=""
    PR_PWDLEN=""
    
    local promptsize=${#${(%):---(%n@%m)---()--}}
    local pwdsize=${#${(%):-%~}}
    
    if [[ "$promptsize + $pwdsize" -gt $TERMWIDTH ]]; then
	    ((PR_PWDLEN=$TERMWIDTH - $promptsize))
    else
	PR_FILLBAR="\${(l.(($TERMWIDTH - ($promptsize + $pwdsize)))..${PR_HBAR}.)}"
    fi

## Show the load avg on osx
if [[ `uname` = Darwin || `uname` = *BSD ]] ; then   psvar=(`uptime | awk '{print $(NF-2),$(NF-1),$NF}' 2>/dev/null`)
else
## Show the load avg on linux
   psvar=(`cat /proc/loadavg`)
fi
}

setopt extended_glob
preexec () {
}


setprompt () {
    ###
    # Need this so the prompt will work.

    setopt prompt_subst
  if [ -e "~/bin/bash_completion.d/git-prompt.sh" ]; then
    source "~bin/bash_completion.d/git-prompt.sh"
  fi
    ###
    # See if we can use colors.

    autoload colors zsh/terminfo
    if [[ "$terminfo[colors]" -ge 8 ]]; then
	colors
    fi
    for color in RED GREEN YELLOW BLUE MAGENTA CYAN WHITE; do
	eval PR_$color='%{$terminfo[bold]$fg[${(L)color}]%}'
	eval PR_LIGHT_$color='%{$fg[${(L)color}]%}'
	(( count = $count + 1 ))
    done
    PR_NO_COLOUR="%{$terminfo[sgr0]%}"

    ###
    # See if we can use extended characters to look nicer.
    
    typeset -A altchar
    set -A altchar ${(s..)terminfo[acsc]}
    PR_SET_CHARSET="%{$terminfo[enacs]%}"
    PR_SHIFT_IN="%{$terminfo[smacs]%}"
    PR_SHIFT_OUT="%{$terminfo[rmacs]%}"
    PR_HBAR=${altchar[q]:--}
    PR_ULCORNER=${altchar[l]:--}
    PR_LLCORNER=${altchar[m]:--}
    PR_LRCORNER=${altchar[j]:--}
    PR_URCORNER=${altchar[k]:--}

    ###
    # Decide if we need to set titlebar text.
    
    case $TERM in
	xterm*)
    PR_TITLEBAR=$'%{\e]0;%(!.-=*[ROOT]*=- | .)%n@%m:%~ | ${COLUMNS}x${LINES} | %y\a%}'
    ;;
screen)
    PR_TITLEBAR=$'%{\e_screen \005 (\005t) | %(!.-=[ROOT]=- | .)%n@%m:%~ | ${COLUMNS}x${LINES} | %y\e\\%}'
	    ;;
	*)
	    PR_TITLEBAR=''
	    ;;
    esac
    
    ###
    # Finally, the prompt.

    PROMPT='$PR_SET_CHARSET$PR_STITLE${(e)PR_TITLEBAR}\
$PR_CYAN$PR_SHIFT_IN$PR_ULCORNER$PR_BLUE$PR_HBAR$PR_SHIFT_OUT(\
$PR_GREEN%(!.%SROOT%s.%n)$PR_WHITE@$PR_RED%m\
$PR_BLUE)$PR_SHIFT_IN$PR_HBAR$PR_CYAN$PR_HBAR${(e)PR_FILLBAR}$PR_BLUE$PR_HBAR$PR_SHIFT_OUT $(__git_ps1)(\
$PR_MAGENTA%$PR_PWDLEN<...<%~%<<\
$PR_BLUE)$PR_SHIFT_IN$PR_HBAR$PR_CYAN$PR_URCORNER$PR_SHIFT_OUT\

$PR_CYAN$PR_SHIFT_IN$PR_LLCORNER$PR_BLUE$PR_HBAR$PR_SHIFT_OUT(\
${(e)PR_APM}$PR_YELLOW%D{%H:%M}\
$PR_LIGHT_BLUE:%(!.$PR_RED.$PR_WHITE)%#$PR_BLUE)$PR_SHIFT_IN$PR_HBAR$PR_SHIFT_OUT\
$PR_CYAN$PR_SHIFT_IN$PR_HBAR$PR_SHIFT_OUT\
$PR_NO_COLOUR '

    RPROMPT=' $PR_CYAN$PR_SHIFT_IN$PR_HBAR$PR_BLUE$PR_HBAR$PR_SHIFT_OUT\
%(?..$PR_LIGHT_RED%?$PR_BLUE)\
($PR_YELLOW%1v %2v %3v$PR_BLUE)$PR_SHIFT_IN$PR_HBAR$PR_CYAN$PR_LRCORNER$PR_SHIFT_OUT$PR_NO_COLOUR'

    PS2='$PR_CYAN$PR_SHIFT_IN$PR_HBAR$PR_SHIFT_OUT\
$PR_BLUE$PR_SHIFT_IN$PR_HBAR$PR_SHIFT_OUT(\
$PR_LIGHT_GREEN%_$PR_BLUE)$PR_SHIFT_IN$PR_HBAR$PR_SHIFT_OUT\
$PR_CYAN$PR_SHIFT_IN$PR_HBAR$PR_SHIFT_OUT$PR_NO_COLOUR '
}

setprompt

# END
