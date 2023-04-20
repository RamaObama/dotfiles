if [[ "$OSTYPE" == "darwin"* ]]; then
    {
        gdate
    } || {
        echo "\n$fg_bold[yellow]passion.zsh-theme depends on cmd [gdate] to get current time in milliseconds$reset_color"
        echo "$fg_bold[yellow][gdate] is not installed by default in macOS$reset_color"
        echo "$fg_bold[yellow]to get [gdate] by running:$reset_color"
        echo "$fg_bold[magenta]brew install coreutils;$reset";
    }
fi

# time
function real_time() {
    local color="%{$fg_no_bold[cyan]%}";
    local time="[$(date +%H:%M:%S)]";
    local color_reset="%{$reset_color%}";
    echo "${color}${time}${color_reset}";
}

# login_info
function login_info() {
    local color="%{$fg_no_bold[cyan]%}";
    local ip
    if [[ "$OSTYPE" == "linux-gnu" ]]; then
        # Linux
        ip="$(ifconfig | grep ^eth1 -A 1 | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' | head -1)";
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        ip="$(ifconfig | grep ^en1 -A 4 | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' | head -1)";
    fi
    local color_reset="%{$reset_color%}";
    echo "${color}[%n@${ip}]${color_reset}";
}


# directory
function directory() {
    local color="%{$fg_no_bold[cyan]%}";
    local directory="${PWD/#$HOME/~}";
    local color_reset="%{$reset_color%}";
    echo "${color}[${directory}]${color_reset}";
}


# git
ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_no_bold[magenta]%}[";
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} ";
ZSH_THEME_GIT_PROMPT_DIRTY=" %{$fg_no_bold[red]%}●%{$fg_no_bold[magenta]%}]";
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg_no_bold[cyan]%}]";

function update_git_status() {
    GIT_STATUS=$(git_prompt_info);
}

function git_status() {
    echo "${GIT_STATUS}"
}


# command
function update_command_status() {
    local arrow="";
    local color_reset="%{$reset_color%}";
    local reset_font="%{$fg_no_bold[white]%}";
    COMMAND_RESULT=$1;
    export COMMAND_RESULT=$COMMAND_RESULT
    if $COMMAND_RESULT;
    then
        arrow="%{$fg_bold[red]%}❱%{$fg_bold[magenta]%}❱%{$fg_bold[green]%}❱";
    else
        arrow="%{$fg_bold[red]%}❱❱❱";
    fi
    COMMAND_STATUS="${arrow}${reset_font}${color_reset}";
}
update_command_status true;

function command_status() {
    echo "${COMMAND_STATUS}"
}


# output command execute after
output_command_execute_after() {
    if [ "$COMMAND_TIME_BEGIN" = "-20200325" ] || [ "$COMMAND_TIME_BEGIN" = "" ];
    then
        return 1;
    fi

    # cmd
    local cmd="$(fc -ln -1)";
    local color_cmd="";
    if $1;
    then
        color_cmd="$fg_no_bold[green]";
    else
        color_cmd="$fg_bold[red]";
    fi
    local color_reset="$reset_color";
    cmd="${color_cmd}${cmd}${color_reset}"

    # time
    local time="[$(date +%H:%M:%S)]"
    local color_time="$fg_no_bold[cyan]";
    time="${color_time}${time}${color_reset}";

    # cost
    local time_end="$(current_time_millis)";
    local cost=$(bc -l <<<"${time_end}-${COMMAND_TIME_BEGIN}");
    COMMAND_TIME_BEGIN="-20200325"
    local length_cost=${#cost};
    if [ "$length_cost" = "4" ];
    then
        cost="0${cost}"
    fi
    cost="[cost ${cost}s]"
    local color_cost="$fg_no_bold[cyan]";
    cost="${color_cost}${cost}${color_reset}";

    echo -e "${time} ${cost} ${cmd}";
    echo -e "";
}


# command execute before
preexec() {
    COMMAND_TIME_BEGIN="$(current_time_millis)";
}

current_time_millis() {
    local time_millis;
    if [[ "$OSTYPE" == "linux-gnu" ]]; then
        # Linux
        time_millis="$(date +%s.%3N)";
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        time_millis="$(gdate +%s.%3N)";
    fi
    echo $time_millis;
}


# command execute after
precmd() {
    # last_cmd
    local last_cmd_return_code=$?;
    local last_cmd_result=true;
    if [ "$last_cmd_return_code" = "0" ];
    then
        last_cmd_result=true;
    else
        last_cmd_result=false;
    fi

    # update_git_status
    update_git_status;

    # update_command_status
    update_command_status $last_cmd_result;

    # output command execute after
    output_command_execute_after $last_cmd_result;
}


# set option
setopt PROMPT_SUBST;


# timer
TMOUT=1;
TRAPALRM() {
    if [ "$WIDGET" = "" ] || [ "$WIDGET" = "accept-line" ] ; then
        zle reset-prompt;
    fi
}


# prompt
PROMPT='$(real_time) $(login_info) $(directory) $(git_status)$(command_status) ';
PROMPT='$(real_time) $(directory) $(git_status)$(command_status) ';