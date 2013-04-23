#!/usr/bin/env bash
#
# lunchy.sh is a bash implementation of the lunchy ruby gem.
#
# Please see the included LICENSE file for licensing information.
#

VERSION='1.0'
AUTHOR='Bill Israel <bill.israel@gmail.com>'
LUNCHY=${HOME}/.lunchyagents

usage() {
    cat << EOF
usage: $(basename $0) [options] command [pattern]

Provides a simpler interface to launchctl.

Options:
    -h                  Print this help message
    -v                  Show verbose output
    -V                  Show version information

Commands:
    ls [pattern]        List all launch agents, or only ones matching the given pattern.
    start {pattern}     Start the launch agent matching the given pattern.
    stop {pattern}      Stop the launch agent matching the given pattern.
    restart {pattern}   Restart the launch agent matching the given pattern.
    status [pattern]    Display the status of all launch agents, or only the ones matching the pattern.
    install {file}      Make lunchy aware of the given launch agent.
    uninstall {file}    Make lunch unaware of the given launch agent.
    show {pattern}      See the launch agent with the specified pattern
    edit {pattern}      Edit the launch agent with the specified pattern

Examples:
    lunchy ls
    lunchy start mongo
    lunchy stop mongo
    lunchy status mysql
    lunchy install /usr/local/opt/mongodb/com.example.mongo.plist
    lunchy uninstall /usr/local/opt/mongodb/com.example.mongo.plist

EOF
}

version() {
    cat << EOF
lunchy.sh - a simple interface to launchctl by $AUTHOR
Version $VERSION 
EOF
}

log() {
    [ $VERBOSE -eq "1" ] && echo "$1"
}


#
# Installs the plist into the lunchy-managed file
#
install() {
    if [ -z "$1" ]; then
        echo "Error: missing path for launch agent to install"
        exit 2
    fi

    file=$1
    
    echo $file >> $LUNCHY
    log "Installed $file."
}

#
# Uninstalls a plist file from the lunchy-managed file
#
uninstall() {
    if [ -z "$1" ]; then
        echo "Error: missing path for launch agent to uninstall"
        exit 2
    fi
    
    file=$1

    sed -e "\#$file#d" -i "" $LUNCHY
    log "Uninstalled $file" 
}


#
# Lists all the plists lunchy knows about
#
ls() {
    pattern=$1
    if [ -z "$pattern" ]; then
        cat $LUNCHY  
    else
        cat $LUNCHY | grep --color=never "$pattern"
    fi
}


#
# Starts the launch agent(s) matching the given pattern
#
start() {
    pattern=$1
    if [ -z "$pattern" ]; then
        echo "Error: missing pattern for launch agent"
        exit 3
    fi

    for plist in `cat $LUNCHY | grep "$pattern"`; do
        launchctl load $plist
        log "Started $plist"
    done
}


#
# Stops the launch agent(s) matching the given pattern
#
stop() {
    pattern=$1
    if [ -z "$pattern" ]; then
        echo "Error: missing pattern for launch agent"
        exit 3
    fi

    for plist in `cat $LUNCHY | grep --color=never "$pattern"`; do
        launchctl unload $plist
        log "Stopped $plist"
    done
}


#
# Shows the status of all lunchy-aware launch agents
#
status() {
    pattern=$1
    if [ -z "$pattern" ]; then
        while read line
        do
            file=$(basename $line)
            plist="${file%.*}"
            launchctl list | grep --color=never $plist
        done < $LUNCHY
    else
        launchctl list | grep --color=never "$pattern"
    fi
}


#
# Output the launch agent(s) specified by the given pattern
#
show() {
    pattern=$1
    if [ -z "$pattern" ]; then
        echo "Error: missing pattern for launch agent"
        exit 3
    fi

    cat `cat $LUNCHY | grep $pattern`
}


#
# Edit the launch agent(s) specified by the given pattern with $EDITOR
#
edit() {
    pattern=$1
    if [ -z "$pattern" ]; then
        echo "Error: missing pattern for launch agent"
        exit 3
    fi

    $EDITOR `cat $LUNCHY | grep $pattern`
}

VERBOSE="0"
while getopts ":vhV" OPTION
do
    case $OPTION in
        h)
            usage
            exit 1
            ;;
        v)
            VERBOSE="1"
            ;;
        V)
            version
            exit 0
            ;;
        ?)
            usage
            exit 1
            ;;
    esac
    
    # Remove the option after it's parsed
    shift $((OPTIND-1))
done


COMMAND=$1
PARAMS=${@:2}
case $COMMAND in
    install)
        install ${PARAMS[0]}
        ;;
    
    uninstall)
        uninstall ${PARAMS[0]}
        ;;

    ls)
        ls ${PARAMS[0]}
        ;;

    start)
        start ${PARAMS[0]} 
        ;;

    stop)
        stop ${PARAMS[0]} 
        ;;

    restart)
        stop ${PARAMS[0]} 
        start ${PARAMS[0]} 
        ;;

    status)
        status ${PARAMS[0]} 
        ;;

    show)
        show ${PARAMS[0]}
        ;;

    edit)
        edit ${PARAMS[0]}
        ;;

    *)
        [ ! -z $COMMAND ] && echo "Unknown command: $COMMAND"
        usage
        exit 1
        ;;
esac

