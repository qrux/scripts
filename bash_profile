##################################################
#
# Global Aliases
#
##################################################

echo "Determining system..."

_SYSTEM=$(uname -s)

echo "Customizing for ${_SYSTEM} system."

find_darwin_major ()
{
	echo $(uname -r | cut -d \. -f 1)
}

if [ "xterm-256color" = $TERM ] ; then
        if [ "Darwin" = $_SYSTEM ] ; then
                if [ "10" = $(find_darwin_major) ] ; then
                        echo "  Changing terminal-type to xterm-color."
                        TERM="xterm-color"
                        export TERM
                fi
        fi
fi

LANG="en_US.UTF-8"
export LANG

path () 
{ 
    if test -x /usr/bin/$1; then
        ${1+"/usr/bin/$@"};
    else
        if test -x /bin/$1; then
            ${1+"/bin/$@"};
        fi;
    fi
}

_bred="$(path tput bold 2> /dev/null; path tput setaf 1 2> /dev/null)"
_byel="$(path tput bold 2> /dev/null; path tput setaf 3 2> /dev/null)"
_bgrn="$(path tput bold 2> /dev/null; path tput setaf 2 2> /dev/null)"
_sgr0="$(path tput sgr0 2> /dev/null)"

function timer_start {
  timer=${timer:-$SECONDS}
}

function timer_stop {
  timer_show=$(($SECONDS - $timer))
  unset timer
}

trap 'timer_start' DEBUG
PROMPT_COMMAND=timer_stop

PS1_TIMER_PREFIX='{${timer_show}s}'

#PS1_PREFIX="(\D{%d %b}, \t) \h"
PS1_PREFIX="$PS1_TIMER_PREFIX \h"

if [ $UID = 0 ] ; then
        PS1="${PS1_PREFIX} [\w] # "
        PS1="\[$_bred\]$PS1\[$_sgr0\]"
elif [ $UID -lt 100 ] ; then
        PS1="${PS1_PREFIX} [\w] > "
        PS1="\[$_byel\]$PS1\[$_sgr0\]"
else
        PS1="${PS1_PREFIX} [\w] $ "
        PS1="\[$_bgrn\]$PS1\[$_sgr0\]"
fi
export PS1

unset _bred _bgrn _sgr0

#
# Are we on a Mac?  If so, change the LANG setting
# (so we have full UTF-8 capabilities).
#
_BIN_LS="/bin/ls"
if [ "Darwin" = ${_SYSTEM} ] ; then
	LS="/bin/ls -G -F" ; export LS
	LS_FLAGS="-G -F"
	export LSCOLORS="DxGxcxdxCxegedabagacad"
elif [ "Linux" = ${_SYSTEM} ] ; then
	LS="/bin/ls --color -F -N -T 0" ; export LS
	LS_FLAGS="--color -F -N -T 0"
	if [ -z $LS_COLORS ] ; then
		export LS_COLORS="di=93"
	else
		export LS_COLORS="$LS_COLORS:di=93"
	fi
else
	LS="/bin/ls -F"
	LS_FLAGS="-F"
fi

LS="${_BIN_LS} ${LS_FLAGS}"
export LS


alias ls="${LS} -C"
alias la="${LS} -aC"
alias lr="${LS} -aCR"

alias dir="${LS} -l"
alias dira="${LS} -al"
alias dirr="${LS} -alR"
alias dirt="${LS} -lrt"
alias dirah="${LS} -alh"
alias dirrah="${LS} -Ralh"
alias diraht="${LS} -alhrt"

alias mv='/bin/mv -i'
alias cp='/bin/cp -i'

alias j="jobs"
alias today="date '+%-d %b %Y'"
alias todate="date '+%Y%m%d'"
alias totime="date '+%Y%m%d_%H%M%S'"

#
# Berkeley Exit Function
#
.()
{
	SCRIPT=$1
	if [ -z $SCRIPT ] ; then
		exit
	else
		source $SCRIPT
	fi
}

#
# h
#
h()
{
        PATTERN=$1

        if [ "$PATTERN" = "" ] ; then
                history
        else
                history | grep $PATTERN
        fi
}

#
# kill something process
#
killproc ()
{
	kill `ps aux | grep "${1}" | grep -v grep | awk '{print $2}'`
}

#
# hidden grep
#
_grep()
{
	grep "${@}"
}

#
# ps
#
p ()
{
	ARGS="${*}"

	if [ "$ARGS" = "" ] ; then
		if [ ${_SYSTEM} = "SunOS" ] ; then
			/bin/ps -ef | sort
		elif [ ${_SYSTEM} = "Linux" ] ; then
			/bin/ps axo user,pid,vsz,rsz,%mem,cmd --sort=vsize | grep -v grep
		elif [ ${_SYSTEM} = "Darwin" ] ; then
			/bin/ps axo user,pid,vsz,rss,%mem,command -m | sed 's/\ *$//' | grep -v grep
		else
			/bin/ps aux | sort
		fi
	else
		if [ ${_SYSTEM} = "SunOS" ] ; then
			/bin/ps -ef | egrep "$ARGS" | grep -v grep | sort
		elif [ ${_SYSTEM} = "Linux" ] ; then
			/bin/ps axo user,pid,vsz,rsz,%mem,cmd --sort=vsize | egrep "$ARGS" | grep -v grep
		elif [ ${_SYSTEM} = "Darwin" ] ; then
			/bin/ps axo user,pid,vsz,rss,%mem,command -m | sed 's/\ *$//' | egrep "$ARGS" | grep -v grep
		else
			/bin/ps aux | egrep "$ARGS" | grep -v grep | sort
		fi
	fi

}

#
# df  -  Need this because Mac OS X/Darwin has stupid mountpoints for some apps.
#
df ()
{
	ARGS="${*}";
	if [ "$ARGS" = "" ]; then
		if [ ${_SYSTEM} = "Darwin" ]; then
			 /bin/df -Phl;
		else
			/bin/df -h;
		fi;
	fi
}

#
# ps | grep -v
#
pv ()
{
	ARGS="${*}"

	if [ ${_SYSTEM} = "SunOS" ] ; then
		/bin/ps -ef | egrep -v "$ARGS" | grep -v grep
	elif [ ${_SYSTEM} = "Linux" ] ; then
		/bin/ps axo user,pid,vsz,rsz,%mem,cmd --sort=vsize | egrep -v "$ARGS" | grep -v grep
	elif [ ${_SYSTEM} = "Darwin" ] ; then
		/bin/ps axo user,pid,vsz,rss,%mem,command -m | sed 's/\ *$//' | egrep -v "$ARGS" | grep -v grep
	else
		/bin/ps aux | egrep -v "$ARGS" | grep -v grep
	fi
}

#
# ps | grep "${USER}"
#
pme ()
{
	p "${USER}"
}

#
# POSIX man behavior
#
export MAN_POSIXLY_CORRECT=1

if [ -d /opt/local/bin ] ; then
	# MacPorts Installer addition: adding an appropriate PATH variable for use with MacPorts.
	export PATH="/opt/local/bin:/opt/local/sbin:$PATH"
	# Finished adapting your PATH environment variable for use with MacPorts.
fi

#
# Personal bin
#
if [ -d $HOME/bin ] ; then
	PATH=$HOME/bin:$PATH
fi

#
# .personal
#
PERSONAL_ALIAS=".alias-$USER"

if [ -e $HOME/.alias-$USER ] ; then
	. $HOME/.alias-$USER
fi

unset PERSONAL_ALIAS


