#
# Defines general aliases and functions.
#
# Authors:
#   Robby Russell <robby@planetargon.com>
#   Suraj N. Kurapati <sunaku@gmail.com>
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

# Load dependencies.
pmodload 'helper' 'spectrum'

# Correct commands.
if zstyle -T ':prezto:module:utility' correct; then
  setopt CORRECT
fi

# Load 'run-help' function.
autoload -Uz run-help-{ip,openssl,sudo}

#
# Aliases
#

# Disable correction.
alias ack='nocorrect ack'
alias cd='nocorrect cd'
alias cp='nocorrect cp'
alias ebuild='nocorrect ebuild'
alias gcc='nocorrect gcc'
alias gist='nocorrect gist'
alias grep='nocorrect grep'
alias heroku='nocorrect heroku'
alias ln='nocorrect ln'
alias man='nocorrect man'
alias mkdir='nocorrect mkdir'
alias mv='nocorrect mv'
alias mysql='nocorrect mysql'
alias rm='nocorrect rm'

# Disable globbing.
alias bower='noglob bower'
alias fc='noglob fc'
alias find='noglob find'
alias ftp='noglob ftp'
alias history='noglob history'
alias locate='noglob locate'
alias rake='noglob rake'
alias rsync='noglob rsync'
alias scp='noglob scp'
alias sftp='noglob sftp'

# Define general aliases.
alias _='sudo'
alias b='${(z)BROWSER}'

alias diffu="diff --unified"
alias e='${(z)VISUAL:-${(z)EDITOR}}'
alias mkdir="${aliases[mkdir]:-mkdir} -p"
alias p='${(z)PAGER}'
alias po='popd'
alias pu='pushd'
alias sa='alias | grep -i'
alias type='type -a'

# Safe ops. Ask the user before doing anything destructive.
alias cpi="${aliases[cp]:-cp} -i"
alias lni="${aliases[ln]:-ln} -i"
alias mvi="${aliases[mv]:-mv} -i"
alias rmi="${aliases[rm]:-rm} -i"
if zstyle -T ':prezto:module:utility' safe-ops; then
  alias cp="${aliases[cp]:-cp} -i"
  alias ln="${aliases[ln]:-ln} -i"
  alias mv="${aliases[mv]:-mv} -i"
  alias rm="${aliases[rm]:-rm} -i"
fi

