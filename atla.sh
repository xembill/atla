# vi: ts=4 sts=4 shiftwidth=4 expandtab 
# filename      : atla.sh
# DESCRIPTION   : Dizin Atla_X
# AUTHOR        : Seçkin KILINÇ <seckinkilincc@gmail.com>
# VERSION       : v0.1
# HISTORY       : 
#   - 24.04.2015 (v0.1): İlk Sürüm 
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

export ATLA_HOME=$HOME/.atla/
export ATLA_FNAME_ABS=$ATLA_HOME/dirlist
export ATLA_FNAME_TEMP=$ATLA_HOME/dirlist.tmp
export ATLA_FNAME_SAVE=$ATLA_HOME/dirlist.save
export ATLA_FNAME_STACK=$ATLA_HOME/dirlist.stack
export ATLA_READLINK=$HOME/.atla/readlink.sh

# Brief: Print usage
# Usage: atla_print_usage
function atla_print_usage
{
    echo "atla - Dizin Atla_X";
    echo;
    echo "[ Seçkin KILINÇ <seckinkilincc@gmail.com>]";
	echo;
    echo "[seckinkilinc.tk>]";
    echo;
    echo "Dizin Atlama Basit Script Kullanım Kılavuzu";
    echo;
    echo "Kullanım: ";
    echo "    atla                 : Dizini Yazar";
    echo "    atla [index]         : Dizini Index Ayarlar";
    echo "    atla add             : Bulunduğun Dizini Ekler";
    echo "    atla add [dir]       : Dizin Ekler";
    echo "    atla rm              : Bulunduğun Dizini Siler";
    echo "    atla rm [index]      : Index Dizinini Siler";
    echo "    atla save <filename> : Ayarları Dosyaya Yazar";
    echo "    atla load <filename> : Ayarları Dosyadan Alır";
    echo "    atla clean           : Herşeyi Siler";
    echo "    atla help            : Kullanım Klavuzu";
    echo;
    echo "Key Map (normal):";
    echo "    CTRL + Yukarı OK       : Öncekine Atlar";
    echo "    CTRL + Aşağı OK     : Sonrakine Atlar";
    echo "    CTRL + Sol OK     : Aşağı Atlar";
    echo "    CTRL + Sağ OK    : Yukarı Atlar";
    echo;
    echo "Key Map (putty + screen):";
    echo "    ALT + Yukarı OK       :  Öncekine Atlar";
    echo "    ALT + Aşağı OK     : Sonrakine Atlar";
    echo "    ALT + Sol OK     : Aşağı Atlar";
    echo "    ALT + Sağ OK    : Yukarı Atlar";
    echo;
    echo "Key Map (mac os):";
    echo "    ESC + Yukarı OK       :Öncekine Atlar";
    echo "    ESC + Aşağı OK     : Sonrakine Atlar";
    echo "    ESC + Sol OK     : Aşağı Atlar";
    echo "    ESC + Sağ OK    : Yukarı Atlar";
    echo;
}

# Brief:
# Usage: atla_ctrl_up
function atla_ctrl_up
{
    # clear stack
    rm -f $ATLA_FNAME_STACK;

    # move previous directory
    clear;
    atla_prev;

    # print current dir list
    echo "[ Dizin Atla_X ]";
	echo;
    echo "[ Seçkin KILINÇ <seckinkilincc@gmail.com>]";
	echo;
    echo "[seckinkilinc.tk>]";
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
    rm -f $ATLA_FNAME_STACK;
    
    # move next directory
    clear;
    atla_next;

    # print current dir list
    echo "[ Dizin Atla_X ]";
	echo;
    echo "[ Seçkin KILINÇ <seckinkilincc@gmail.com>]";
	echo;
    echo "[seckinkilinc.tk>]";
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
    grep "$PWD" $ATLA_FNAME_STACK > /dev/null 2>&1;
    if [ $? = $is_diffrent_line ]; then
        rm -f $ATLA_FNAME_STACK;
    fi

    atla_push_dir_into_stack;

    # go down
    cd ..;

    # print current dir
    echo "[ Dizin Atla_X ]";
	echo;
    echo "[ Seçkin KILINÇ <seckinkilincc@gmail.com>]";
	echo;
    echo "[seckinkilinc.tk>]";
    echo;
    echo -e "    TOP: \033[7m`head -n1 $atla_FNAME_STACK`\033[27m";
    echo    "    PWD: $PWD";
    echo;
    echo    "(Daha Fazla Bilgi İçin 'atla help' yazabilirsiniz.)";
    echo;

    # delete last history
    history -d $(($HISTCMD-1));
}

# Brief:
# Usage: atla_ctrl_right
function atla_ctrl_right
{
    clear;
    if [ -e $ATLA_FNAME_STACK ]; then

        # go up
        cd $(tail -n1 $ATLA_FNAME_STACK);

        # pop stack
        atla_pop_dir_from_stack;
    fi

    # print current dir
    echo "[ Dizin Atla_X ]";
	echo;
    echo "[ Seçkin KILINÇ <seckinkilincc@gmail.com>]";
	echo;
    echo "[seckinkilinc.tk>]";
    echo;
    if [ -e $ATLA_FNAME_STACK ]; then
        echo -e "    TOP: \033[7m`head -n1 $ATLA_FNAME_STACK`\033[27m";
    else
        echo -e "    TOP: \033[7m$PWD\033[27m";
    fi
    echo "    PWD: $PWD";
    echo;
    echo    "(Daha Fazla Bilgi İçin 'atla help' yazabilirsiniz.)";
    echo;

    # delete last history
    history -d $(($HISTCMD-1));
}


