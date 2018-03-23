#!/bin/bash
FILELIST=$(ls -1)
#echo $FILELIST
#for FILE in $FILELIST
#do
#FILENAME=$(echo $FILE)
#echo $FILENAME
#done

stringarray=($FILELIST)
# Find out length of array
LENGTH=${#stringarray[@]}
echo "Length="$LENGTH

#FILE1=$(echo ${stringarray[$FILENUMBER]})
#FILE2=$(echo ${stringarray[$A]})
#FILE3=$(echo ${stringarray[$B-1]})

#echo $FILE1
#echo $FILE2
#echo $FILE3
FILENUMBER=5
echo "FILENUMBER="$FILENUMBER

if [ $FILENUMBER <= $LENGTH ]; then
	echo $(echo ${stringarray[$FILENUMBER]})
	#echo $FILE
else
    echo "Sage index exceeds number of files in dir"
fi

FILENUMBER=999
echo "FILENUMBER="$FILENUMBER
if [ $FILENUMBER<$LENGTH ]; then
	echo $(echo ${stringarray[$FILENUMBER]})
	#echo $FILE
else
    echo "Sage index exceeds number of files in dir"
fi