# ls
if [[ ${(@M)${(f)"$(ls --version 2>&1)"}:#*(GNU|lsd) *} ]]; then
  # GNU Core Utilities

  if zstyle -T ':prezto:module:utility:ls' dirs-first; then
    alias ls="${aliases[ls]:-ls} --group-directories-first"
  fi

  if zstyle -t ':prezto:module:utility:ls' color; then
    # Define colors for GNU ls if they're not already defined
    if (( ! $+LS_COLORS )); then
      # Try dircolors when available
      if is-callable 'dircolors'; then
        eval "$(dircolors --sh $HOME/.dir_colors(N))"
      else
        export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=36;01:cd=33;01:su=31;40;07:sg=36;40;07:tw=32;40;07:ow=33;40;07:'
      fi
    fi

    alias ls="${aliases[ls]:-ls} --color=auto"
  else
    alias ls="${aliases[ls]:-ls} -F"
  fi
else
  # BSD Core Utilities

  if zstyle -t ':prezto:module:utility:ls' color; then
    # Define colors for BSD ls if they're not already defined
    if (( ! $+LSCOLORS )); then
      export LSCOLORS='exfxcxdxbxGxDxabagacad'
    fi

    alias ls="${aliases[ls]:-ls} -G"
  else
    alias ls="${aliases[ls]:-ls} -F"
  fi
fi

alias l='ls -1A'         # Lists in one column, hidden files.
alias ll='ls -lh'        # Lists human readable sizes.
alias lr='ll -R'         # Lists human readable sizes, recursively.
alias la='ll -A'         # Lists human readable sizes, hidden files.
alias lm='la | "$PAGER"' # Lists human readable sizes, hidden files through pager.
alias lk='ll -Sr'        # Lists sorted by size, largest last.
alias lt='ll -tr'        # Lists sorted by date, most recent last.
alias lc='lt -c'         # Lists sorted by date, most recent last, shows change time.
alias lu='lt -u'         # Lists sorted by date, most recent last, shows access time.

if [[ ${(@M)${(f)"$(ls --version 2>&1)"}:#*GNU *} ]]; then
  alias lx='ll -XB'      # Lists sorted by extension (GNU only).
fi

# Grep
if zstyle -t ':prezto:module:utility:grep' color; then
  export GREP_COLOR=${GREP_COLOR:-'37;45'}            # BSD.
  export GREP_COLORS=${GREP_COLORS:-"mt=$GREP_COLOR"} # GNU.

  alias grep="${aliases[grep]:-grep} --color=auto"
fi

# macOS Everywhere
if is-darwin; then
  alias o='open'
elif is-cygwin; then
  alias o='cygstart'
  alias pbcopy='tee > /dev/clipboard'
  alias pbpaste='cat /dev/clipboard'
elif is-termux; then
  alias o='termux-open'
  alias pbcopy='termux-clipboard-set'
  alias pbpaste='termux-clipboard-get'
else
  alias o='xdg-open'

  if (( $+commands[wl-copy] )) && [[ -n "${WAYLAND_DISPLAY}" ]]; then
    alias pbcopy='wl-copy'
    alias pbpaste='wl-paste'
  elif (( $+commands[xclip] )); then
    alias pbcopy='xclip -selection clipboard -in'
    alias pbpaste='xclip -selection clipboard -out'
  elif (( $+commands[xsel] )); then
    alias pbcopy='xsel --clipboard --input'
    alias pbpaste='xsel --clipboard --output'
  fi
fi

alias pbc='pbcopy'
alias pbp='pbpaste'

# File Download
zstyle -s ':prezto:module:utility:download' helper '_download_helper' || _download_helper='curl'

typeset -A _download_helpers=(
  aria2c  'aria2c --continue --remote-time --max-tries=0'
  curl    'curl --continue-at - --location --progress-bar --remote-name --remote-time'
  wget    'wget --continue --progress=bar --timestamping'
)

if (( $+commands[$_download_helper] && $+_download_helpers[$_download_helper] )); then
  alias get="$_download_helpers[$_download_helper]"
elif (( $+commands[curl] )); then
  alias get="$_download_helpers[curl]"
fi

unset _download_helper{,s}

# Resource Usage
alias df='df -kh'
alias du='du -kh'

if is-darwin || is-bsd; then
  alias topc='top -o cpu'
  alias topm='top -o vsize'
else
  alias topc='top -o %CPU'
  alias topm='top -o %MEM'
fi

# Miscellaneous

# Serves a directory via HTTP.
if (( $#commands[(i)python(|[23])] )); then
  autoload -Uz is-at-least
  if (( $+commands[python3] )); then
    alias http-serve='python3 -m http.server'
  elif (( $+commands[python2] )); then
    alias http-serve='python2 -m SimpleHTTPServer'
  elif is-at-least 3 ${"$(python --version 2>&1)"[(w)2]}; then
    alias http-serve='python -m http.server'
  else
    alias http-serve='python -m SimpleHTTPServer'
  fi
fi

#
# Functions
#

# Makes a directory and changes to it.
function mkdcd {
  [[ -n "$1" ]] && mkdir -p "$1" && builtin cd "$1"
}

# Changes to a directory and lists its contents.
function cdls {
  builtin cd "$argv[-1]" && ls "${(@)argv[1,-2]}"
}

# Pushes an entry onto the directory stack and lists its contents.
function pushdls {
  builtin pushd "$argv[-1]" && ls "${(@)argv[1,-2]}"
}

# Pops an entry off the directory stack and lists its contents.
function popdls {
  builtin popd "$argv[-1]" && ls "${(@)argv[1,-2]}"
}

# Prints columns 1 2 3 ... n.
function slit {
  awk "{ print ${(j:,:):-\$${^@}} }"
}

# Finds files and executes a command on them.
function find-exec {
  find . -type f -iname "*${1:-}*" -exec "${2:-file}" '{}' \;
}

# Displays user owned processes status.
function psu {
  ps -U "${1:-$LOGNAME}" -o 'pid,%cpu,%mem,command' "${(@)argv[2,-1]}"
}

# Enables globbing selectively on path arguments.
# Globbing is enabled on local paths (starting in '/' and './') and disabled
# on remote paths (containing ':' but not starting in '/' and './'). This is
# useful for programs that have their own globbing for remote paths.
# Currently, this is used by default for 'rsync' and 'scp'.
# Example:
#   - Local: '*.txt', './foo:2017*.txt', '/var/*:log.txt'
#   - Remote: user@localhost:foo/
#
# NOTE: This function is buggy and is not used anywhere until we can make sure
# it's fixed. See https://github.com/sorin-ionescu/prezto/issues/1443 and
# https://github.com/sorin-ionescu/prezto/issues/1521 for more information.
function noremoteglob {
  local -a argo
  local cmd="$1"
  for arg in ${argv:2}; do case $arg in
    ( ./* ) argo+=( ${~arg} ) ;; # local relative, glob
    (  /* ) argo+=( ${~arg} ) ;; # local absolute, glob
    ( *:* ) argo+=( ${arg}  ) ;; # remote, noglob
    (  *  ) argo+=( ${~arg} ) ;; # default, glob
  esac; done
  command $cmd "${(@)argo}"
}
