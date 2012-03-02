#!/bin/bash
# ask@0x61736b.net

# LOCALE

export LOCALE=C
export LC_ALL=$LOCALE

LivingProfilePrefix="$HOME/.living-profile"
LivingShellProfile="$LivingProfilePrefix/bash/boot"

throw() {
    printf "ERROR: $1\n" >/dev/stderr
    exit 1
}
warn() {
    printf "WARNING: $1\n" >/dev/stderr
}

pman () {
    man -t "$1" | open -f -a Preview
}

unshift_manpath () {
    new_manpath="$1"
    # Add the path into $PATH if it doesn't already exist.
    echo $MANPATH | grep -q -s "$new_manpath"
    if [ $? -eq 1 ]; then
        MANPATH="$new_manpath":"$MANPATH"
    fi
    export MANPATH
}

unshift_path () {
    new_path="$1"
    # Add the path into $PATH if it doesn't already exist.
    echo $PATH | grep -q -s "$new_path"
    if [ $? -eq 1 ]; then
        PATH="$new_path":"$PATH"
    fi
    export PATH
}


lp_exec_action() {
    action=$1
    script_file="$LivingShellProfile/$action.sh"
    if [ -x "$script_file" ]; then
        . "$script_file"
    else
        throw "File for action $action ($script_file) is not executable"
    fi
}


# ### SYSTEM INITIALIZATION



# ### CONFIGURATION

BASH_RC="$HOME/.bashrc"
BASH_PROFILE="$HOME/.bash_profile"

# ### SHELL INIT

IS_BASH=
IS_SH=
IS_KORN=
IS_CSH=

this_shell=$(basename "$SHELL")
case "$this_shell" in
    bash)
        export IS_BASH=1
    ;;
    sh)
        export IS_SH=1
    ;;
    ksh)
        export IS_KORN=1
    ;;
    pdksh)
        export IS_KORN=1
    ;;
    csh)
        export IS_CSH=1
    ;;
esac

if [ ! -z "$BASH_VERSION" ]; then
    export IS_BASH=1
fi

# ### OS INIT

# Determine which OS we're running.

OSNAME="$(uname -s)"
ARCHTYPE="$(uname  -p)"
OSVERSION="$(uname -r)"

IS_MAC_OS_X=
IS_LINUX=

case $OSNAME in
    "Darwin")
        export IS_MAC_OS_X=1
        export OS_GREETING="Mac OS X"
    ;;
    "Linux")
        export IS_LINUX=1
        export OS_GREETING="Linux"
    ;;
esac

if [ $IS_MAC_OS_X ]; then

    # Seems to be hardcoded to powerpc in Tiger, even though
    # it's intel. So we set it explicitly with help from uname here.
    export HOSTTYPE="$ARCHTYPE"

    # same with this, which is hardcoded to powerpc-apple-darwin8.0
    export MACHTYPE="$ARCHTYPE-apple-darwin-$OSVERSION"

    # FINK
    if [ -f "$FINK_LOAD_SCRIPT" ]; then
        source "$FINK_LOAD_SCRIPT"
    fi
fi

# SHELL OPTIONS

lp_exec_action IncludeSystemwideProfile
lp_exec_action ViMode
lp_exec_action AddUserBinToPath
lp_exec_action PyUtils

include_startup_script () {
    script="$1"
    if [ -f "$script" -a -x "$script" ]; then
        source "$script"
    fi
}

include_startup_script "$BASH_PROFILE"
include_startup_script "$BASH_RC"


# PATH


unshift_path "/Developer/Tools"
unshift_path "/usr/local/bin"
unshift_path "/usr/local/sbin"
unshift_path "/Applications"
for sbin_dir in /opt/*/sbin; do
    unshift_path "$sbin_dir"
done
for bin_dir  in /opt/*/bin;  do
    unshift_path "$bin_dir"
done

unshift_path "/usr/local/mysql/bin"
export PATH;

