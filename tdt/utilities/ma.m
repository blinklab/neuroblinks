function y = ma(x,n)

% ma calculates n points moving average.
%
%   y = ma(x,n)
%
%     y : Output
%     x : Input
%     n : The number of data points.
%         It should be n>=3 and an odd number.
%
%                          2000,Oct.19
%                          By Y. Tasaki
%
% Revision by Shane so function can be used universally: If n is even, use
% n-1. If n equals 1 return input unchanged.

if iseven(n)
    n=n-1;
end

if n==1
    y=x;
    return
end

a = [1];
b = [(1:n)./(1:n)/n];
d = length(x);
n1 = (n+1)/2;
n2 = n-1;
n3 = d-(n-2);
n4 = d-((n-1)/2);

y = filter(b,a,x);

for i = n1:n2
   y(i) = sum(x(1:i))/i;
   for j = n3:n4
      z(j) = sum(x(j:d))/(d-j+1);
   end
end

y = [y(n1:length(y)) z(n3:n4)];