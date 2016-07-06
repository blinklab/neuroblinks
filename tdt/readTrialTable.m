function trialvars=readTrialTable(current_tr)
% Return current row from trial table, which is stored in the app data for the root figure

trialtable=getappdata(0,'trialtable');

[m,n]=size(trialtable);

current_tr=mod(current_tr-1,m)+1;	% Cycle through the table again if we've reached the end

trialvars=trialtable(current_tr,:);
