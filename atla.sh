# vi: ts=4 sts=4 shiftwidth=4 expandtab 
# filename      : atla.sh
# DESCRIPTION   : Dizin Atla_X
# AUTHOR        : Young-gi Park <ghostyak@gmail.com>
# VERSION       : v0.5
# HISTORY       : 
#   - 2013-07-02 (v0.1): first release 
#   - 2013-10-09 (v0.2): speed optimization
#   - 2014-02-23 (v0.3): refactoring & update display & keymap
#   - 2014-02-28 (v0.4): support putty + screen environment
#   - 2014-03-01 (v0.5): support mac os
#

#
# If you are looking for the other key binding, you can use 'cat >/dev/null'
# command and press any key combinations.
#

## setting for the linux terminal
# CTRL + Up/Down/Right/Left Arrow
bind '"\e[1;5A":"atla_ctrl_up\C-m"' 2> /dev/null
bind '"\e[1;5B":"atla_ctrl_down\C-m"' 2> /dev/null
bind '"\e[1;5C":"atla_ctrl_right\C-m"' 2> /dev/null
bind '"\e[1;5D":"atla_ctrl_left\C-m"' 2> /dev/null

## setting for the putty
# CTRL + Up/Down/Right/Left Arrow
bind '"\eOA":"atla_ctrl_up\C-m"' 2> /dev/null
bind '"\eOB":"atla_ctrl_down\C-m"'  2> /dev/null
bind '"\eOC":"atla_ctrl_right\C-m"'  2> /dev/null
bind '"\eOD":"atla_ctrl_left\C-m"' 2> /dev/null

## setting for the screen in the putty
# ALT + Up/Down/Right/Left Arrow
bind '"\e\e[A":"atla_ctrl_up\C-m"' 2> /dev/null
bind '"\e\e[B":"atla_ctrl_down\C-m"'  2> /dev/null
bind '"\e\e[C":"atla_ctrl_right\C-m"'  2> /dev/null
bind '"\e\e[D":"atla_ctrl_left\C-m"' 2> /dev/null

export DJ_HOME=$HOME/.atla/
export DJ_FNAME_ABS=$DJ_HOME/dirlist
export DJ_FNAME_TEMP=$DJ_HOME/dirlist.tmp
export DJ_FNAME_SAVE=$DJ_HOME/dirlist.save
export DJ_FNAME_STACK=$DJ_HOME/dirlist.stack
export DJ_READLINK=$HOME/.atla/readlink.sh

# Brief: Print usage
# Usage: atla_print_usage
function atla_print_usage
{
    echo "atla - Dizin Atla_X";
    echo;
    echo "Usage: ";
    echo "    atla                 : print directories";
    echo "    atla [index]         : change directory by index";
    echo "    atla add             : add current directory";
    echo "    atla add [dir]       : add directory";
    echo "    atla rm              : remove current directory";
    echo "    atla rm [index]      : remove directory by index";
    echo "    atla save <filename> : save dir list into the file";
    echo "    atla load <filename> : load dir list from the file";
    echo "    atla clean           : clean the stack";
    echo "    atla help            : print usage";
    echo;
    echo "Key Map (normal):";
    echo "    CTRL + Up Arrow       : move previous";
    echo "    CTRL + Down Arrow     : move next";
    echo "    CTRL + Left Arrow     : jump down";
    echo "    CTRL + Right Arrow    : jump up";
    echo;
    echo "Key Map (putty + screen):";
    echo "    ALT + Up Arrow       : move previous";
    echo "    ALT + Down Arrow     : move next";
    echo "    ALT + Left Arrow     : jump down";
    echo "    ALT + Right Arrow    : jump up";
    echo;
    echo "Key Map (mac os):";
    echo "    ESC + Up Arrow       : move previous";
    echo "    ESC + Down Arrow     : move next";
    echo "    ESC + Left Arrow     : jump down";
    echo "    ESC + Right Arrow    : jump up";
    echo;
}

# Brief:
# Usage: atla_ctrl_up
function atla_ctrl_up
{
    # clear stack
    rm -f $atla_FNAME_STACK;

    # move previous directory
    clear;
    atla_prev;

    # print current dir list
    echo "[ Dizin Atla_X ]";
    echo;
    atla_dirs;
    
    # delete last history
    history -d $(($HISTCMD-1));
}

# Brief:
# Usage: atla_ctrl_down
function atla_ctrl_down
{
    # clear stack
    rm -f $atla_FNAME_STACK;
    
    # move next directory
    clear;
    atla_next;

    # print current dir list
    echo "[ Dizin Atla_X ]";
    echo;
    atla_dirs;

    # delete last history
    history -d $(($HISTCMD-1));
}

