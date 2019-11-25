Scripts for processing DWI-ADC data, as published in:
Rulseh AM, Vymazal J. Whole Brain Apparent Diffusion Coefficient Measurements Correlate with Survival in Glioblastoma Patients. 
doi: 

Basic steps:
1. dicom to nifti conversion
2. create separate b0 and TRACE files if not present
3. calculate ADC maps, brain extract and standardize
4. get measurements

Step 1 can be done using e.g. dcm2nii or mcverter
Steps 2-4 can be done using scripts provided 

Setup:
An example wrapper script is provided, edit where marked for your setup. 
Edit mk_b0_trace.sh (if used) to reflect your DWI format.
Edit mk_adc.sh to reflect the non-b0 b-value used.

Comments:
An "output basename" is optional. Input files can include 
paths, file extensions are optional. The "output basename"
can also include a path. msr_median.sh and msr_p85.sh are
basic wrappers for fslstats. A Matlab script also included
to run on mk_adc.sh output. 

Example:
bash adc_wrapper.sh dwi_file.nii.gz
bash adc_wrapper.sh /path/to/dwi_file Subj0001_20190728
bash /path/to/adc_wrapper.sh dwi_file /path/to/study_adcs/Subj0004_20190131