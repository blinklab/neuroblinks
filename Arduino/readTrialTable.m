function trialvars=readTrialTable(current_tr)
% Return current row from trial table, which is stored in the app data for the root figure

trialtable=getappdata(0,'trialtable');

[m,n]=size(trialtable);


current_tr=mod(current_tr-1,m)+1;	% Cycle through the table again if we've reached the end
% if current_tr == 0
% 	current_tr=m;	% Need this additional step b/c mod(x,{x,2x,3x,..})==0, which happens when we reach the last item in the table
% end


trialvars=trialtable(current_tr,:);