#!/bin/bash

echo $#
echo $0
echo $1
if [ $# -lt 1  ];then
	SERVER="localhost"
else 
	SERVER="$1"
fi

echo "Cliente de EFTP"
IP=`ip address | grep inet | grep -i enp0s3 | cut -d " " -f 6 | cut -d "/" -f 1`
PORT="3333"
TIMEOUT=1

echo "(1) Send"

sleep 1
echo "EFTP 1.0 $IP" | nc $SERVER $PORT

echo "(2) Listen"

DATA=`nc -l -p $PORT -w $TIMEOUT`

echo $DATA

echo "(5) Test & Send"

if [ "$DATA" != "OK_HEADER" ]; then
	echo "ERROR 1: BAD HEADER"
	exit 1
fi

echo "BOOOM"
sleep 1
echo "BOOOM" | nc $SERVER $PORT

echo "(6) Listen" 

DATA=`nc -l -p $PORT -w $TIMEOUT`

echo $DATA

echo "(9) test"

if [ "$DATA" != "OK_HANDSHAKE" ]
then
	echo "ERROR 2: BAD_HANDSHAKE"
	exit 2
fi

echo "OK_HANDSHAKE GOOD"
sleep 1

echo "(10) Send File"

FILE_NAME="fary1.txt"
FILE_MD5=`echo fary1.txt | md5sum | cut -d " " -f 1`

echo "File&MD5 sended"
sleep 1
echo "FILE_NAME $FILE_NAME $FILE_MD5" | nc $SERVER $PORT

echo "(11) Listen"

DATA=`nc -l -p $PORT -w $TIMEOUT`
echo $DATA

echo "(14) Test&Send"

if [ "$DATA" != "OK_FILE_NAME"  ]
then
	echo "ERROR 4: BAD OK_FILE_NAME"
	sleep 1
	echo "ERROR KO_FILE_NAME" | nc $SERVER $PORT
	exit 3
fi

echo "(15)Listen"

DATA=`nc -l -p $PORT -w $TIMEOUT`
echo $DATA


if [ "$DATA" != "OK_DATA" ]
then
	echo "ERROR 5: BAD_DATA"
	sleep 1
	echo "KO_DATA"
fi

echo "(18) Send"

FILE_MD5=`cat imgs/$FILE_NAME| md5sum | cut -d " " -f 1`
sleep 1
echo "FILE_MD5 $FILE_MD5" | nc $SERVER $PORT
sleep 1

echo "(19) Listen"
DATA=`nc -l -p $PORT -w $TIMEOUT`
echo $DATA

echo "(21) Test"

if [ "$DATA" != "OK_FILE_MD5"  ]; then
	echo "ERROR: FILE MD5"
	exit 5
fi

echo "FIN"
exit 0