#!/bin/bash
############################################
# User Configuration
# Call by: /Applications/snap/bin/gpt "/Users/jm622/Rprojects/landcover/xml/extract_to_tif_files.xml" -PsourceFile="/Users/jm622/Sentinel/Sentinel-2/20170506Mosaic/Inputs/S2A_MSIL2A_20170525T112121_N0205_R037_T30UVA_20170525T112434.SAFE" -PtargetFile="/Users/jm622/Sentinel/Sentinel-2/20170506Mosaic/Outputs/S2A_MSIL2A_20170525T112121_N0205_R037_T30UVA_20170525T112434"
############################################

# adapt this path to your needs
 gptPath=/Applications/snap/bin/gpt
 
############################################
# Command line handling
############################################
 
# first parameter is a path to the graph xml
graphXmlPath=$GRAPH
echo $GRAPH
 
# use third parameter for path to source products
sourceDirectory=$SOURCE
echo $SOURCE
 
# use fourth parameter for path to target products
targetDirectory=$TARGET
echo $TARGET
 
############################################
# Helper functions
############################################
 

############################################
# Main processing
############################################
WKDIR=$HOME"/sentinel/graphs_xml" # location of graph xml script
echo "WKDIR= "$WKDIR
cd $WKDIR

. /etc/profile.d/modules.sh
module add shared esa-snap
module load shared gdal
which gpt
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
  procCmd="gpt $graphXmlPath -PsourceFile=\"${sourceFile}\" -PtargetFile=\"${targetFile}\" "

 eval "$procCmd"
done



