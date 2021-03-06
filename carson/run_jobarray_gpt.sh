#!/bin/bash
############################################
# User Configuration
# Call from .sub file 
############################################

# adapt this path to your needs
gptPath=/Applications/snap/bin/gpt
 
############################################
# Command line handling
############################################
# first parameter is a path to the graph xml
graphXmlPath=$GRAPH
echo $graphXmlPath
# use third parameter for path to source products
sourceDirectory=$SOURCE
echo $sourceDirectory
# use fourth parameter for path to target products
targetDirectory=$TARGET
echo $targetDirectory
 
WKDIR=$HOME"/sentinel/graphs_xml" # location of graph xml script
echo "WKDIR= "$WKDIR
cd $WKDIR
############################################
# CALCULATE PARAMETERS for target and source files
############################################
# PREPARE SOURCE FILE
FILELIST=$(ls -1 $sourceDirectory)
FILEARRAY=($FILELIST)

# Find out number of files in directory
LENGTH=${#FILEARRAY[@]}
echo "Number of files in directory="$LENGTH

FILENUMBER=$SGE_TASK_ID-1 # assuming SGE_TASK_ID start at 1
FILENAME=$(echo ${FILEARRAY[$FILENUMBER]})

sourceFile="${SOURCE}/${FILENAME}"

echo "Processing source file: "$sourceFile

# PREPARE OUTPUT FILE
# Remove file extension and save name
FILESTUB=$(echo $FILENAME | cut -f 1 -d '.')
# write filename - gpt will complete filename
targetFile="${targetDirectory}/${FILESTUB}"

echo "Creating target file: "$targetFile 

############################################
# Call gpt graph .xml
############################################

. /etc/profile.d/modules.sh
module add shared esa-snap
module load shared gdal
which gpt
# Create command line
procCmd="gpt $graphXmlPath -PsourceFile=\"${sourceFile}\" -PtargetFile=\"${targetFile}\" "

eval "$procCmd"



