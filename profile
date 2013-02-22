#!/bin/bash
# ask@0x61736b.net

# LOCALE
export LOCALE=C
export LC_ALL=$LOCALE

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
        PATH="${new_path}:${PATH}"
    fi
    export PATH
}


# ### CONFIGURATION

BASH_RC="$HOME/.bashrc"
BASH_PROFILE="$HOME/.bash_profile"

# ### SHELL INIT

IS_BASH=
IS_SH=
IS_KORN=

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
        export OS_GREETING="OS X"
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
fi


# Include system-wide profile
if [ -f "/etc/profile" ]; then
    . /etc/profile
fi
export PATH="$PATH:/usr/libexec"

# Enable vi-mode
if [ $IS_BASH ]; then
    set -o vi on
elif [ $IS_KORN ]; then
    set -o vi on
    set -o viraw on
fi

# Add user bin
if [ -d "$HOME/bin" ]; then
    PATH="$HOME/bin:${PATH}"
fi

# Macros
pymod () {
    python -c "import $1; print($1.__file__.replace('.pyc', '.py'))"
}

vimod () {
    ${VISUAL:-${EDITOR:-vi}} $(pymod $1)
}

pman () {
    man -t "$1" | open -f -a Preview
}

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

start_rabbit () {
    (cd /opt/devel/Rabbit/rabbitmq-server/;
     sudo ./scripts/rabbitmq-server -detached)
}



# Include additional profiles (.bash_profile, .bashrc)
include_startup_script () {
    script="$1"
    if [ -f "$script" -a -x "$script" ]; then
        source "$script"
    fi
}
include_startup_script "$BASH_PROFILE"
include_startup_script "$BASH_RC"


# PATH

#-- Add all programs in /opt
for sbin_dir in /opt/*/sbin; do
    unshift_path "$sbin_dir"
done
for bin_dir  in /opt/*/bin;  do
    unshift_path "$bin_dir"
done
#---- MANPATH
for man_dir  in /opt/*/man;  do
    unshift_manpath "$man_dir"
done


# ENVIRONMENT

# Use vim as the man pager.
export MANPAGER="col -b | view -c 'set ft=man nomod nolist' -"
export EDITOR='mvim'
export VISUAL="$EDITOR"

if [ $IS_MAC_OS_X ]; then
    export MACOSX_DEPLOYMENT_TARGET="10.8"
fi

# PROMPT
HOSTNAME=$(hostname -s);
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
alias s='sudo'
alias lsd='ls -clr | grep $(date "+%Y-%m") | sort -k 6 -r'
alias ipy='ipython'
alias cov='nosetests --with-coverage3 --cover3-html'
alias ackt='ack --ignore-dir=tests/'


# STARTUP EXEC

echo
echo "{$OS_GREETING @$MACHTYPE}"
echo

# ### INITIALIZE ENVIRONMENT

if [ ! $IS_MAC_OS_X ]; then
    export DISPLAY=":0"
fi

# Development Environment
LIBPATHS="-L/usr/local/lib"
INCPATHS="-I/usr/local/include"

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

PATH="/usr/local/bin:/usr/local/sbin:$PATH"

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


# virtualenvwrapper
source /usr/local/bin/virtualenvwrapper.sh

alias g='gh'
# Autocomplete for 'g' as well
complete -o default -o nospace -F _git g
complete -o default -o nospace -F _git gh


# Add /usr/local paths
PATH="/usr/local/bin:/usr/local/sbin:$PATH"

if [ -f ~/.localenv ]; then
    . ~/.localenv
fi

# Setting PATH for Ruby 1.8
PATH="/System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/bin:${PATH}"

# Setting PATH for Python 2.7
# The orginal version is saved in .profile.pysave
PATH="/Library/Frameworks/Python.framework/Versions/2.7/bin:${PATH}"
# Setting PATH for Python 3.3
# The orginal version is saved in .profile.pysave
PATH="/Library/Frameworks/Python.framework/Versions/3.3/bin:${PATH}"

# Delete duplicate PATH components.
PATH=`
    perl -le'for(split m/:/,shift){push@_,$_ if!$s{$_}++};print join":",@_' "$PATH"
`;
export PATH


celery_stable () {
    cd /opt/devel/py-amqp; git checkout 1.0; python setup.py develop
    cd /opt/devel/kombu; git checkout 2.5; python setup.py develop
    cd /opt/devel/billiard; git checkout 2.7; python setup.py install
    cd /opt/devel/celery; git checkout 3.0; python setup.py develop
}

celery_master () {
    cd /opt/devel/py-amqp; git checkout master; python setup.py develop
    cd /opt/devel/kombu; git checkout master; python setup.py develop
    cd /opt/devel/billiard; git checkout master; python setup.py install
    cd /opt/devel/celery; git checkout master; python setup.py develop
}
