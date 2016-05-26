%correlation between eyecoordinates and position of the mouse in the VR

%close all;
clear all;
load('\\zserver\Data\EyeTrack\M120203_BALL\220\102\M120203_BALL_220_102_eyetrack.mat')
load('\\zserver\Data\ball\M120203_BALL\220\M120203_BALL_220_session_102_trial001.mat')

n_trials= 20-TRIAL.info.abort;

speed=zeros(n_trials,150);

EyeXCoor=zeros(1,383);
EyeYCoor=zeros(1,383);
eyeMov=zeros(n_trials,383);
counterMissingData=0;



for trial=1:n_trials

%timing of each trial    
t_in=min(find(TRIAL.trialIdx==trial));
t_end=max(find(TRIAL.trialIdx==trial));
traj=TRIAL.traj(t_in:t_in+382);

%calculate speed in each position
trajRound=round(traj);

for pos=1:150
    
    tpos=find(trajRound==pos);
  
        if length(tpos)>1
           speed(trial,pos)=1/((max(tpos)-min(tpos))/60);
        else
           speed(trial,pos)=1/0.016; 
        end

    speed60Hz(tpos)=speed(trial,pos);    
    clear tpos
end



%get the position of the center of the pupil at each timepoint
centroidPrevious=eyetrack(1,trial,1).pupil.Centroid;

for i=1:length(traj)
    if ~isempty(eyetrack(1,trial,i).pupil)   
        
        %in case it finds more than one ellipse, it retains the ellipse
        %closer to the ellipse found at the previous time step 
        if length(eyetrack(1,trial,i).pupil)>1 
            
            for ellipse=1:length(eyetrack(1,trial,i).pupil)
              dist(ellipse)=sqrt((centroidPrevious(1)-eyetrack(1,trial,i).pupil(ellipse).Centroid(1))^2+ (centroidPrevious(2)-eyetrack(1,trial,i).pupil(ellipse).Centroid(2))^2); 
            end
            EyeXCoor(i)=eyetrack(1,trial,i).pupil(find(dist==min(dist))).Centroid(1);
            EyeYCoor(i)=eyetrack(1,trial,i).pupil(find(dist==min(dist))).Centroid(2);
            eyeMov(trial,i)=min(dist);
            centroidPrevious=eyetrack(1,trial,i).pupil(find(dist==min(dist))).Centroid;
            clear dist
            
        else
             
           EyeXCoor(i)=eyetrack(1,trial,i).pupil.Centroid(1);
           EyeYCoor(i)=eyetrack(1,trial,i).pupil.Centroid(2); 
           eyeMov(trial,i)=sqrt((centroidPrevious(1)-eyetrack(1,trial,i).pupil.Centroid(1))^2+ (centroidPrevious(2)-eyetrack(1,trial,i).pupil.Centroid(2))^2); 
           centroidPrevious=eyetrack(1,trial,i).pupil.Centroid;
        end
        
       
       
    %if it doesn't find the pupil, it uses the coordinates of the pupil found at the previous time step  
    else  
       EyeXCoor(i)=centroidPrevious(1);
       EyeYCoor(i)=centroidPrevious(2);
       counterMissingData=counterMissingData+1;
    end
    
end


%calculate correlations 
MaxLag=100;
[corrPosEyeX(trial,:) lagsPosEyeX]=xcov(traj',EyeXCoor,MaxLag,'none');
[corrPosEyeY(trial,:) lagsPosEyeY]=xcov(traj',EyeYCoor,MaxLag,'none');
[corrEyeXSpeed(trial,:) lagsEyeXSpeed]=xcov(speed60Hz(1:383),EyeXCoor,MaxLag,'none');
[corrEyeYSpeed(trial,:) lagsEyeYSpeed]=xcov(speed60Hz(1:383),EyeYCoor,MaxLag,'none');
% [corrPosSpeed(trial,:) lagsPosSpeed]=xcov(speed,1:150,MaxLag,'biased');

if trial ~= n_trials
  clear traj trajRound EyeXCoor EyeYCoor speed60Hz
end

end


%calculate average over trials
meanCorrPosEyeX=mean(corrPosEyeX,1);
meanCorrPosEyeY=mean(corrPosEyeY,1);
meanCorrEyeXSpeed=mean(corrEyeXSpeed,1);
meanCorrEyeYSpeed=mean(corrEyeYSpeed,1);
% meanCorrPosSpeed=mean(corrPosSpeed,1);
meanSpeed=mean(speed,1);
StDevSpeed=std(speed,0,1);

%plot
figure;
supertitle('Correlation Eye position with position in VR')
subplot(1,2,1)
plot(lagsPosEyeX,meanCorrPosEyeX)
title('pupil position on x axis')
subplot(1,2,2)
plot(lagsPosEyeY,meanCorrPosEyeY)
title('pupil position on y axis')

figure;
supertitle('Correlation Eye position with speed')
subplot(1,2,1)
plot(lagsEyeXSpeed,meanCorrEyeXSpeed)
title('pupil position on x axis')
subplot(1,2,2)
plot(lagsEyeYSpeed,meanCorrEyeYSpeed)
title('pupil position on y axis')

figure;
%plot(1:150,meanSpeed)
errorbar(meanSpeed,StDevSpeed)
title('Speed vs position in VR')

