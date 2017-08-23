export LANG=en_CA.UTF-8
export XMLLINT_INDENT="	"
export HISTFILESIZE=100000
export HISTSIZE=10000
export HISTCONTROL=ignoredups:erasedups
shopt -s histappend direxpand
tabs -4 2>/dev/null || true
alias less="less -x4 -R"

color_black='0;30'
color_darkGray='1;30'
color_blue='0;34'
color_lightBlue='1;34'
color_green='0;32'
color_lightGreen='1;32'
color_cyan='0;36'
color_lightCyan='1;36'
color_red='0;31'
color_lightRed='1;31'
color_purple='0;35'
color_lightPurple='1;35'
color_brown='0;33'
color_yellow='1;33'
color_lightGray='0;37'
color_white='1;37'

COMMON_SETUP=$HOME/common_setup
BASEPATH=${BASEPATH:-${PATH}}
PATH=$COMMON_SETUP/scripts:$BASEPATH

# PS1="\[\e]0;\w\a\]\n\A \[\e[32m\]\u@\h \[\e[33m\]\w\[\e[0m\]\n\$ "
PS1="\[\e]0;\W (\h)\a\]\n\[\e[${color_cyan}m\]\A \[\e[${color_green}m\]\u@\h \[\e[${color_brown}m\]\w\[\e[${color_red}m\]\n\\\$ \[\e[m\]"

alias cgrep="grep -E --exclude-dir='*.svn' --exclude-dir='.metadata' --exclude='*.class' --exclude='*.jar' --exclude='*.war' --exclude='*.ear' --exclude='*.log' --exclude='*.log.*'"
alias disable_move_key_repeat='for k in 25 38 39 40; do xset -r $k; done'

function collatePDF {
odd="$1"
even="$2"
output="$3"
if [[ -z "$output" ]]
then
	output=$(echo "$1" | sed -r 's/(.+)_\w+.pdf/\1.pdf/')
fi
if [[ -z "$odd" || -z "$even" || -z "$output" || "$output" == "$odd" ]]
then
	echo "invalid input odd=$odd even=$even output=$output" >&2
	return 1;
fi
if [ -e "$output" ]
then
	echo "file $output exists, not overwriting" >&2
	return 1;
fi
echo $output
pdftk A="$odd" B="$even" shuffle A Bend-1south output "$output"
}

function git_stash_reverse() {
	git stash show -p | git apply --reverse	
}

function clean_downloads {
	find $HOME/Downloads -mindepth 1 -maxdepth 1 -mtime +90 -exec rm -rf {} \;
}

SSH_ENV="$HOME/.ssh/environment"

function start_agent {
	echo "Initialising new SSH agent..."
	/usr/bin/ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
	echo succeeded
	chmod 600 "${SSH_ENV}"
	. "${SSH_ENV}" > /dev/null
	/usr/bin/ssh-add;
}

# Source SSH settings, if applicable
if [ -z "${DISPLAY}" ]
then
	if [ -f "${SSH_ENV}" ]
	then
		. "${SSH_ENV}" > /dev/null
		#ps ${SSH_AGENT_PID} doesn't work under cywgin
		ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || {
		start_agent;
	}
	else
		start_agent;
	fi
fi

if [ -r $HOME/.bash_local ]
then
	. $HOME/.bash_local
fi

wine_disassociate() {
	find $HOME/.local/share/applications -name "wine-extension-*" | grep -Ev -e '\b(acsm|azw|azw4|vbs|odm)\b' | xargs rm
}

svn_mv_after() {
	if ! [ -e "$2" ]; then 
		echo "non-existent destination, check order" 1>&2
		return
	fi
	if [ -e "$1" ]; then
		echo "source exists, correct" 1>&2
		return
	fi
	mv "$2" "$1"
	svn mv "$1" "$2"
}

zip_summarize() {
	unzip -lv "$1" | tr -s ' ' | cut -d' ' -f8,9 | tail -n+4 | sort -k2
}
