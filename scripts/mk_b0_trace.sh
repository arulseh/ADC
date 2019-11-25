#!/bin/bash
set -e

## generate separate b0 and trace files
## from dwi nifti with >1 volumes 
##
## inputs can be files or /paths/files
## output saves by default to input dir
## output basename can include path

if [ $# -lt 1 ]; then
	echo "Usage: `basename $0` <input dwi nifti>"
	echo "       `basename $0` <input dwi nifti> [output basename]"
	exit
fi

echo "`date` - `basename $0`"
INPUTFILENAME="$1"

if [ $(${FSLDIR}/bin/imtest $INPUTFILENAME) -ne 1 ]; then 
	echo "`date` - `basename $0` - ERROR: not valid image: $INPUTFILENAME"
	exit 1
fi

if [ $(${FSLDIR}/bin/fslval $INPUTFILENAME dim4) -eq 1 ]; then
	echo "`date` - `basename $0` - ERROR: input has 1 volume"
	exit 1
fi

INPUTBASENAME=$(${FSLDIR}/bin/remove_ext $INPUTFILENAME)
FILEPATH="$(dirname $INPUTBASENAME)/"

if [ -z ${2+x} ]; then
	OUTBASENAME="$INPUTBASENAME"
else
	OUTPATH=$(dirname $2)
	if [ $(echo $2 | rev | cut -c1) == "/" ]; then
		echo "[output basename] = string or /path/string" 
		exit 1
	elif [ $OUTPATH == "." ]; then
		OUTBASENAME="${FILEPATH}${2}"
	else
		mkdir -p ${OUTPATH}
		OUTBASENAME="$2"
	fi
fi


############
## Examples 
## depends on vendor, and how sequence is set up
## can automate if bvals file available

## Example 1
## DWI nifti with 1st volume b0 and 2nd volume trace 
${FSLDIR}/bin/fslroi ${INPUTFILENAME} ${OUTBASENAME}_B0 0 1 
${FSLDIR}/bin/fslroi ${INPUTFILENAME} ${OUTBASENAME}_TRACE 1 1

## Example 2
## DWI nifti with 1st volume trace and 2nd volume b0 
#${FSLDIR}/bin/fslroi ${INPUTFILENAME} ${OUTBASENAME}_B0 1 1
#${FSLDIR}/bin/fslroi ${INPUTFILENAME} ${OUTBASENAME}_TRACE 0 1

## Example 3
## DWI nifti with 1st volume b0 followed by 3 DW volumes along noncolinear gradient directions
#${FSLDIR}/bin/fslroi ${INPUTFILENAME} ${OUTBASENAME}_B0 0 1 
#${FSLDIR}/bin/fslroi ${INPUTFILENAME} ${OUTBASENAME}_TRACE 1 3
#${FSLDIR}/bin/fslmaths ${OUTBASENAME}_TRACE -Tmean ${OUTBASENAME}_TRACE

###############
## optional QC
slices ${OUTBASENAME}_B0 -o ${OUTBASENAME}_B0.gif
slices ${OUTBASENAME}_TRACE -o ${OUTBASENAME}_TRACE.gif