# Brief:
# Usage: atla_ctrl_left
function atla_ctrl_left
{
    is_direct_line=0;
    is_diffrent_line=1;

    clear;

    # discards stack
    grep "$PWD" $atla_FNAME_STACK > /dev/null 2>&1;
    if [ $? = $is_diffrent_line ]; then
        rm -f $atla_FNAME_STACK;
    fi

    atla_push_dir_into_stack;

    # go down
    cd ..;

    # print current dir
    echo    "[ Dizin Atla_X ]";
    echo;
    echo -e "    TOP: \033[7m`head -n1 $atla_FNAME_STACK`\033[27m";
    echo    "    PWD: $PWD";
    echo;
    echo    "(See 'atla help' for for information)";
    echo;

    # delete last history
    history -d $(($HISTCMD-1));
}

# Brief:
# Usage: atla_ctrl_right
function atla_ctrl_right
{
    clear;
    if [ -e $atla_FNAME_STACK ]; then

        # go up
        cd $(tail -n1 $atla_FNAME_STACK);

        # pop stack
        atla_pop_dir_from_stack;
    fi

    # print current dir
    echo "[ Dizin Atla_X ]";
    echo;
    if [ -e $atla_FNAME_STACK ]; then
        echo -e "    TOP: \033[7m`head -n1 $atla_FNAME_STACK`\033[27m";
    else
        echo -e "    TOP: \033[7m$PWD\033[27m";
    fi
    echo "    PWD: $PWD";
    echo;
    echo "(See 'atla help' for for information)";
    echo;

    # delete last history
    history -d $(($HISTCMD-1));
}


# Brief: Push a current directory into stack
# Usage: atla_push_dir_into_stack
function atla_push_dir_into_stack
{
    if [ -e $atla_FNAME_STACK ] \
        && [ $(tail -n1 $atla_FNAME_STACK) != $PWD ] \
        && [ $PWD != "/" ]; then
        echo $PWD >> $atla_FNAME_STACK;
    elif ! [ -e $atla_FNAME_STACK ]; then
        echo $PWD >> $atla_FNAME_STACK;
    fi
}

# Brief: Pop a last directory from stack
# Usage: atla_pop_dir_from_stack
function atla_pop_dir_from_stack
{
    # delete last line at $DJ_FNAME_STACK
    if [ -e $atla_FNAME_STACK ];then
        sed -itmp '$ d' $atla_FNAME_STACK
        rm -f $atla_FNAME_STACK"tmp"
    fi

    # if file size 0 then delete $atla_FNAME_STACK file
    ! [ -s $atla_FNAME_STACK ] && rm -f $atla_FNAME_STACK;
}

# Brief: Remove directories that is not exist
# Usage: atla_reload_only_exist_dir
function atla_reload_only_exist_dir
{
    rm -f $atla_FNAME_TEMP && touch $atla_FNAME_TEMP;
    ! [ -f $atla_FNAME_ABS ] && touch $atla_FNAME_ABS;

    while read line; do
        if [ -d $line ]; then
            echo "$line" >> $atla_FNAME_TEMP;
        fi
    done < <(cat $atla_FNAME_ABS)

    mv -f $atla_FNAME_TEMP $atla_FNAME_ABS;
}

# Brief: Display directory list
# Usage: atla_dirs
function atla_dirs
{
    LINE_COUNT=$(wc -l $atla_FNAME_ABS | awk '{print $1}');
    if [ "$LINE_COUNT" == "0" ]; then
        echo "(empty stack. 'atla --help')";
        return;
    fi

    atla_reload_only_exist_dir;

    while read line;
    do
        directory=$(echo $line | awk '{print $2}');

        #Point out current directory
        if [[ $PWD == $directory ]];then
            echo -e "    \033[7m$line\033[27m";
        else
            echo "    $line";
        fi
    done < <(cat -n $atla_FNAME_ABS)

    echo;
    echo "(See 'atla help' for for information)";
    echo;
}

# Brief:
# Usage:
function atla_add
{
    # Check param
    if ! test -d "$1"; then
        echo "error: Invalid parameter" 1>&2
        return 1;
    fi

    echo $($atla_READLINK $1) >> $atla_FNAME_ABS;
    atla_reload_only_exist_dir;

    sort -u $atla_FNAME_ABS -o $atla_FNAME_TEMP;
    mv -f $atla_FNAME_TEMP $atla_FNAME_ABS;

    return;
}

# Brief:
# Usage:
function atla_clean
{
    rm -f $atla_FNAME_ABS && touch $atla_FNAME_ABS;
}

# Brief: Save a directory list to the filepath.
# Usage: atla_save <filepath>
function atla_save
{
    # error handling
    [ "$#" = 0 ] && return 0;
    atla_reload_only_exist_dir;

    cp $atla_FNAME_ABS $1;
}

