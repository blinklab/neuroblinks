function true=iseven(num)

% true=iseven(num) - Returns 1 for even NUM, 0 for odd

if mod(num,2) == 0
    true = 1;
else true = 0;
end

