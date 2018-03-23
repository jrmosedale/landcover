############################################
# Command line handling
# Submit by qsub -v GRAPH="S2_export_60m_bands_tif.xml" run_parameter_gpt.sub
############################################
 
# first parameter is a path to the graph xml
graphXmlPath=$GRAPH
echo "graphXMLPath= "$graphXmlPath
 

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
gpt $graphXmlPath -PsourceFile="$HOME/sentinel/graphs_xml/testin/S2A_MSIL2A_20170803T112121_N0205_R037_T29UQS_20170803T112115.SAFE" -PtargetFile="$HOME/sentinel/graphs_xml/testout/test" 