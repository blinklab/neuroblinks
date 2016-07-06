function yy = rebin(x,d,e)

% yy = rebin(x,d,e)  Re-Bin hist vector x using bin size of e (seconds)
% 
% e must be larger than current binsize (d) and will be converted to whole
% number multiple of current binsize.  Binsize should be specified in
% seconds.  X should be histogram vector.  
%

[m,n]=size(x);

if m > 1
    error('X must be a vector');
end

if e < d
    error('New bin size must be greater than old one')
end

a=ceil(e./d);      % Make e whole number multiple of d
e=d.*a;             % Not output, but can be checked for debugging

b=mod(n,a);

yy=[];
for i=1:a:n-b
    s=sum(x(i:i+a-1));
%     s=sum(x(i:i+a));
    yy=[yy s];
end

if b > 0            % Add bin at tail end, corrected for shorter binsize
    s=sum(x(n-b+1:n));
    yy=[yy s.*(b./a)];
end