# Brief: Push a current directory into stack
# Usage: atla_push_dir_into_stack
function atla_push_dir_into_stack
{
    if [ -e $ATLA_FNAME_STACK ] \
        && [ $(tail -n1 $ATLA_FNAME_STACK) != $PWD ] \
        && [ $PWD != "/" ]; then
        echo $PWD >> $ATLA_FNAME_STACK;
    elif ! [ -e $ATLA_FNAME_STACK ]; then
        echo $PWD >> $ATLA_FNAME_STACK;
    fi
}

# Brief: Pop a last directory from stack
# Usage: atla_pop_dir_from_stack
function atla_pop_dir_from_stack
{
    # delete last line at $ATLA_FNAME_STACK
    if [ -e $ATLA_FNAME_STACK ];then
        sed -itmp '$ d' $ATLA_FNAME_STACK
        rm -f $ATLA_FNAME_STACK"tmp"
    fi

    # if file size 0 then delete $ATLA_FNAME_STACK file
    ! [ -s $ATLA_FNAME_STACK ] && rm -f $ATLA_FNAME_STACK;
}

# Brief: Remove directories that is not exist
# Usage: atla_reload_only_exist_dir
function atla_reload_only_exist_dir
{
    rm -f $ATLA_FNAME_TEMP && touch $ATLA_FNAME_TEMP;
    ! [ -f $ATLA_FNAME_ABS ] && touch $ATLA_FNAME_ABS;

    while read line; do
        if [ -d $line ]; then
            echo "$line" >> $ATLA_FNAME_TEMP;
        fi
    done < <(cat $ATLA_FNAME_ABS)

    mv -f $ATLA_FNAME_TEMP $ATLA_FNAME_ABS;
}

# Brief: Display directory list
# Usage: atla_dirs
function atla_dirs
{
    LINE_COUNT=$(wc -l $ATLA_FNAME_ABS | awk '{print $1}');
    if [ "$LINE_COUNT" == "0" ]; then
        echo "(Henüz hiçbir klasör eklemediniz. Yardım için : 'atla --help')";
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
    done < <(cat -n $ATLA_FNAME_ABS)

    echo;
    echo    "(Daha Fazla Bilgi İçin 'atla help' yazabilirsiniz.)";
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

    echo $($ATLA_READLINK $1) >> $ATLA_FNAME_ABS;
    atla_reload_only_exist_dir;

    sort -u $ATLA_FNAME_ABS -o $ATLA_FNAME_TEMP;
    mv -f $ATLA_FNAME_TEMP $ATLA_FNAME_ABS;

    return;
}

# Brief:
# Usage:
function atla_clean
{
    rm -f $ATLA_FNAME_ABS && touch $ATLA_FNAME_ABS;
}

# Brief: Save a directory list to the filepath.
# Usage: atla_save <filepath>
function atla_save
{
    # error handling
    [ "$#" = 0 ] && return 0;
    atla_reload_only_exist_dir;

    cp $ATLA_FNAME_ABS $1;
}

# Brief: Load a directory list from the filepath.
# Usage: atla_load <filepath>
function atla_load
{
    # error handling
    [ "$#" = 0 ] && return 0;

    cp $1 $ATLA_FNAME_ABS;

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
        atla_print_usage;
        return;
    fi

    atla_reload_only_exist_dir;

    rm -f $ATLA_FNAME_TEMP && touch $ATLA_FNAME_TEMP;

    # Save all directoryes without target.
    while read line;
    do
        index=$(echo $line | awk '{print $1}');
        directory=$(echo $line | awk '{print $2}');
        [ "$index" -ne "$1" ] && echo $directory >> $ATLA_FNAME_TEMP;
    done < <(cat -n $ATLA_FNAME_ABS)

    mv -f $ATLA_FNAME_TEMP $ATLA_FNAME_ABS;

    return 0;
}

function atla_rm_by_dirname
{
    rm -f $ATLA_FNAME_TEMP && touch $ATLA_FNAME_TEMP;

    while read line;
    do
        if [[ ! "$line" == "$($ATLA_READLINK $1)" ]]; then
            echo "$line" >> $ATLA_FNAME_TEMP;
        fi
    done < <(cat $ATLA_FNAME_ABS)

    mv -f $ATLA_FNAME_TEMP $ATLA_FNAME_ABS;
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
    done < <(cat -n $ATLA_FNAME_ABS)

    index_curr=$(expr $index_curr + 1);
    index_end=$(wc -l $ATLA_FNAME_ABS | awk '{print $1}');

    #roll back
    if [ $index_curr -gt $index_end ]; then
        index_curr=1;
    fi

    #change directory
    atla_go $index_curr;
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

    done < <(cat -n $ATLA_FNAME_ABS)

    index_curr=$(expr $index_curr - 1);
    index_end=$(wc -l $ATLA_FNAME_ABS | awk '{print $1}');

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
    ATLA_TARGET=$(cat -n $ATLA_FNAME_ABS | grep "^[[:space:]]*$1[[:space:]]" | awk '{print $2}');

    # go
    ! [ -z $ATLA_TARGET ] && cd $ATLA_TARGET;
}

function atla
{
    if [ ! -f $ATLA_FNAME_ABS ]; then
        touch $ATLA_FNAME_ABS
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

# ekstra kısayollar 
alias nnd='nano /etc/nginx/sites-available/default'
alias ser='service $1 $2'
alias sers='service $1 status'
alias serr='service $1 restart'
alias apin='apt install $1'
alias remcd='rm -rf ./*'
alias remcda='rm -rf ./.*'
