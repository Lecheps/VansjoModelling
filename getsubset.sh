#!/bin/bash

#Querying and organizing daily netcdf gridded data from metno

LIST="$1"      #List of opendap files to query
COORD="$2"     #Extent to query as a postgis BOX
SAVEFILE="$3"  #Name of the file that will store all data
VAR="$4"       #Variable to extract from the daily files: not needed right now. Stores all variables be default

echo $LIST and $COORD and $SAVEFILE

if [ "$#" -ne 4 ]; then
    echo "Illegal number of parameters"
fi

CNT=1

#Extracting boundaries from BOX
echo $COORD
while read w s e n; do WEST="$w";SOUTH="$s"; EAST="$e";NORTH="$n"; done < <(echo $COORD | sed -e 's/[^0-9 ,.]//g' | awk -F '[ ,]' '{print  $1 " " $2 " " $3 " " $4}')

echo 'The boundaries are:'
echo $WEST
echo $SOUTH
echo $EAST
echo $NORTH

NUMPROCESSORS=32

#head -n 500 $LIST > dummy.txt

#Parallel queries to metno using OpenDAP and fimex
ulimit -n 512 && cat $LIST | parallel --eta --jobs 0 -u --no-notice "fimex --extract.reduceToBoundingBox.south=$SOUTH --extract.reduceToBoundingBox.north=$NORTH --extract.reduceToBoundingBox.west=$WEST --extract.reduceToBoundingBox.east=$EAST  --input.file={} --output.file={/}"

#LAST=`exec ls $MY_DIR | sed 's/\([0-9]\+\).*/\1/g' | sort -n | tail -1`

#Concatenating all daily netcdf files to a single file. Getting rid of lat lon in degrees.
mkdir -p ./tmp/
mv *.nc ./tmp/
cd tmp #&& ls | parallel -u --jobs 0 --no-notice "fimex --extract.removeVariable=lat --extract.removeVariable=lon --input.file={} --output.file={}"
ncrcat *.nc $SAVEFILE
mv $SAVEFILE ../..
#cd tmp && cat $(eval "cdo cat {$LAST..1}.nc4 $SAVEFILE") && mv $SAVEFILE ..
#cd tmp && cdo cat -selname,Y,X,time,$VAR *.nc4 $SAVEFILE && mv $SAVEFILE ..

cd ..
#rm -r tmp