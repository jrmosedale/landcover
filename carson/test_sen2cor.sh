NAME=/home/ISAD/jm622/sentinel/S2_1C_Products/S2A_MSIL1C_20170118T113411_N0204_R080_T30UUA_20170118T113659.zip
echo "Product name= "$NAME
# INFILE=$HOME/sentinel/S1C_Products/$NAME
# echo="Infile= "$INFILE
#export SEN2COR_HOME==/cm/shared/apps/anaconda.ks/4.2.0_py_2.7/lib/python2.7/site-packages/sen2cor-2.3.1-py2.7.egg/sen2cor



#export SEN2COR_HOME=$HOME/sentinel/sen2cor-2.3.0
#export SEN2COR_BIN=/cm/shared/apps/anaconda.ks/4.2.0_py_2.7/lib/python2.7/site-packages/sen2cor-2.3.1-py2.7.egg/sen2cor
#export GDAL_DATA=/cm/shared/apps/anaconda.ks/4.2.0_py_2.7/lib/python2.7/site-packages/sen2cor-2.3.1-py2.7.egg/sen2cor/cfg/gdal_data

. /etc/profile.d/modules.sh
#module add Anaconda/4.2.0_py_2.7
which module add Anaconda/5.0.0_py_2.7
which python
L2A_Process --resolution 10 $NAME