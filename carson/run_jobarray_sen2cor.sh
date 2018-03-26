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
# unzip $zipFile -d $SOURCE 

# Determine SAFE filename
# Remove file extension and save name
FileStub=$(echo $FILENAME | cut -f 1 -d '.')
sourceFile=${FileStub}.SAFE

echo "Processing source file: "$sourceFile

# write command for calling sen2cor with correct parameters
# procCmd="bash /home/ISAD/jm622/sentinel/Sen2Cor-2.4.0-Linux64/bin/L2A_Process ${sourceFile} --resolution=60"
procCmd="bash /home/ISAD/jm622/sentinel/Sen2Cor-2.4.0-Linux64/bin/L2A_Process ${sourceFile} "
# echo $procCmd
eval "$procCmd"



