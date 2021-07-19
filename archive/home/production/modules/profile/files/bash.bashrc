# /etc/bashrc

# System wide functions and aliases
# Environment stuff goes in /etc/profile

# By default, we want this to get set.
# Even for non-interactive, non-login shells.
if [ $UID -gt 99 ] && [ "`id -gn`" = "`id -un`" ]; then
	umask 002
else
	umask 022
fi



# are we an interactive shell?
if [ "$PS1" ]; then
#    case $TERM in
#	xterm*)
#		if [ -e /etc/sysconfig/bash-prompt-xterm ]; then
#			PROMPT_COMMAND=/etc/sysconfig/bash-prompt-xterm
#		else
#	    	PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/~}"; echo -ne "\007"'
#		fi
#		;;
#	screen)
#		if [ -e /etc/sysconfig/bash-prompt-screen ]; then
#			PROMPT_COMMAND=/etc/sysconfig/bash-prompt-screen
#		else
#		PROMPT_COMMAND='echo -ne "\033_${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/~}"; echo -ne "\033\\"'
#		fi
#		;;
#	*)
#		[ -e /etc/sysconfig/bash-prompt-default ] && PROMPT_COMMAND=/etc/sysconfig/bash-prompt-default
#	    ;;
#    esac

if [ "$USER" = "root" ]; then
    USRCOL="\[\033[0;31m\]"
    USRPROMPTSIGN="\[\033[0;31m\]#"
  else
    USRCOL="\[\033[0;32m\]"
    USRPROMPTSIGN="\[\033[0;32m\]>"
fi

PROMPT_COMMAND='RES=$?; [[ ${RES} -eq 0 ]] && RCCOL=32 || RCCOL=31 ;PS1=`echo -ne "${USRCOL}\u\[\033[0m\]@\[\033[0;32m\]\h\[\033[0m\]:\[\033[1;34m\]\w\[\033[0m\][\[\033[0;${RCCOL}m\]${RES}\[\033[0m\]]${USRPROMPTSIGN} \[\033[0m\]"`'


    # Turn on checkwinsize
    shopt -s checkwinsize
    [ "$PS1" = "\\s-\\v\\\$ " ] && PS1="[\u@\h \W]\\$ "
fi

if ! shopt -q login_shell ; then # We're not a login shell
	# Need to redefine pathmunge, it get's undefined at the end of /etc/profile
    pathmunge () {
		if ! echo $PATH | /bin/egrep -q "(^|:)$1($|:)" ; then
			if [ "$2" = "after" ] ; then
				PATH=$PATH:$1
			else
				PATH=$1:$PATH
			fi
		fi
	}

	# Only display echos from profile.d scripts if we are no login shell
    # and interactive - otherwise just process them to set envvars
    for i in /etc/profile.d/*.sh; do
        if [ -r "$i" ]; then
            if [ "$PS1" ]; then
                . $i
            else
                . $i >/dev/null 2>&1
            fi
        fi
    done

	unset i
	unset pathmunge
fi
if [ -f ~/.ssh/known_hosts ]
	then 
	complete -W "$(echo `cat ~/.ssh/known_hosts | cut -f 1 -d ' ' | sed -e s/,.*//g | uniq | grep -v "\["`;)" ssh
	complete -W "$(echo `cat ~/.ssh/known_hosts | cut -f 1 -d ' ' | sed -e s/,.*//g | uniq | grep -v "\["`;)" ping

fi

export CDPATH=.:~:/local0

alias ll='ls -l'
alias la='ls -la'
alias lt='ls -ltr'
alias l='ls -lA'
alias pa='puppet agent -t'

export TZ='Europe/Zurich' 
