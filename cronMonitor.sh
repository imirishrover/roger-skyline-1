#!/bin/bash

BUFF="/roger_files/checksum"
FILE="/var/spool/cron/crontabs/nsance"
CHECKSUM=$(sudo md5sum $FILE)

if [ ! -f $BUFF ]
then
        echo "$CHECKSUM" > $BUFF
        exit 0;
fi;

if [ ! -f $FILE ]
then
        echo "Cron file doesn't exist for current user"
        exit 0;
fi;

if [ "$CHECKSUM" != "$(cat $BUFF)" ];
        then
        echo "$CHECKSUM" > $BUFF
        echo "$FILE has been modified ! '*_*" | mail -s comandante3795@gmail.com
fi;
