# Lines configured by zsh-newuser-install
HISTFILE=~/.zsh_histfile
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory autocd notify
unsetopt beep
bindkey -e
# End of lines configured by zsh-newuser-install

# Basic auto/tab complete:
autoload -U compinit
zstyle ':completion:*' menu select
zmodload zsh/complist
compinit
_comp_options+=(globdots)   # Include hidden files.

# Load aliases
[ -f "$HOME/.alias" ] && source "$HOME/.alias"

function precmd {
  local TERMWIDTH
  (( TERMWIDTH = ${COLUMNS} - 1 ))
 
  ###
  # Truncate the path if it's too long.
  PR_FILLBAR=""
  PR_PWDLEN=""
 
  local promptsize=${#${(%):---(%n@%m:%l)---()--}}
  local pwdsize=${#${(%):-%~}}
  local unamer=$(uname -r)
  local size_uname=${#${unamer}}
(( promptsize = $promptsize + 29 + size_uname + 5 ))
  if [[ "$promptsize + $pwdsize" -gt $TERMWIDTH ]]; then
    ((PR_PWDLEN=$TERMWIDTH - $promptsize))
  else
    PR_FILLBAR="\${(l.(($TERMWIDTH - ($promptsize + $pwdsize)))..${PR_HBAR}.)}"
  fi
}
 
setopt extended_glob
preexec () {
  if [[ "$TERM" == "screen" ]]; then
    local CMD=${1[(wr)^(*=*|sudo|-*)]}
    echo -n "\ek$CMD\e\\"
  fi
}
 
setprompt () {
  ###
  # Need this so the prompt will work.
  setopt prompt_subst
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
  [ $UID = 0 ] && USRPROMPT="$PR_RED#$PR_NO_COLOUR" || USRPROMPT="$PR_BLUE\$$PR_NO_COLOUR"
 
  ###
  # See if we can use extended characters to look nicer.
  typeset -A altchar
  set -A altchar ${(s..)terminfo[acsc]}
  PR_SET_CHARSET="%{$terminfo[enacs]%}"
  PR_SHIFT_IN="%{$terminfo[smacs]%}"
  PR_SHIFT_OUT="%{$terminfo[rmacs]%}"
  PR_HBAR=-
  PR_ULCORNER=${altchar[l]:--}
  PR_LLCORNER=${altchar[m]:--}
  PR_LRCORNER=${altchar[j]:--}
  PR_URCORNER=${altchar[k]:--}
 
#  PR_ULCORNER="/"
#  PR_LLCORNER="\\"
#  PR_URCORNER="\\"
#  PR_LRCORNER="/"
 
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
  # Decide whether to set a screen title
  if [[ "$TERM" == "screen" ]]; then
    PR_STITLE=$'%{\ekzsh\e\\%}'
  else
    PR_STITLE=''
  fi
 
  ###
  # Finally, the prompt.
  PROMPT='$PR_SET_CHARSET$PR_STITLE${(e)PR_TITLEBAR}\
$PR_SHIFT_IN$PR_ULCORNER$PR_HBAR$PR_HBAR$PR_SHIFT_OUT\
\
(%D{%a, %Y-%m-%d %H:%M:%S})\
$PR_SHIFT_IN$PR_HBAR$PR_HBAR$PR_HBAR$PR_SHIFT_OUT\
(%(!.%SROOT%s.%n)@%m:%l)\
$PR_SHIFT_IN$PR_HBAR$PR_HBAR$PR_HBAR$PR_SHIFT_OUT\
($(uname -r))\
\
$PR_SHIFT_IN$PR_HBAR${(e)PR_FILLBAR}$PR_SHIFT_OUT(\
%$PR_PWDLEN<...<%~%<<\
)$PR_SHIFT_IN$PR_SHIFT_IN$PR_HBAR$PR_HBAR$PR_URCORNER$PR_SHIFT_OUT\
 
$PR_SHIFT_IN$PR_LLCORNER$PR_HBAR$PR_HBAR$PR_SHIFT_OUT(\
%(?.${PR_LIGHT_GREEN}OK.${PR_LIGHT_RED}ERR %?)\
$PR_NO_COLOUR)$PR_SHIFT_IN$PR_HBAR$PR_SHIFT_OUT\
$PR_SHIFT_IN$PR_HBAR$PR_SHIFT_OUT\
(%1~)\
>$USRPROMPT '
 
  RPROMPT=' $PR_SHIFT_IN$PR_HBAR$PR_HBAR$PR_SHIFT_OUT(\
$(uptime | sed -e "s/.*: *//" | cut -d" " -f1,2 | sed 's/,$//'))\
$PR_SHIFT_IN$PR_HBAR$PR_HBAR$PR_LRCORNER$PR_SHIFT_OUT$PR_NO_COLOUR'
 
 
  PS2='$PR_SHIFT_IN$PR_HBAR$PR_SHIFT_OUT\
$PR_SHIFT_IN$PR_HBAR$PR_SHIFT_OUT(\
$PR_LIGHT_GREEN%_)$PR_SHIFT_IN$PR_HBAR$PR_SHIFT_OUT\
$PR_SHIFT_IN$PR_HBAR$PR_SHIFT_OUT$PR_NO_COLOUR '
}
 
setprompt

bindkey "\e[5~" history-beginning-search-backward
bindkey "\e[6~" history-beginning-search-forward
# EOF ##########################################################################

