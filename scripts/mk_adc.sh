#!/bin/bash
set -e

## calculate ADC map from B0 and TRACE volumes
## saves to same path as B0 by default
## input and output base can include paths

if [ $# -lt 2 ]; then
	echo "Usage: `basename $0` <input b0> <input trace>"
	echo "       `basename $0` <input b0> <input trace> [output basename]" 
	exit
fi

#########################
## set non-b0 b-value
BVAL="1000" 
#########################

echo "`date` - `basename $0`"
INPUTB0="$1"
INPUTTRACE="$2"

if [ $(${FSLDIR}/bin/imtest $INPUTB0) -ne 1 ]; then 
	echo "not valid image: $INPUTB0"
	exit 1
elif [ $(${FSLDIR}/bin/imtest $INPUTTRACE) -ne 1 ]; then 
	echo "not valid image: $INPUTTRACE"
	exit 1
fi

B0VOLS=$(${FSLDIR}/bin/fslval $INPUTB0 dim4)
TRACEVOLS=$(${FSLDIR}/bin/fslval $INPUTTRACE dim4)

if [ $B0VOLS -ne 1 ]; then
	echo "`date` - `basename $0` - ERROR: expected 1 volume, has ${B0VOLS}: $INPUTB0"
	exit 1
elif [ $TRACEVOLS -ne 1 ]; then
	echo "`date` - `basename $0` - ERROR: expected 1 volume, has ${TRACEVOLS}: $INPUTTRACE"
	exit 1
fi

INPUTBASENAME=$(${FSLDIR}/bin/remove_ext $INPUTB0)
if [ $(echo $INPUTBASENAME | rev | cut -d'_' -f1 | rev) == "B0" ]; then
	INPUTBASENAME=$(echo $INPUTBASENAME | rev | cut -d'_' -f2- | rev)
fi
FILEPATH="$(dirname $INPUTBASENAME)/"

if [ -z ${3+x} ]; then
	OUTBASENAME="$INPUTBASENAME"
else
	OUTPATH=$(dirname $3)
	if [ $(echo $3 | rev | cut -c1) == "/" ]; then
		echo "`date` - `basename $0` - ERROR: [output basename] = string or /path/string" 
		exit 1
	elif [ $OUTPATH == "." ]; then
		OUTBASENAME="${FILEPATH}${3}"
	else
		mkdir -p ${OUTPATH}
		OUTBASENAME="$3"
	fi
fi


###############
## make ADC 
${FSLDIR}/bin/fslmaths ${INPUTB0} -div ${INPUTTRACE} -log -div ${BVAL} ${OUTBASENAME}_ADC
## brain extract and standardize
${FSLDIR}/bin/bet ${INPUTB0} ${OUTBASENAME}_brain -m -f .3 -R
${FSLDIR}/bin/fslmaths ${OUTBASENAME}_brain_mask -ero -ero -ero ${OUTBASENAME}_brainmask
${FSLDIR}/bin/imrm ${OUTBASENAME}_brain ${OUTBASENAME}_brain_mask
${FSLDIR}/bin/fslmaths ${OUTBASENAME}_ADC -mas ${OUTBASENAME}_brainmask ${OUTBASENAME}_ADC_brain
${FSLDIR}/bin/fslmaths ${OUTBASENAME}_ADC_brain -sub $(fslstats ${OUTBASENAME}_ADC_brain -k ${OUTBASENAME}_brainmask -m) -div $(fslstats ${OUTBASENAME}_ADC_brain -k ${OUTBASENAME}_brainmask -s) -mas ${OUTBASENAME}_brainmask ${OUTBASENAME}_ADC_brain_std

###############
## optional QC
slices ${OUTBASENAME}_ADC -o ${OUTBASENAME}_ADC.gif
slices ${OUTBASENAME}_ADC ${OUTBASENAME}_brainmask -o ${OUTBASENAME}_ADC_brainmask.gif
slices ${OUTBASENAME}_ADC_brain_std -o ${OUTBASENAME}_ADC_brain_std.gif

