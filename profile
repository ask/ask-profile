#!/bin/bash
# ask@0x61736b.net

LivingProfilePrefix="$HOME/.living-profile"
LivingShellProfile="$LivingProfilePrefix/shell"

throw() {
    printf "ERROR: $1\n" >/dev/stderr
    exit 1
}
warn() {
    printf "WARNING: $1\n" >/dev/stderr
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

include_startup_script () {
    script="$1"
    if [ -f "$script" -a -x "$script" ]; then
        source "$script"
    fi
}

include_startup_script "$BASH_PROFILE"
include_startup_script "$BASH_RC"

# LOCALE

export LOCALE="en_GB.UTF-8"
export LC_ALL=$LOCALE

# PATH
PATH="/opt/bleadperl/bin:$PATH"
PATH="/Developer/Tools:$PATH"
PATH="/usr/local/bin:/usr/local/sbin:$PATH"
PATH="/Applications:$PATH"
for sbin_dir in /opt/*/sbin; do
    PATH="$sbin_dir:$PATH"
done
for bin_dir  in /opt/*/bin;  do
    PATH="$bin_dir:$PATH"
done

PATH=$PATH:/usr/local/mysql/bin
PATH=$PATH:/usr/local/BerkeleyDB.4.5/bin/
export PATH;

# MANPATH
for man_dir  in /opt/*/man;  do
    MANPATH="$man_dir:$MANPATH"
done
MANPATH=$MANPATH:/opt/lighttpd/share/man
export MANPATH

# ENVIRONMENT

# Use vim as the man pager.
export MANPAGER="col -b | view -c 'set ft=man nomod nolist' -" 
export EDITOR=vim
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

if [ $IS_MAC_OS_X ]; then
    export MACOSX_DEPLOYMENT_TARGET="10.5"
fi

# PROMPT

HOSTNAME=$(hostname -s);
export PS1='$USER@${HOSTNAME:-localhost}:$PWD\$> '

# ALIASES

alias vim='mvim'
alias ls='/opt/local/bin/ls --color -F -h'
alias psa='ps auxww'
alias grepi='grep -i'
alias egrepi='grep -Ei'
alias gps='ps auxww | grepi '
alias metafoo='meta foo -ws 16'
alias metaa='meta any -ws 16'
alias lst='ls -t --reverse'

# MIT Scheme settings.
export MITSCHEME_LIBRARY_PATH=/opt/local/lib/mit-scheme

# Delete duplicate PATH components.
PATH=`
    perl -E'for(split m/:/,shift){push@_,$_ if!$s{$_}++};say join":",@_' "$PATH"
`;
export PATH

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

export PATH="/bin:/usr/bin:/usr/local/bin:~/bin:${PATH}"
#export MANPATH="/usr/share/man"

# #### GO CREATE CUSTOM ENVIRONMENT

# todo.sh
#test -f /opt/local/bin/t -a -x /opt/local/bin/t && /opt/local/bin/t list
#echo

# Setting PATH for MacPython 2.5
# The orginal version is saved in .profile.pysave
PATH="/Library/Frameworks/Python.framework/Versions/Current/bin:${PATH}"
export PATH

# Common LISP
#export PATH="/opt/lisp/bin:$PATH"

##
# DELUXE-USR-LOCAL-BIN-INSERT
# (do not remove this comment)
##
#echo $PATH | grep -q -s "/usr/local/bin"
#if [ $? -eq 1 ] ; then
#    PATH=$PATH:/usr/local/bin
#    export PATH
#fi

# ### Currently selected Perl first!
export PATH="/opt/perl/bin/perl:$PATH"

alias boa='python'
alias suroot='sudo su -l -'

export EMAIL="ask@0x61736b.net"

##
# Your previous /Users/ask/.profile file was backed up as /Users/ask/.profile.mpsaved_2008-07-30_at_19:47:58
##

# MacPorts setting on 2008-07-30 at 19:47:58: adding an appropriate MANPATH variable for use with MacPorts.
export MANPATH=/opt/local/share/man:$MANPATH
# Finished adapting your MANPATH environment variable for use with MacPorts.

