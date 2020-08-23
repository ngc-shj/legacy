#!/bin/bash

NOTIFYPATHS="/etc /bin /sbin /usr/bin /usr/sbin /usr/local/bin /usr/local/sbin /root /var/www/html"
HOST_NAME=$(/bin/hostname)
MAILTO=ng@jpng.jp

function monitor_path() {
    local notifypath=$1
    local timeout=5

    {
        /usr/bin/inotifywait -e modify,attrib,create,delete \
                             -mrq $notifypath | \
            while true; do
                messages=""
                while read -t $timeout line; do
                    messages="${messages}$line@LF@"
                done

                if [[ -n "$messages" ]]; then
                    echo $messages | \
                        sed -e 's/@LF@/\n/g' | \
                        /usr/bin/Mail -s "[falsification notice] $HOST_NAME:$notifypath" $MAILTO
                fi
            done
    } &
}

function main() {
    for notifypath in $(echo $NOTIFYPATHS); do
        monitor_path $notifypath
    done
}

main $@

