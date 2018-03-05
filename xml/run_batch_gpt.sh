#!/bin/bash
#
 
############################################
# User Configuration
############################################
 
# adapt this path to your needs
gptPath=gpt
 
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
  targetFile="${targetDirectory}/${F}"
  procCmd="\"${gptPath}\" \"${graphXmlPath}\" -PsourceFile= \"${sourceFile}\" -PtargetFile= \"${targetFile}\""
  "${procCmd}"
done