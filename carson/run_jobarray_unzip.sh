#!/bin/bash 
echo "Source directory="$SOURCE

# PREPARE SOURCE FILE
FILELIST=$(ls -1 $SOURCE/*.zip)
FILEARRAY=($FILELIST)

# Find out number of files in directory
LENGTH=${#FILEARRAY[@]}
echo "Number of files in directory="$LENGTH
echo "FileArray elements="${FILEARRAY[*]}

FILENUMBER=$(($SGE_TASK_ID-1)) # assuming SGE_TASK_ID start at 1 while array index starts at 0
echo "Processing File Number "$FILENUMBER
FILENAME=$(echo ${FILEARRAY[$FILENUMBER]})
zipFile=${FILENAME}

echo "Opening zip file: "$zipFile
# unzip sourceFile 
 unzip $zipFile -d $SOURCE 





