#!/bin/bash
set -e

## return median value 
##  

if [ $# -lt 2 ]; then
	echo "Usage: `basename $0` <input adc> <input mask>"
	exit 1
fi

ADC="$1"
MASK="$2"

if [ $(${FSLDIR}/bin/imtest $ADC) -ne 1 ]; then 
	echo "`date` - `basename $0` - ERROR: not valid image: $ADC"
	exit 1
elif [ $(${FSLDIR}/bin/imtest $MASK) -ne 1 ]; then
	echo "`date` - `basename $0` - ERROR: not valid image: $MASK"
	exit 1
fi

ADC_MEDIAN=$(fslstats $ADC -k $MASK -p 50)
echo "$ADC_MEDIAN"

