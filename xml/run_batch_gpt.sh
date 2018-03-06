#!/bin/bash
############################################
# User Configuration
############################################

# adapt this path to your needs
gptPath=/Applications/snap/bin/gpt
 
############################################
# Command line handling
############################################
 
# first parameter is a path to the graph xml
graphXmlPath="$1"
 
# use third parameter for path to source products
sourceDirectory="$2"
 
# use fourth parameter for path to target products
targetDirectory="$3"
 
 
############################################
# Helper functions
############################################
 

############################################
# Main processing
############################################
 
# Create the target directory
mkdir -p "${targetDirectory}"
 
IFS=$'\n'
for F in $(ls -1 "${sourceDirectory}"); do
  sourceFile="${sourceDirectory}/${F}"
  filename=$(echo $F |cut -f 1 -d '.')
  targetFile="${targetDirectory}/${filename}"
  procCmd="${gptPath} \"${graphXmlPath}\" -PsourceFile=\"${sourceFile}\" -PtargetFile=\"${targetFile}_rsmpsset_20mbands.tif\""
  ${procCmd}
done