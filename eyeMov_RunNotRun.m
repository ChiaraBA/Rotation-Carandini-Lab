

clear all;
clc;
animal='M120307_BALL';
iseries=322;
iexp=106;

expName2 = [animal '_' num2str(iseries) '_session_' num2str(iexp) '_trial001.mat'];
VRData = ['\\zserver\Data\ball\' animal filesep num2str(iseries) filesep expName2];
load(VRData)

expName1 = [animal '_' num2str(iseries) '_' num2str(iexp) '_eyetrack.mat'];
EyeTrackData = ['\\zserver\Data\EyeTrack\' animal filesep num2str(iseries) filesep num2str(iexp) filesep 'newparams' filesep expName1];
load(EyeTrackData)

n_trials=max(TRIAL.trialIdx)-1;
counterMissingData=zeros(1,n_trials);

t_in=find(TRIAL.trialIdx==1, 1 ); 
t_end=find(TRIAL.trialIdx==1, 1, 'last' ); 
t_in=find(TRIAL.traj(t_in:t_end)~=0, 1 )+ t_in-1;
count=t_in;
EyeX(1:t_in-1)=NaN;
EyeY(1:t_in-1)=NaN;
EyeMov(1:t_in-1)=NaN;
Area(1:t_in-1)=NaN;

for trial=1:n_trials


if ~isempty(eyetrack(1,trial,1).pupil)
PreviousPupil=eyetrack(1,trial,1).pupil;
end


for i=2:length(frameTimes{1,trial})
    if ~isempty(eyetrack(1,trial,i-1).pupil) && ~isnan(eyetrack(1,trial,i-1).pupil.Centroid(1))   
            
           eyeXCoor(i-1)=eyetrack(1,trial,i-1).pupil.Centroid(1);
           eyeYCoor(i-1)=eyetrack(1,trial,i-1).pupil.Centroid(2);
           area(i-1)=eyetrack(1,trial,i-1).pupil.Area;
           eyeMov(i-1)=sqrt((PreviousPupil.Centroid(1)-eyetrack(1,trial,i-1).pupil.Centroid(1))^2+ (PreviousPupil.Centroid(2)-eyetrack(1,trial,i-1).pupil.Centroid(2))^2); 
           PreviousPupil=eyetrack(1,trial,i-1).pupil;
       
    %if it doesn't find the pupil, it uses the coordinates of the pupil found at the previous time step  
    else  
       eyeXCoor(i-1)=NaN;%PreviousPupil.Centroid(1);
       eyeYCoor(i-1)=NaN;%PreviousPupil.Centroid(2);
       area(i-1)=NaN;%PreviousPupil.Area;
       eyeMov(i-1)=NaN;
       counterMissingData(trial)=counterMissingData(trial)+1;
    end
    
end

if trial==size(eyetrack,2)
disp('n')
end

eyeXCoor=interp1(frameTimes{trial}(1:length(frameTimes{1,trial})-1), eyeXCoor, TRIAL.time(t_in:t_end)-TRIAL.time(t_in));
eyeYCoor=interp1(frameTimes{trial}(1:length(frameTimes{1,trial})-1), eyeYCoor, TRIAL.time(t_in:t_end)-TRIAL.time(t_in));
eyeMov=interp1(frameTimes{trial}(1:length(frameTimes{1,trial})-1), eyeMov, TRIAL.time(t_in:t_end)-TRIAL.time(t_in));
%area=interp1(frameTimes{trial}(1:length(frameTimes{1,trial})-1), area, TRIAL.time(t_in:t_end)-TRIAL.time(t_in));

if length(eyeXCoor)~= length(TRIAL.time(t_in:t_end)-TRIAL.time(t_in))
    disp('ahahahahah')
end

if trial~=size(eyetrack,2)
End=t_end; 
t_in=find(TRIAL.trialIdx==trial+1, 1 ); 
t_end=find(TRIAL.trialIdx==trial+1, 1, 'last' ); 
t_in=find(TRIAL.traj(t_in:t_end)~=0, 1 )+ t_in-1;
IntervalTwoTrials=t_in-End-1;

EyeX(count+length(eyeXCoor):count+length(eyeXCoor)+IntervalTwoTrials-1)=NaN;
EyeY(count+length(eyeYCoor):count+length(eyeYCoor)+IntervalTwoTrials-1)=NaN;
EyeMov(count+length(eyeMov):count+length(eyeMov)+IntervalTwoTrials-1)=NaN;
%Area(count+length(area):count+length(area)+IntervalTwoTrials-1)=NaN;
else
    IntervalTwoTrials=0;
end 


EyeX(count:count+length(eyeXCoor)-1)=eyeXCoor;
EyeY(count:count+length(eyeXCoor)-1)=eyeYCoor;
EyeMov(count:count+length(eyeXCoor)-1)=eyeMov;
%Area(count:count+length(eyeXCoor)-1)=area;


count=count+length(eyeYCoor)+IntervalTwoTrials;

clear eyeXCoor eyeYCoor eyeMov

end




t_end=find(TRIAL.trialIdx==n_trials, 1, 'last' );

figure;
subplot(4,1,1)
plot(VRdata.ballspeed(1:t_end))
title(['Speed' num2str(iexp)])

subplot(4,1,2)
plot(EyeX)
title('X')

subplot(4,1,3)
plot(EyeY)
title('Y')

subplot(4,1,4)
plot(TRIAL.traj)
title('traj')

figure;
subplot(2,1,1)
plot(VRdata.ballspeed(1:t_end))
title(['Speed' num2str(iexp)])

subplot(2,1,2)
plot(EyeMov)
title('Eye movement')