# MANPATH
for man_dir  in /opt/*/man;  do
    unshift_manpath "$man_dir"
done
unshift_manpath "/opt/lighttpd/share/man"

for opt_app in apache2 intel; do 
    unshift_path "/opt/$opt_app/bin"
done


# ENVIRONMENT

# Use vim as the man pager.
export MANPAGER="col -b | view -c 'set ft=man nomod nolist' -" 
export EDITOR='mvim'
export VISUAL="$EDITOR"

if [ $IS_MAC_OS_X ]; then
    export MACOSX_DEPLOYMENT_TARGET="10.7"
fi

# PROMPT
HOSTNAME=$(hostname -s);
#export PS1='$USER@${HOSTNAME:-localhost}:$PWD\$> '
export PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]$(__git_ps1 "(%s)")$> '

# DEBIAN PACKAGE OPTIONS
export DEBEMAIL="ask@celeryproject.org"
export DEBFULLNAME="Ask Solem"

# ALIASES

alias ls='/usr/local/bin/gls --color -F -h'
alias pack='ack --python'
alias pipx='$VIRTUAL_ENV/bin/pip -E $VIRTUAL_ENV'
alias P='workon def'
alias macvim='mvim'
alias vim='mvim'
alias psa='ps auxww'
alias grepi='grep -i'
alias egrepi='grep -Ei'
alias gps='ps auxww | grepi '
alias metafoo='meta foo -ws 16'
alias metaa='meta any -ws 16'
alias svnprop='svn propset svn:keywords Id,Source,Author,HeadURL,Revision,Date'
alias op='/opt/local/bin/gnome'
alias make..='(cd ../; make)'
alias lst='ls -t --reverse'
alias boa='python'
alias suroot='sudo su -l -'
alias svim='sudo \vim'
alias sapt='sudo apt-get install'
alias saps='sudo apt-cache search'
alias svi='svim'
alias vip='mvim --remote-tab'
alias pws='gpg --decrypt /opt/void/pwd.gpg'
alias s='sudo'
alias pypan='env MACOSX_DEPLOYMENT_TARGET=10.6 easy_install'
alias psyq='psyqueue'
alias psyf='psyfetch'
alias ptv='psyqueue tv'
alias pxvid='psyqueue xvid'
alias pmac='psyqueue mac'
alias paudio='psyqueue audioiso'
alias psample='psyqueue samplecd'
alias lsd='ls -clr | grep $(date "+%Y-%m") | sort -k 6 -r'
alias ipy='ipython'
alias cov='nosetests --with-coverage3 --cover3-html'
alias ackt='ack --ignore-dir=tests/'


# STARTUP EXEC

echo
echo "                          [ Welcome to $OS_GREETING @$MACHTYPE ]"
echo

# mail
mail_bin=$(whereis mail)
test -f "$mail_bin" -a -x "$mail_bin" && $mail_bin
echo

# ### INITIALIZE ENVIRONMENT

if [ ! $IS_MAC_OS_X ]; then
    export DISPLAY=":0"
fi

# Development Environment
LIBPATHS="-L/usr/local/lib -L/usr/local/mysql/lib"
INCPATHS="-I/usr/local/include -I/usr/local/mysql/include"

export LDFLAGS="$LIBPATHS"
CFLAGS="-Os -sse3 -ssse3"
export CFLAGS="$LIBPATHS $INCPATHS $CFLAGS"

if [ $IS_MAC_OS_X ]; then
    # Build programs for these architectures
    export ARCHFLAGS='-arch i386 -arch x86_64'
fi

export EMAIL="ask@celeryproject.org"

# git stuff
export GIT_AUTHOR_NAME="Ask Solem"
export GIT_AUTHOR_EMAIL="ask@celeryproject.org"
export GIT_EDITOR="/Applications/MacVim.app/Contents/MacOS/Vim -g -f"

# IDA Pro
export PATH+=":/opt/ida/bin"

export PATH="/usr/local/bin:/usr/local/sbin:$PATH"

# Python
unshift_path "/Library/Frameworks/Python.framework/Versions/Current/bin"
unshift_path "/opt/rabbitmq/sbin"

if [ -f `brew --prefix`/etc/bash_completion ]; then
  . `brew --prefix`/etc/bash_completion
fi

# pip bash completion start
_pip_completion()
{
    COMPREPLY=( $( COMP_WORDS="${COMP_WORDS[*]}" \
                   COMP_CWORD=$COMP_CWORD \
                   PIP_AUTO_COMPLETE=1 $1 ) )
}
complete -o default -F _pip_completion pip
# pip bash completion end


PATH="~/.gem/ruby/1.8/bin/:${PATH}"
export PATH


# virtualenvwrapper
source /usr/local/bin/virtualenvwrapper.sh

dapp() {
    cd /opt/devel/django-celery/examples/demoproject;
    python manage.py $*
}


capp() {
    cd /opt/devel/demoapp
    $*
}

cpy() {
    (capp bpython);
}

celerytop () {
    watch -n 0.1 'ps auxww | grep "\[celery" | grep -Ev "grep|watch"'
}



alias g='gh'
# Autocomplete for 'g' as well
complete -o default -o nospace -F _git g
complete -o default -o nospace -F _git gh


# Setting PATH for Python 2.7
# The orginal version is saved in .profile.pysave
PATH="/Library/Frameworks/Python.framework/Versions/2.7/bin:${PATH}"
export PATH


PATH="/opt/devel/Rabbit/rabbitmq-server/scripts:${PATH}"
export PATH


start_rabbit () {
    (cd /opt/devel/Rabbit/rabbitmq-server/;
     sudo ./scripts/rabbitmq-server -detached)
}


# Setting PATH for Python 3.2
# The orginal version is saved in .profile.pysave
PATH="/Library/Frameworks/Python.framework/Versions/3.2/bin:${PATH}"
export PATH

PATH="/usr/local/bin:/usr/local/sbin:$PATH"

# Delete duplicate PATH components.
PATH=`
    perl -le'for(split m/:/,shift){push@_,$_ if!$s{$_}++};print join":",@_' "$PATH"
`;
export PATH


if [ -f ~/.localenv ]; then
    . ~/.localenv
fi
