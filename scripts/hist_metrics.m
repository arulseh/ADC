%%%%%%%%%%%%%%%%%%%%%%%%%
% get histogram metrics

% assumes input files in this format:
% ID_DATE_*.nii.gz
% ID_DATE_brainmask.nii.gz

close all; clear;

%%SETUP%%%%%%%%%%%%%%%%%%
mydir = '/Users/aaron/matlab/';
DirDataIn = [mydir 'DATA/ADC/ADC_STD_IMG/'];
%DirMaskIn = [mydir 'DATA/ADC/ADC_MASK/'];
DirDataOut = [mydir 'DATA/ADC/ADC_STD_CSV/'];
ext = 'nii.gz';
datastr = 'ADC_brain_std';
maskstr = 'brainmask';
%%%%%%%%%%%%%%%%%%%%%%%%%

cd(DirDataIn);
d = dir(['*' datastr '.' ext]);
fns = char({d.name}); 

for f=1:size(fns,1);
	ADCIMG = read_avw(fns(f,:));
	[IDToken,remain] = strtok(fns(f,:),'_');
	DateToken = strtok(remain,'_');
%	MASK = read_avw([DirMaskIn IDToken '_' DateToken '_' maskstr '.' ext]);
	MASK = read_avw([IDToken '_' DateToken '_' maskstr '.' ext]);
	X = ADCIMG(MASK==1);
	tmparr = zeros(1,7);
	tmparr(1,1) = skewness(X); 
	tmparr(1,2) = kurtosis(X); 
	tmparr(1,3) = entropy(X); 
	tmparr(1,4) = median(X); 
	tmparr(1,5) = mode(X); 
	tmparr(1,6) = prctile(X,15);
	tmparr(1,7) = prctile(X,85);
	csvwrite([DirDataOut IDToken '_' DateToken '_' datastr '.csv'], tmparr);
end

