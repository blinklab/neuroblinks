function streamEyelid(hObject, handles)
updaterate=0.015;   % ~67 Hz

% Load objects from root app data
TDT=getappdata(0,'tdt');
vidobj=getappdata(0,'vidobj');

try
    while get(handles.togglebutton_stream,'Value') == 1
        metadata=getappdata(0,'metadata');  % Need to load metadata within this loop so the values update during streaming
        tic
        wholeframe=getsnapshot(vidobj);
        % roi=wholeframe(handles.y1:handles.y2,handles.x1:handles.x2);
        % Had to revise this to work with elliptical ROI
        roi=wholeframe.*uint8(metadata.cam.mask);
        eyelidpos=sum(roi(:)>=256*metadata.cam.thresh);
        TDT.SetTargetVal('task_timer.EyeVid',(eyelidpos-metadata.cam.calib_offset)/metadata.cam.calib_scale);
        %     TDT.SetTargetVal('Stim.EyeVid',sum(sum(im2bw(roi,metadata.cam.thresh))));
        
        
        stopTrial = str2double(get(handles.edit_StopAfterTrial,'String'));
        if stopTrial > 0 && metadata.cam.trialnum > stopTrial
            set(handles.toggle_continuous,'Value',0);
            set(handles.toggle_continuous,'String','Start Continuous');
        end
        
        % --- check Trigger from TDT (if OK, this sends trigger to TDT) ----
        if get(handles.toggle_continuous,'Value') == 1
            if TDT.GetTargetVal('task_timer.EyeReady'),
                TriggerStim(hObject, handles)
            end
        end
        
        t=toc;
        % -- pause in the left time -----
        d=updaterate-t;
        if d>0
            pause(d)        %   java.lang.Thread.sleep(d*1000);     %     drawnow
        else
            if get(handles.checkbox_verbose,'Value') == 1
                disp(sprintf('%s: Unable to sustain requested stream rate! Loop required %f seconds.',datestr(now,'HH:MM:SS'),t))
            end
        end
    end
catch
    disp('Aborted eye streaming.')
    set(handles.togglebutton_stream,'Value',0);
    return
end





% function streameyelid(handles)
% 
% updaterate=0.01;   % ~100 Hz
% 
% % Load objects from root app data
% TDT=getappdata(0,'tdt');
% src=getappdata(0,'src');
% vidobj=getappdata(0,'vidobj');
% metadata=getappdata(0,'metadata');
% 
% % d=1./500; % 2 ms timer
% d=updaterate;
% 
% try
% while get(handles.togglebutton_stream,'Value') == 1
%     
%     tic
%     wholeframe=getsnapshot(vidobj);
%     roi=wholeframe(handles.y1:handles.y2,handles.x1:handles.x2);
% %     binframe=im2bw(roi,metadata.thresh);
% %     eyelidpos=sum(sum(im2bw(roi,metadata.thresh)));
%     
% %     TDT.SetTargetVal('Stim.EyeVid',eyelidpos);
%     TDT.SetTargetVal('Stim.EyeVid',sum(sum(im2bw(roi,metadata.cam.thresh))));
%     t=toc;
%     
%     java.lang.Thread.sleep(d*1000);  % Note: sleep() accepts [mSecs] duration
%     drawnow
%     
%     if t>d
%         disp(sprintf('%s: Unable to sustain requested stream rate! Loop required %f seconds.',datestr(now,'HH:MM:SS'),t))
%     end
%     
% %     d=updaterate-t;
% %     if d>0
% %         java.lang.Thread.sleep(d*1000);  % Note: sleep() accepts [mSecs] duration
% %         drawnow
% %     else
% %         disp(sprintf('%s: Unable to sustain requested stream rate! Loop required %f seconds.',datestr(now,'HH:MM:SS'),t))
% %     end
% end
% catch
%     disp('Aborted eye streaming.')
%     return
% end

%-------- From Selmaan's program ---------%

% function streameyelid(handles)
% 
% global TDT metadata src vidobj
% 
% frames_per_trial=metadata.FPS.*metadata.T_length;
% TDT.SetTargetVal('ustim.FramePulse',1e3/(2*metadata.FPS));
% TDT.SetTargetVal('ustim.NumFrames',frames_per_trial);
% 
% vidobj.StopFcn=@AdvanceTrial;
% PauseDur=1/metadata.FPS+.0005;
% frame=1; updateFrame=metadata.FPS/str2double(get(handles.edit_UpdateRate,'String'));
% % try
%     while get(handles.togglebutton_stream,'Value') == 1
%         
%         wholeframe=getsnapshot(vidobj);
%         TDT.SetTargetVal('ustim.EyeVid',sum(sum(im2bw(wholeframe(handles.y1:handles.y2,handles.x1:handles.x2),metadata.thresh))));
%         if TDT.GetTargetVal('ustim.MatOK')==1
%             start(vidobj),TDT.SetTargetVal('ustim.ForceStart',1);
%         end
%         Pauser(PauseDur);
%         
%         if frame>updateFrame
%             drawnow
%             frame=1;
%         else
%             frame=frame+1;
%         end
%     end
