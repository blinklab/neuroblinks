function plotOneEyelid(t_num)

trials=getappdata(0,'trials');
if ~isfield(trials,'eye'),    return,  end
% --- identifying 3 periods ----
ti_pre=find(trials.eye(t_num).time<=trials.eye(t_num).stimtime.st{1});
ti_post=find(trials.eye(t_num).time>trials.eye(t_num).stimtime.st{end});
ti_isi=find(trials.eye(t_num).time>trials.eye(t_num).stimtime.st{1} & trials.eye(t_num).time<=trials.eye(t_num).stimtime.st{end});
% -- plot stim ----
stimcol={'r' 'g' 'b'};
for i=1:length(trials.eye(t_num).stimtime.st)
    if trials.eye(t_num).stimtime.en{i}>0
        rectangle('position',[trials.eye(t_num).stimtime.st{i} -0.15+0.04*(i-1) trials.eye(t_num).stimtime.en{i} 0.04],...
            'facecolor',stimcol{trials.eye(t_num).stimtime.cchan(i)},'edgecolor','none')
    end
end
% -- plot eye ----
plot(trials.eye(t_num).time(1:ti_pre(end)+1),trials.eye(t_num).trace(1:ti_pre(end)+1),'k'), 
plot(trials.eye(t_num).time(ti_post(1)-1:end),trials.eye(t_num).trace(ti_post(1)-1:end),'b'), 
plot(trials.eye(t_num).time(ti_isi),trials.eye(t_num).trace(ti_isi),'r'),




