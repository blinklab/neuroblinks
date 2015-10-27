function trialtable=makeTrialTable(paramtable_data,randomize)
	% Generate full trial table from parameter table in which first column is an integer specifying the number of repeats for the other parameters in that row.
	% NOTE: This function expects a properly formatted table in which the first column always specifies the number of repeats, even if only one repeat is desired.


[m,n]=size(paramtable_data);
trialtable=[];

blk_set=unique(paramtable_data(:,end-1)');

for blk=blk_set,
    temp_trialtable=[];
    for i=find(paramtable_data(:,end-1)'==blk);
        r=paramtable_data(i,1);
        temp_trialtable=[temp_trialtable; repmat(paramtable_data(i,2:end-2),r,1)];
        % if r=0, repmat returns [], so the row will be ignored.
    end
    rep_blk=max(paramtable_data((paramtable_data(:,end-1)==blk),end));
    if rep_blk==0, rep_blk=1; end

    if randomize
        rng('shuffle');     % Need to do this first to seed the RNG with current time
        [m,n]=size(temp_trialtable);
        for j=1:rep_blk,
            trialtable=[trialtable; temp_trialtable(randperm(m),:)];
        end
    else
        trialtable=[trialtable; repmat(temp_trialtable,rep_blk,1)];
    end
end

% for i=1:m
%     r=paramtable_data(i,1);
%     trialtable=[trialtable; repmat(paramtable_data(i,2:end),r,1)];
% end

% if randomize
%     [m,n]=size(trialtable);
%     trialtable=trialtable(randperm(m),:);
% end
