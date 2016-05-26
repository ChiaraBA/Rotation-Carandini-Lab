%correlation between eyecoordinates and position of the mouse in the VR

%close all;
clear all;
clc;
animal='M120307_BALL';
iseries=322;
iexp=106;

expName2 = [animal '_' num2str(iseries) '_session_' num2str(iexp) '_trial001.mat'];
VRData = ['\\zserver\Data\ball\' animal filesep num2str(iseries) filesep expName2];
load(VRData)

expName1 = [animal '_' num2str(iseries) '_' num2str(iexp) '_eyetrack.mat'];
EyeTrackData = ['\\zserver\Data\EyeTrack\' animal filesep num2str(iseries) filesep num2str(iexp) filesep expName1];
load(EyeTrackData)


%load('\\zserver\Data\EyeTrack\M120307_BALL\312\101\M120307_BALL_312_101_eyetrack.mat')


n_trials= TRIAL.nCompTraj-1;
counterMissingData=zeros(1,n_trials);
avSpeed=zeros(n_trials,150);
avAcceleration=zeros(n_trials,150);
avXPos=zeros(n_trials,150);
avYPos=zeros(n_trials,150);
avEyeMov=zeros(n_trials,150);
avArea=zeros(n_trials,150);

for trial=1:n_trials

%VR info of each trial    

t_in=find(TRIAL.trialIdx==trial, 1 ); 
t_end=find(TRIAL.trialIdx==trial, 1, 'last' ); 
t_in=find(TRIAL.traj(t_in:t_end)~=0, 1 )+ t_in-1;
traj=TRIAL.traj(t_in:t_end);
speed=VRdata.ballspeed(t_in:t_end);
acceleration=diff(speed);

%position of the center of the pupil 
if ~isempty(eyetrack(1,trial,1).pupil)
PreviousPupil=eyetrack(1,trial,1).pupil;
end


for i=2:length(frameTimes{1,trial})
    if ~isempty(eyetrack(1,trial,i-1).pupil) && ~isnan(eyetrack(1,trial,i-1).pupil.Centroid(1))   
            
           eyeXCoor(i-1)=eyetrack(1,trial,i-1).pupil.Centroid(1);
           eyeYCoor(i-1)=eyetrack(1,trial,i-1).pupil.Centroid(2);
           area{trial}(i-1)=eyetrack(1,trial,i-1).pupil.Area;
           eyeMov{trial}(i-1)=sqrt((PreviousPupil.Centroid(1)-eyetrack(1,trial,i-1).pupil.Centroid(1))^2+ (PreviousPupil.Centroid(2)-eyetrack(1,trial,i-1).pupil.Centroid(2))^2); 
           PreviousPupil=eyetrack(1,trial,i-1).pupil;
       
    %if it doesn't find the pupil, it uses the coordinates of the pupil found at the previous time step  
    else  
       eyeXCoor(i-1)=NaN;%PreviousPupil.Centroid(1);
       eyeYCoor(i-1)=NaN;%PreviousPupil.Centroid(2);
       area{trial}(i-1)=NaN;%PreviousPupil.Area;
       eyeMov{trial}(i-1)=NaN;
       counterMissingData(trial)=counterMissingData(trial)+1;
    end
    
end


%set the same time axis
timepoints=min(frameTimes{1,trial}):0.0167:min([TRIAL.time(t_end)-TRIAL.time(t_in) max(frameTimes{1,trial})-0.0167]);
Traj{trial}=interp1((TRIAL.time(t_in:t_end)-TRIAL.time(t_in)),traj,timepoints);
Speed{trial}=interp1((TRIAL.time(t_in:t_end)-TRIAL.time(t_in)),speed,timepoints);
Acceleration{trial}=interp1((TRIAL.time(t_in:t_end-1)-TRIAL.time(t_in)),acceleration,timepoints);
EyeXCoor{trial}=interp1(frameTimes{trial}(1:length(frameTimes{1,trial})-1),eyeXCoor,timepoints);
EyeYCoor{trial}=interp1(frameTimes{trial}(1:length(frameTimes{1,trial})-1),eyeYCoor,timepoints);
EyeMov{trial}=interp1(frameTimes{trial}(1:length(frameTimes{1,trial})-1),eyeMov{trial},timepoints);
Area{trial}=interp1(frameTimes{trial}(1:length(frameTimes{1,trial})-1),area{trial},timepoints);

%calculate correlations 
% MaxLag=200;
% [corrPosEyeX(trial,:) lagsPosEyeX]=xcov(Traj{trial},EyeXCoor{trial},MaxLag,'coeff');
% [corrPosEyeY(trial,:) lagsPosEyeY]=xcov(Traj{trial},EyeYCoor{trial},MaxLag,'coeff');
% [corrEyeXSpeed(trial,:) lagsEyeXSpeed]=xcov(Speed{trial},EyeXCoor{trial},MaxLag,'coeff');
% [corrEyeYSpeed(trial,:) lagsEyeYSpeed]=xcov(Speed{trial},EyeYCoor{trial},MaxLag,'coeff');

%avererage speed at each position

for pos=1:150
   tpos=find(round(Traj{trial})==pos);
   if ~isempty(tpos)
   avSpeed(trial,pos)=nanmean(Speed{trial}(tpos));
   avAcceleration(trial,pos)=nanmean(Acceleration{trial}(tpos));
   avXPos(trial,pos)=nanmean(EyeXCoor{trial}(tpos));
   avYPos(trial,pos)=nanmean(EyeYCoor{trial}(tpos));
   avEyeMov(trial,pos)=nanmean(EyeMov{trial}(tpos));
   avArea(trial,pos)=nanmean(Area{trial}(tpos));
   else
   avSpeed(trial,pos)=NaN;
   avAcceleration(trial,pos)=NaN;
   avXPos(trial,pos)=NaN;
   avYPos(trial,pos)=NaN;
   avEyeMov(trial,pos)=NaN;
   avArea(trial,pos)=NaN;
   end
   clear tpos 
end




if trial ~= n_trials
  clear traj eyeXCoor eyeYCoor speed 
end

end


%calculate average over trials
% meanCorrPosEyeX=mean(corrPosEyeX,1);
% meanCorrPosEyeY=mean(corrPosEyeY,1);
% meanCorrEyeYSpeed=mean(corrEyeYSpeed,1);
% meanCorrEyeXSpeed=mean(corrEyeXSpeed,1);
% meanSpeedPos=mean(avSpeed,1);
% StDevSpeed=std(avSpeed,0,1);
% 
%plot
% figure;
% supertitle('Correlation Eye position with position in VR')
% subplot(1,2,1)
% plot(lagsPosEyeX,meanCorrPosEyeX)
% title('pupil position on x axis')
% subplot(1,2,2)
% plot(lagsPosEyeY,meanCorrPosEyeY)
% title('pupil position on y axis')
% figure;
% supertitle('Correlation Eye position with speed in VR')
% subplot(1,2,1)
% plot(lagsEyeXSpeed,meanCorrEyeXSpeed)
% title('pupil position on x axis')
% subplot(1,2,2)
% plot(lagsEyeYSpeed,meanCorrEyeYSpeed)
% title('pupil position on y axis')

for trial=1:n_trials
    figure;
    plot(avSpeed(trial,:))
    hold all
    title('Speed versus mouse position in VR')
    
    figure;
    plot(avXPos(trial,:))
    hold all
    title('Eye X position versus mouse position in VR')
    
    figure;
    plot(avYPos(trial,:))
    hold all
    title('Eye Y position versus mouse position in VR')
    
    figure;
    plot(avEyeMov(trial,:))
    hold all
    title('Eye movement versus mouse position in VR')
    
    figure;
    plot(avArea(trial,:))
    hold all
    title('Area versus mouse position in VR')
    
    figure;
    plot(avAcceleration(trial,:))
    hold all
    title('Acceleration versus mouse position in VR')
    
end


