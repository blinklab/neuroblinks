function eventchans=TDTgetEventChans(TTX)
% Strobe+ (all epoch data is probably stored as this type, otherwise modify
% code)
ev=TTX.GetEventCodes(257);
nev=length(ev);

eventchans=cell(nev,1);
for i=1:nev
    eventchans{i}=TTX.CodeToString(ev(i));
end