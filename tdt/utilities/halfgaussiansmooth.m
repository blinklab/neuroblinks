function smooth=halfgaussiansmooth(x,sigma)
% SMOOTHED=GAUSSIANSMOOTH(X,SIGMA)
% Smooth data X with non causal half gaussian kernel defined by SD=SIGMA (in units of number of
% datapoints)

% Make gaussian kernel
% Take only part of function within 99% confidence interval, so 3*SD
gausskern=gaussfun(-3*sigma:3*sigma,sigma);
% gausskern=gausskern(ceil(length(gausskern)/2):end);  % causal
gausskern=gausskern(1:floor(length(gausskern)/2));  % non-causal
gausskern=gausskern./sum(gausskern);    % Normalize to sum of 1 so no scaling

%zero-pad input based on length of kernel
ng=length(gausskern);
nx=length(x);
if nx < ng
    Warning(sprintf(['Function gaussiansmooth(): input vector shorter than kernel' ...
        'Input: %i, Kernel: %i'], nx, ng));
end

% Pad data endpoints with mean of first 'ng' and last 'ng' points, where ng
% is the length of the gaussian kernel
x=[ones(size(gausskern))*mean(x(1:ng)), x(:)', ones(size(gausskern))*mean(x(end-ng+1:end))]; % x(:)' ensures row vector
  
% Do convolution. Output is length(x)+length(gausskern)-1
smooth=conv(x,gausskern);
% Remove padding
smooth(1:ng)=[];
smooth(end-ng+1:end)=[];

% Correct for size increase from convolution
n=ng;
if isodd(n)
    d1=(n-1)/2;
    d2=(n-1)/2;
else
    d1=n/2-1;
    d2=n/2;
end
smooth=smooth(d1:end-d2-1);

return

% % old version 
% % Do gaussian smoothing
% sigma=2;
% gausskern=gaussfun(ONbins,sigma);
% % Take only part of function within 99% confidence interval
% n=length(gausskern);
% if isodd(n)
%     n=n-1;
% end
% gausskern=gausskern(n/2-3*sigma:n/2+3*sigma+1);   % 99% of gaussian is within 3 SDs
% gausskern=gausskern./sum(gausskern);    % Normalize to sum of 1 so no scaling
% 
% %zero-pad input based on length of kernel
% n=length(gausskern);
% pdrONzeroed=[zeros(size(gausskern)), pdrON, zeros(size(gausskern))];
%     
% pdrONsmooth=conv(pdrONzeroed,gausskern);
% % Remove zero-padding
% pdrONsmooth(1:length(gausskern))=[];
% pdrONsmooth(length(pdrONsmooth)-length(gausskern)+1:end)=[];
% 
% % Correct for size increase from convolution
% n=length(gausskern);
% if isodd(n)
%     n=n-1;
% end
% pdrONsmooth=pdrONsmooth(n/2:end-n/2);