# Brief: Load a directory list from the filepath.
# Usage: atla_load <filepath>
function atla_load
{
    # error handling
    [ "$#" = 0 ] && return 0;

    cp $1 $atla_FNAME_ABS;

    # error handling
    atla_reload_only_exist_dir;
}

# Brief: Remove a directory.
# Usage: atla_rm <filepath>
function atla_rm
{
    # Check argument whether number.
    if [ ! $(echo $1 | sed -n '/^[0-9][0-9]*$/p') ]; then
        echo "error: Input number" 1>&2
        dj_print_usage;
        return;
    fi

    atla_reload_only_exist_dir;

    rm -f $atla_FNAME_TEMP && touch $atla_FNAME_TEMP;

    # Save all directoryes without target.
    while read line;
    do
        index=$(echo $line | awk '{print $1}');
        directory=$(echo $line | awk '{print $2}');
        [ "$index" -ne "$1" ] && echo $directory >> $atla_FNAME_TEMP;
    done < <(cat -n $atla_FNAME_ABS)

    mv -f $atla_FNAME_TEMP $atla_FNAME_ABS;

    return 0;
}

function atla_rm_by_dirname
{
    rm -f $atla_FNAME_TEMP && touch $atla_FNAME_TEMP;

    while read line;
    do
        if [[ ! "$line" == "$($atla_READLINK $1)" ]]; then
            echo "$line" >> $atla_FNAME_TEMP;
        fi
    done < <(cat $atla_FNAME_ABS)

    mv -f $atla_FNAME_TEMP $atla_FNAME_ABS;
}


function atla_next
{
    index_curr=0;

    atla_reload_only_exist_dir;

    while read line;
    do
        index=$(echo "$line" | awk '{print $1}')
        directory=$(echo $line | awk '{print $2}')

        if [[ $PWD == $directory ]];then
            index_curr=$index;
        fi
    done < <(cat -n $atla_FNAME_ABS)

    index_curr=$(expr $index_curr + 1);
    index_end=$(wc -l $atla_FNAME_ABS | awk '{print $1}');

    #roll back
    if [ $index_curr -gt $index_end ]; then
        index_curr=1;
    fi

    #change directory
    dj_go $index_curr;
    return 0;
}

function atla_prev
{
    index_curr=0;

    atla_reload_only_exist_dir;

    while read line;
    do
        index=$(echo $line | awk '{print $1}');
        directory=$(echo $line | awk '{print $2}');

        if [[ $PWD == $directory ]];then
            index_curr=$index;
        fi

    done < <(cat -n $atla_FNAME_ABS)

    index_curr=$(expr $index_curr - 1);
    index_end=$(wc -l $atla_FNAME_ABS | awk '{print $1}');

    #roll back
    if [ $index_curr -lt 1 ]; then
        index_curr=$index_end;
    fi

    #change directory
    atla $index_curr;
    return 0;
}

# Brief: Change a current directory using index
# Usage: atla_go <index>
function atla_go
{
    # Check argument whether number.
    if [ ! $(echo $1 | sed -n '/^[0-9][0-9]*$/p') ]; then
        atla_print_usage;
        return;
    fi

    # get directory by index
    DJ_TARGET=$(cat -n $atla_FNAME_ABS | grep "^[[:space:]]*$1[[:space:]]" | awk '{print $2}');

    # go
    ! [ -z $atla_TARGET ] && cd $atla_TARGET;
}

function atla
{
    if [ ! -f $atla_FNAME_ABS ]; then
        touch $atla_FNAME_ABS
    fi

    case $1 in

        "")
            atla_dirs;
            ;;

    help)
        atla_print_usage;
        ;;

    add)
        if [ $# -gt 2 ]; then
            atla_print_usage;
            return;
        fi
        if [[ $# == 1 ]]; then
            atla_add "."
        else
            atla_add $2
        fi
        ;;

    rm)
        if [ $# -gt 2 ]; then
            atla_print_usage;
            return;
        elif [ $# -eq 1 ]; then
            atla_rm_by_dirname ".";
        elif [ $# -eq 2 ]; then
            atla_rm $2;
        fi
        ;;

    next)
        if [ $# -gt 1 ]; then
            atla_print_usage;
            return;
        fi
        atla_next $2;
        ;;

    prev)
        if [ $# -gt 1 ]; then
            atla_print_usage;
            return;
        fi
        atla_prev $2;
        ;;

    clean)
        if [ $# -gt 1 ]; then
            atla_print_usage;
            return;
        fi
        atla_clean;
        ;;

    save)
        if [ $# -gt 2 ]; then
            atla_print_usage;
            return;
        fi
        atla_save $2;
        ;;

    load)
        if [ $# -gt 2 ]; then
            atla_print_usage;
            return;
        fi
        atla_load $2;
        ;;

    *)
        atla_go $1
        ;;
        
    esac
}
