#!/bin/bash

LIST="$1"
COORD="$2"
SAVEFILE="$3"
VAR="$4"

echo $LIST and $COORD and $SAVEFILE

if [ "$#" -ne 4 ]; then
    echo "Illegal number of parameters"
fi

CNT=1


echo $COORD
while read w s e n; do WEST="$w";SOUTH="$s"; EAST="$e";NORTH="$n"; done < <(echo $COORD | sed -e 's/[^0-9 ,.]//g' | awk -F '[ ,]' '{print  $1 " " $2 " " $3 " " $4}')

echo 'The boundaries are:'
echo $WEST
echo $SOUTH
echo $EAST
echo $NORTH

while read p; do #head $LIST | 
    fimex --extract.reduceToBoundingBox.south=$SOUTH --extract.reduceToBoundingBox.north=$NORTH --extract.reduceToBoundingBox.west=$WEST --extract.reduceToBoundingBox.east=$EAST   --input.file=$p --extract.selectVariables=X --extract.selectVariables=Y --extract.selectVariables=$VAR --extract.removeVariable=lon --extract.removeVariable=lat --output.file=$CNT.nc4 > /dev/null &
#     fimex --extract.reduceToBoundingBox.south=$SOUTH --extract.reduceToBoundingBox.north=$NORTH --extract.reduceToBoundingBox.west=$WEST --extract.reduceToBoundingBox.east=$EAST  --input.file=$p --extract.selectVariables=RR --output.file=$CNT.nc4
    
    if ! (($CNT % 20)); then
        echo $CNT
        wait
    fi
    CNT=$((CNT + 1))
done < $LIST

LAST=`exec ls $MY_DIR | sed 's/\([0-9]\+\).*/\1/g' | sort -n | tail -1`

mkdir -p ./tmp/
mv *.nc4 ./tmp/
cd tmp && cat $(eval "cdo cat {$LAST..1}.nc4 $SAVEFILE") && mv $SAVEFILE ..
cd ..
#rm -r tmp