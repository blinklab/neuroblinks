function resetDevices()
%Reset cameras and open serial devices

imaqreset

s=instrfind('Status','Open');

if ~isempty(s)
    fclose(s);
end

end

