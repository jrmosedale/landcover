#!/bin/bash 
# Submit: autoFmask /home/ISAD/jm622/sentinel/S2_1C_Products/test/S2A_MSIL1C_20161216T112452_N0204_R037_T30UUA_20161216T112624.SAFE/GRANULE/L1C_T30UUA_A007756_20161216T112624 /home/ISAD/jm622/sentinel/FmaskMSI
# 1. Unzips 2. Runs FMask 3. Runs Sen2Cor
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
# 1.Unzip sourceFile 
unzip $zipFile -d $SOURCE 
# Remove zipFile?
# rm -r $zipFile

# Determine SAFE filename
# Remove file extension and save name
FileStub=$(echo $FILENAME | cut -f 1 -d '.')
sourceFile=${FileStub}.SAFE

echo "Processing source file: "$sourceFile

# 2. Run Fmask
InDir=$(ls -1 ${sourceFile}/GRANULE/L1C*)

addpath /home/ISAD/jm622/sentinel/FmaskMSI
# addpath ${outDir}
autoFmask $InDir OutputDirectory=/home/ISAD/jm622/sentinel/fmask_output


# Write command for calling sen2cor with correct parameters creating 2A Product
# procCmd="bash /home/ISAD/jm622/sentinel/Sen2Cor-2.4.0-Linux64/bin/L2A_Process ${sourceFile} --resolution=60"
procCmd="bash /home/ISAD/jm622/sentinel/Sen2Cor-2.4.0-Linux64/bin/L2A_Process ${sourceFile} "
# echo $procCmd
eval "$procCmd"



