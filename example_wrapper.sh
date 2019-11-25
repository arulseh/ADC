#!/bin/bash
set -e

export LC_ALL=C

if [ $# -lt 1 ]; then
	echo "Usage: `basename $0` <input dwi nifti>"
	echo "Usage: `basename $0` <input dwi nifti> [output basename]"
	exit
fi

## EDIT for your setup #############################
# edit SCRIPTDIR to reflect where these scripts are
SCRIPTDIR="${HOME}/projects/aaron/ADC/scripts" 
# edit for your FSL setup
export FSLDIR="/usr/share/fsl/5.0.10"
source ${FSLDIR}/etc/fslconf/fsl.sh
####################################################

INPUTDWI="$1"
INPUTBASENAME=$(${FSLDIR}/bin/remove_ext $INPUTDWI)
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

## make separate b0 and trace
bash ${SCRIPTDIR}/mk_b0_trace.sh "$INPUTDWI" "$OUTBASENAME"

## make adc, brain extract and standardize
bash ${SCRIPTDIR}/mk_adc.sh "${OUTBASENAME}_B0" "${OUTBASENAME}_TRACE" "$OUTBASENAME" 

## measure median
ADC_MEDIAN=$(bash ${SCRIPTDIR}/msr_median.sh "${OUTBASENAME}_ADC_brain_std" "${OUTBASENAME}_brainmask")

## measure p85
ADC_p85=$(bash ${SCRIPTDIR}/msr_p85.sh "${OUTBASENAME}_ADC_brain_std" "${OUTBASENAME}_brainmask")

echo "adc_median,adc_p85"
echo "${ADC_MEDIAN},${ADC_p85}"
