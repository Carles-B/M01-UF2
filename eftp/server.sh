#!/bin/bash

echo "Servidor de EFTP"
CLIENT="10.65.0.77"
PORT="3333"
TIMEOUT=1

echo "(0) Listen"

DATA=`nc -l -p $PORT -w $TIMEOUT`
PREFIX=`echo $DATA | cut -d " " -f 1`
VERSION=`echo $DATA | cut -d " " -f 2`
echo $DATA

echo "(3) Test & Send" 
#Comprobar si lo que nos ha llegado es == a cabecera. 
#si cabecera es == EFTP 1.0 Continuar sino ERROR
#Los tests siempre comprueban si es distinto no si es igual.
if [ "$PREFIX $VERSION" != "EFTP 1.0" ]; then
	echo "ERROR 1: BAD_HEADER"
	sleep 1
	echo "KO_HEADER" | nc $CLIENT $PORT
	exit 1
fi

CLIENT=`echo $DATA | cut -d " " -f 3`
if [ "$CLIENT" == ""  ]; then
	echo "ERROR: NO IP"
	exit 1
fi

echo "OK_HEADER"
sleep 1
echo "OK_HEADER" | nc $CLIENT $PORT

echo "(4) Listen"

DATA=`nc -l -p $PORT -w $TIMEOUT`

echo $DATA

echo "(7) Test & Send"

if [ "$DATA" != "BOOOM"  ]; then
	echo "ERROR 2: BAD HANDSHAKE"
	sleep 1
	echo "KO_HANDSHAKE" | nc $CLIENT $PORT
	exit 2
fi

echo "OK_HANDSHAKE"
sleep 1
echo "OK_HANDSHAKE" | nc $CLIENT $PORT

echo "(7a) Listen NUM_FILES"

DATA=`nc -l -p $PORT -w $TIMEOUT`
echo $DATA

echo "(7b) Send OK/KO_NUM_FILES"

PREFIX=`echo $DATA | cut -d " " -f 1`
if [ "$PREFIX" != "NUM_FILES"  ]; then
	echo "ERROR 3a: BAD NUM_FILE"
	sleep 1
	echo "KO_FILE_NUM" | nc $CLIENT $PORT
	exit 2
fi

echo "OK_FILE_NUM" | nc $CLIENT $PORT
FILE_NUM=`echo $DATA | cut -d " " -f 2`

echo "(8a) Loop NUM"

for N in `seq $FILE_NUM`
do
	echo "Archivo numero $N"

echo "(8b) Listen"

DATA=`nc -l -p $PORT -w $TIMEOUT`
echo $DATA

echo "(12) Test&Store&Send"

PREFIX=`echo $DATA | cut -d " " -f 1`


if [ "$PREFIX" != "FILE_NAME"  ]
then
	echo "ERROR 3: BAD FILE NAME PREFIX"
	sleep 1
	echo "KO_FILE_NAME" | nc $CLIENT $PORT
	exit 3
fi



FILE_MD5=`echo "$DATA" | cut -d " " -f 3`
FILE_NAME=`echo "$DATA" | cut -d " " -f 2`
FILE_MD5_LOCAL=`echo $FILE_NAME | md5sum | cut -d " " -f 1`

if [ "$FILE_MD5" != "$FILE_MD5_LOCAL" ]; then
	echo "ERROR 3: BAD FILE NAME MD5"
	sleep 1
	echo "KO_FILE_NAME" | nc $CLIENT $PORT
	exit 3
fi

sleep 1
echo "OK_FILE_NAME" | nc $CLIENT $PORT


echo "(13) Listen"
DATA=`nc -l -p $PORT -w $TIMEOUT > inbox/$FILE_NAME`
echo $DATA

echo "(16) Store&Send"

DATA=`cat inbox/$FILE_NAME`

if [ "$DATA" == "" ]
then
	echo "ERROR 4: EMPTY DATA"
	sleep 1
	echo "KO_DATA" | nc $CLIENT $PORT
	exit 4
fi

sleep 1
echo "OK_DATA" | nc $CLIENT $PORT

echo "(17) Listen"
DATA=`nc -l -p $PORT -w $TIMEOUT`
echo $DATA

echo "(20) Test&Send"

echo $DATA

PREFIX=`echo $DATA | cut -d " " -f 1`
if [ "$PREFIX" != "FILE_MD5"  ]; then
	echo "ERROR 5: BAD FILE MD5 PREFIX"
	echo "KO_FILE_MD5" | nc $CLIENT $PORT
	exit 5
fi

sleep 1
echo "OK_FILE_MD5" | nc $CLIENT $PORT

done
echo "FIN"
exit 0
