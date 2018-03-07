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
echo $1
 
# use third parameter for path to source products
sourceDirectory="$2"
echo $2
 
# use fourth parameter for path to target products
targetDirectory="$3"
echo $3 
 
############################################
# Helper functions
############################################
 

############################################
# Main processing
############################################
 
# Create the target directory
 
IFS=$'\n'
for F in $(ls -1 "${sourceDirectory}"); do
  # Write input file path and name
  sourceFile="${sourceDirectory}/${F}"
  # Remove file extension and save name
  filename=$(echo $F | cut -f 1 -d '.')
  # write filename - gpt will complete filename
  targetFile="${targetDirectory}/${filename}"
  # write command for calling gpt with correct parameters
  #procCmd="/Applications/snap/bin/gpt \"${graphXmlPath}\" -PsourceFile=\"${sourceFile}\" -PtargetFile=\"${targetFile}\" "
  procCmd="${gptPath} \"${graphXmlPath}\" -PsourceFile=\"${sourceFile}\" -PtargetFile=\"${targetFile}\" "

 #${procCmd}
 eval "$procCmd"
done