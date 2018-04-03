#!/bin/bash
# Target directory can be set in L3_GIPP
# Min time and max time set in L3_GIPP
# Algorithm - TEMP_HOMOGENEITY, RADIOMETRIC_QUALITY, AVERAGE
# L3_Process [-h] [--resolution {10,20,60}] [--clean] directory
# sen2Three input_directory --resolution=20
source /Users/jonathanmosedale/sen2three/L3_Bashrc

L3_Process /Users/jonathanmosedale/Documents/Exeter/Sentinel/Sentinel-2/20171112Mosaic/Inputs/UVA 
L3_Process /Users/jonathanmosedale/Documents/Exeter/Sentinel/Sentinel-2/20171112Mosaic/Inputs/UVB 
L3_Process /Users/jonathanmosedale/Documents/Exeter/Sentinel/Sentinel-2/20171112Mosaic/Inputs/UUA 
L3_Process /Users/jonathanmosedale/Documents/Exeter/Sentinel/Sentinel-2/20171112Mosaic/Inputs/UUB 
