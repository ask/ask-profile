#!/bin/bash
# ask@0x61736b.net

LivingProfilePrefix="$HOME/.living-profile"
LivingShellProfile="$LivingProfilePrefix/bash/boot"

throw() {
    printf "ERROR: $1\n" >/dev/stderr
    exit 1
}
warn() {
    printf "WARNING: $1\n" >/dev/stderr
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

FINK_LOAD_SCRIPT="/sw/bin/init.sh"

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

include_startup_script () {
    script="$1"
    if [ -f "$script" -a -x "$script" ]; then
        source "$script"
    fi
}

include_startup_script "$BASH_PROFILE"
include_startup_script "$BASH_RC"

# LOCALE

export LOCALE="en_US.UTF-8"
export LC_ALL=$LOCALE

# PATH
unshift_path "/opt/bleadperl/bin"
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
unshift_path "/usr/local/BerkeleyDB.4.5/bin"
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
export EDITOR=vim
export VISUAL="$EDITOR"
export CVSROOT=/opt/CVS/
export MODWHEEL_AUTHOR=1
export GETOPTLL_AUTHOR=1
export FILEBSED_AUTHOR=1
export LIBGBSED_AUTHOR=1
export MODWHEEL_DBTEST=1
export CLASS_DOT_MODEL_AUTHOR=1
export CLASS_DOT_AUTHOR=1
export CONFIG_PLCONFIG_AUTHOR=1
export CLASSPLUGINUTIL_AUTHOR=1
export ALIEN_CODEPRESS_AUTHOR=1
export MODULE_BUILD_DEBIAN_AUTHOR=1
export XWA_AUTHOR="Ask Solem"
export XWA_AUTHOR_EMAIL="askh@opera.com"
export MACOSX_DEPLOYMENT_TARGET=10.5

if [ $IS_MAC_OS_X ]; then
    export MACOSX_DEPLOYMENT_TARGET="10.5"
fi

# PROMPT

HOSTNAME=$(hostname -s);
export PS1='$USER@${HOSTNAME:-localhost}:$PWD\$> '

# DEBIAN PACKAGE OPTIONS
export DEBEMAIL="askh@opera.com"
export DEBFULLNAME="Ask Solem"

# ALIASES

alias ls='/opt/local/bin/ls --color -F -h'
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
alias vim='mvim'
alias svim='sudo vim'
alias sapt='sudo apt-get install'
alias saps='sudo apt-cache search'
alias svi='svim'
alias pws='gpg --decrypt /opt/void/pwd.gpg'
alias s='sudo'
alias pypan='env MACOSX_DEPLOYMENT_TARGET=10.5 easy_install'
alias psyq='psyqueue'
alias psyf='psyfetch'
alias ptv='psyqueue tv'
alias pxvid='psyqueue xvid'
alias pmac='psyqueue mac'
alias paudio='psyqueue audioiso'
alias psample='psyqueue samplecd'
alias lsd='ls -clr | grep $(date "+%Y-%m") | sort -k 6 -r'


# MIT Scheme settings.
export MITSCHEME_LIBRARY_PATH=/opt/local/lib/mit-scheme


export PERL5LIB="$PERL5LIB:/opt/devel/my:/opt/devel/core-mods"

# STARTUP EXEC

echo
echo "                          [ Welcome to $OS_GREETING @$MACHTYPE ]"
echo

# mail
mail_bin=$(whereis mail)
test -f "$mail_bin" -a -x "$mail_bin" && $mail_bin
echo

# ### INITIALIZE ENVIRONMENT

# Setting PATH for MacPython 2.5
# The orginal version is saved in .profile.pysave
unshift_path "/Library/Frameworks/Python.framework/Versions/Current/bin"

# Common LISP
unshift_path "/opt/lisp/bin"

# git
unshift_path "/opt/git/bin"

if [ ! $IS_MAC_OS_X ]; then
    export DISPLAY=":0"
fi

# Development Environment
LIBPATHS="-L/opt/perl-5.10/lib -L/opt/postgres/lib -L/opt/local/lib -L/opt/mysql/lib -L/sw/lib"
INCPATHS="-I/opt/local/include -I/opt/postgres/include -I/sw/include -I/opt/mysql/include"

# BerkeleyDB
LIBPATHS="-L/opt/BerkeleyDB/lib $LIBPATHS"
INCPATHS="-I/opt/BerkeleyDB/include $INCPATHS"
export PATH="/opt/BerkeleyDB/bin:$PATH"
export LDFLAGS="$LIBPATHS"
CFLAGS="-Os -sse3 -ssse3 -mtune=nocona"
export CFLAGS="$LIBPATHS $INCPATHS $CFLAGS"

## PostgreSQL
export PGDATA="/opt/postgres/data"

# MzScheme
export PATH="/opt/mzscheme/bin:$PATH"
export LDFLAGS="-L/opt/mzscheme/lib $LDFLAGS"
export CFLAGS="-I/opt/mzscheme/include $CFLAGS"

# Glascow Haskell Compiler
export PATH="/opt/haskell/bin:$PATH"

# MacTex
export PATH="/opt/mactex/bin:$PATH"

# Git
export PATH="/opt/git/bin:$PATH"
#

if [ $IS_MAC_OS_X ]; then
    # Build programs for these architectures
    export ARCHFLAGS='-arch i386 -arch x86_64'
fi


# ### Currently selected Perl first!
unshift_path "/opt/perl/bin/perl"

export EMAIL="ask@0x61736b.net"

# git stuff
export GIT_AUTHOR_NAME="Ask Solem"
export GIT_AUTHOR_EMAIL="asksh@cpan.org"

# IDA Pro
export PATH+=":/opt/ida/bin"

# Delete duplicate PATH components.
PATH=`
    perl -le'for(split m/:/,shift){push@_,$_ if!$s{$_}++};print join":",@_' "$PATH"
`;
export PATH
