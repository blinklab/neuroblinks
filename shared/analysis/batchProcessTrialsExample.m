%%
user = 'user';
mouse = 'M001';
isi = 200;
session = 1;
us = 3;
cs = 1;
day_offset=0;
day = datestr(now-day_offset,'yymmdd');

folder = fullfile('d:\data',user, mouse, day);

trials = processTrials(fullfile(folder,'compressed'),...
    fullfile(folder,'compressed',sprintf('%s_%s_s01_calib.mp4',mouse,day))); 

save(fullfile(folder, 'trialdata.mat'),'trials');

[hf1,hf2]=makePlots(trials,isi,session,us,cs);

hgsave(hf1,fullfile(folder,'CRs.fig'));
hgsave(hf2,fullfile(folder,'CR_amp_trend.fig'));

print(hf1,fullfile(folder,sprintf('%s_%s_CRs.pdf',mouse,day)),'-dpdf')
print(hf2,fullfile(folder,sprintf('%s_%s_CR_amp_trend.pdf',mouse,day)),'-dpdf')

