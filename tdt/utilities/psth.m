function [hstdata,varargout]=psth(data,triggertm,binsz,pretm,posttm,varargin)
% Generate PSTH of data based on arbitrary trigger time 
% [hstdata,{rasterdata},{countdata}]=psth(data,triggertm,binsz,pretm,posttm,{smoothing type,kernel size},{useindex})
%
% Outputs psth HST counts with a given BINSZ, PRETIME, and POSTTIME.
% Pre and post time are both specified as positive numbers. 
% HSTDATA is a 2xn matrix containing hist counts and bins.
% Optionally also outputs full RASTER using 100 us resolution (rows are
% sweeps, with the last row being raster bins with 100 us resolution) 
% and hist COUNTS (2xn) for the raster using the 100 us bin size. 
%
% If SMOOTHING TYPE is specified, smooths data using specified kernel type
% and parameters. Right now only gaussian ('gauss'), rectangular (moving average; 'rect'), 
% and (experimental) non-causal half gaussian ('halfgauss') filters are implemented. 
% Kernel size should be specified in same units as data, e.g. seconds, not data points. 


sint=0.0001; % 100 us
raster=zeros(length(triggertm),round((pretm+posttm)./sint));
% We make raster bins 2 elements too big so we can chop off the ends
rastbins=-pretm-sint:sint:posttm;   
histbins=-pretm:binsz:posttm-binsz;


try
    for i=1:length(triggertm)
        tmphist=hist(data,rastbins+triggertm(i));
        raster(i,:)=tmphist(2:end-1);
    end
catch
    disp(sprintf('Trigger time %5.4f produced an error in PSTH function at loop iteration %d.',triggertm(i),i));
    lasterr;
    disp('Press any key to continue.');
    pause;
end


count=sum(raster,1);
hst=rebin(count./length(triggertm),sint,binsz);


if nargin >= 7   % if smoothing is desired
    smtype=lower(varargin{1});
    smkernsize=varargin{2};
    smpoints=round(smkernsize./binsz);
    
    if smkernsize < binsz
        warning('Kernel size for smoothing should be larger than bin size');
        smkernsize=binsz;
    end
    
    switch smtype
        case 'gauss'
            hst=gaussiansmooth(hst,smpoints);
        case 'halfgauss' %non-causal
            hst=halfgaussiansmooth(hst,smpoints);
        case 'rect'
            hst=ma(hst,smpoints);
        otherwise
            warning('Smoothing type not recognized. Using no smoothing.')
            hst=ma(hst,1);  % "moving average" with 1 point = no change
    end    
end


hstdata=[hst; histbins];
rasterdata=[raster; rastbins(2:end-1)];
countdata=[count; rastbins(2:end-1)];

if nargout > 1
    varargout{1}=rasterdata;
end

if nargout > 2
    varargout{2}=countdata;
end