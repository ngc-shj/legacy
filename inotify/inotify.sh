#!/bin/bash

NOTIFYPATHS=(/etc /bin /sbin /usr/bin /usr/sbin /usr/local/bin /usr/local/sbin /root /var/www/html)
EXCLUDEPATHS=(/etc/pki/nssdb/ /etc/mail/spamassassin/sa-update-keys/)
HOST_NAME=$(/bin/hostname)
MAILTO=foobar@example.com

function monitor_path() {
    local notifypath=$1
    local timeout=5

    {
        /usr/bin/inotifywait -e modify,attrib,create,delete \
                             -mrq $notifypath | \
            while true; do
                messages=""
                while read -t $timeout line; do
                    if [[ $(printf '%s\n' "${EXCLUDEPATHS[@]}" | grep -qx "${line%% *}"; echo -n ${?}) -ne 0 ]]; then
                        messages="${messages}$line@LF@"
                    fi
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
    for notifypath in ${NOTIFYPATHS[@]}; do
        monitor_path $notifypath
    done
}

main $@

