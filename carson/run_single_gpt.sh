############################################
# User Configuration
# Call by: /Applications/snap/bin/gpt "/Users/jm622/Rprojects/landcover/xml/extract_to_tif_files.xml" -PsourceFile="/Users/jm622/Sentinel/Sentinel-2/20170506Mosaic/Inputs/S2A_MSIL2A_20170525T112121_N0205_R037_T30UVA_20170525T112434.SAFE" -PtargetFile="/Users/jm622/Sentinel/Sentinel-2/20170506Mosaic/Outputs/S2A_MSIL2A_20170525T112121_N0205_R037_T30UVA_20170525T112434"
############################################


############################################
# Main processing
############################################
. /etc/profile.d/modules.sh
module add shared esa-snap
module load shared gdal
which gpt
gpt "/home/ISAD/jm622/sentinel/graphs_xml/S2_export_60m_bands_tif.xml" -PsourceFile="/home/ISAD/jm622/sentinel/graphs_xml/testin/S2A_MSIL2A_20170803T112121_N0205_R037_T29UQS_20170803T112115.SAFE" -PtargetFile="/home/ISAD/jm622/sentinel/graphs_xml/testout/test" 