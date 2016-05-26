clear all; close all; clc

addpath '\\zserver\lab\Tmp\Chiara\ChronuxToolbox\spectral_analysis\continuous'

%%%%sleeping state
Sl_chnHP=21;
Sl_chnV1=5;
Sl_t_in=3E4*400; %in 30 kHz
Sl_t_end=3E4*470; %in 30 kHz
Sl_iexp=106;

%%%% stationary state
St_chnHP=27;
St_chnV1=10;
St_t_in=217*3E4;
St_t_end=338*3E4;
St_iexp=106;

%%%% running state
R_chnHP=21;
R_chnV1=10;
R_t_in= 15120000;
R_t_end=23100000;
R_iexp=106;


%%%Sleeping%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%load data

disp('working on SLEEPING STATE')

animal='M120307_BALL';
iseries=322;
iexp=Sl_iexp;
ChnHP=Sl_chnHP;
ChnV1=Sl_chnV1;
t_in=Sl_t_in;
t_end=Sl_t_end;

if iexp==106
load('VRDatasession106.mat')
TimeRec= 29527801;
elseif iexp==107
load('VRDatasession107.mat')
TimeRec= 33463922;
end

addpath \\zserver\Code\Spikes
global pepNEV;
global DIRS;
SetDefaultDirs;

CHANNELS_ORDER = MichiganGetLayout(animal,iseries,33);
expName1 = [animal '_' num2str(iseries) '_' num2str(iexp) '.ns5'];
ns5file1 = ['\\ZSERVER\Data\Cerebus\' animal filesep num2str(iseries) filesep num2str(iexp) filesep expName1];
[~,SamplingRateInKHZ,nchan] = nsopen2(ns5file1);

disp('Loading photodiode times')
NameTimes = [animal '_' num2str(iseries) '_' num2str(iexp) '_screenTimes.mat'];
filenameScreentime=['\\ZSERVER\Data\multichanspikes\' animal filesep num2str(iseries) filesep NameTimes];
load(filenameScreentime)


disp('Loading LFP data')
CHANNELS_ORDER = MichiganGetLayout(animal,iseries,33);
HP=find(CHANNELS_ORDER==ChnHP);
V1=find(CHANNELS_ORDER==ChnV1);
dataHP=double(pepNEV.ns.Data.data(HP,t_in:t_end));
dataV1=double(pepNEV.ns.Data.data(V1,t_in:t_end));

disp('Loading eye tracking data')
[EyeX,EyeY,EyeMov]=EyeTime(animal, iseries, iexp);

disp('Interpolating VR data')
Traj=interp1(dig_pho,VRdata.TRIAL.traj(2:length(VRdata.TRIAL.traj)),1:TimeRec);
Speed=interp1(dig_pho,VRdata.ballspeed(2:length(VRdata.ballspeed)),1:TimeRec);
eyeX=interp1(dig_pho(1:length(EyeX)),EyeX(1:length(EyeX)),1:TimeRec);
eyeY=interp1(dig_pho(1:length(EyeX)),EyeY(1:length(EyeX)),1:TimeRec);
eyeMov=interp1(dig_pho(1:length(EyeX)),EyeMov(1:length(EyeX)),1:TimeRec);

%general figure
figure;
supertitle('Sleeping state')

subplot(5,1,1)
plot(resample(dataV1,1,10))
axis tight
title('LFP in visual cortex')
xlabel('time, 30 KHz')
ylabel('LFP')

subplot(5,1,2)
plot(resample(dataHP,1,10))
axis tight
title('LFP in hippocampus')
xlabel('time, 30 KHz')
ylabel('LFP')

subplot(5,1,3)
plot(resample(eyeX(t_in:t_end),1,10))
axis tight
title('X coordinate of eye pupil')
xlabel('time, 30 KHz')
ylabel('')

subplot(5,1,4)
plot(resample(eyeY(t_in:t_end),1,10))
axis tight
title('Y coordinate of eye pupil')
xlabel('time, 30 KHz')
ylabel('')

subplot(5,1,5)
plot(resample(Speed(t_in:t_end),1,10))
axis tight
title('Moving speed of the animal')
xlabel('time, 30 KHz')
ylabel('')

disp('calculating power spectrum')
[f_expHP, pow_expHP] = powerSpectrum(dataHP,1/30000,0,'r');
[f_expV1, pow_expV1] = powerSpectrum(dataV1,1/30000,0,'b');

HighLimFreq=find(f_expHP<400, 1, 'last');

%power spectrum
figure;
loglog(f_expHP(1:HighLimFreq), f_expHP(1:HighLimFreq).*smooth(pow_expHP(1:HighLimFreq),30),'r')
hold on
loglog(f_expV1(1:HighLimFreq), f_expV1(1:HighLimFreq).*smooth(pow_expV1(1:HighLimFreq),30),'b')
title('Power spectrum in the sleeping state')
xlabel('Frequency, Hz')
ylabel('Power')
axis tight

save sleepingstate1.mat
saveas(1,'Sleeping1')
saveas(2,'Sleeping2')
%%%Stationary%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%load data
 
disp('working on STATIONARY STATE')

animal='M120307_BALL';
iseries=322;
iexp=St_iexp;
ChnHP=St_chnHP;
ChnV1=St_chnV1;
t_in=St_t_in;
t_end=St_t_end;

clear dataHP dataV1 f_expHP pow_expHP f_expV1 pow_expV1

if iexp~= Sl_iexp

clear VRdata dig_pho n_pho EyeX EyeY EyeMov Traj Speed eyeX eyeY eyeMov 


if iexp==106
load('VRDatasession106.mat')
TimeRec= 29527801;
elseif iexp==107
load('VRDatasession107.mat')
TimeRec= 33463922;
end


disp('Loading photodiode times')
NameTimes = [animal '_' num2str(iseries) '_' num2str(iexp) '_screenTimes.mat'];
filenameScreentime=['\\ZSERVER\Data\multichanspikes\' animal filesep num2str(iseries) filesep NameTimes];
load(filenameScreentime)

disp('Loading eye tracking data')
[EyeX,EyeY,EyeMov]=EyeTime(animal, iseries, iexp);

disp('Interpolating VR data')
Traj=interp1(dig_pho,VRdata.TRIAL.traj(2:length(VRdata.TRIAL.traj)),1:length(n_pho));
Speed=interp1(dig_pho,VRdata.ballspeed(2:length(VRdata.ballspeed)),1:length(n_pho));
eyeX=interp1(dig_pho(1:length(EyeX)),EyeX(1:length(EyeX)),1:TimeRec);
eyeY=interp1(dig_pho(1:length(EyeX)),EyeY(1:length(EyeX)),1:TimeRec);
eyeMov=interp1(dig_pho(1:length(EyeX)),EyeMov(1:length(EyeX)),1:TimeRec);

expName1 = [animal '_' num2str(iseries) '_' num2str(iexp) '.ns5'];
ns5file1 = ['\\ZSERVER\Data\Cerebus\' animal filesep num2str(iseries) filesep num2str(iexp) filesep expName1];

end


[~,SamplingRateInKHZ,nchan] = nsopen2(ns5file1);

disp('Loading LFP data')
HP=find(CHANNELS_ORDER==ChnHP);
V1=find(CHANNELS_ORDER==ChnV1);
dataHP=double(pepNEV.ns.Data.data(HP,t_in:t_end));
dataV1=double(pepNEV.ns.Data.data(V1,t_in:t_end));

%general figure
figure;
supertitle('Stationary state')

subplot(5,1,1)
plot(resample(dataV1,1,10))
axis tight
title('LFP in visual cortex')
xlabel('time, 30 KHz')
ylabel('LFP')

subplot(5,1,2)
plot(resample(dataHP,1,10))
axis tight
title('LFP in hippocampus')
xlabel('time, 30 KHz')
ylabel('LFP')

subplot(5,1,3)
plot(resample(eyeX(t_in:t_end),1,10))
axis tight
title('X coordinate of eye pupil')
xlabel('time, 30 KHz')
ylabel('')

subplot(5,1,4)
plot(resample(eyeY(t_in:t_end),1,10))
axis tight
title('Y coordinate of eye pupil')
xlabel('time, 30 KHz')
ylabel('')

subplot(5,1,5)
plot(resample(Speed(t_in:t_end),1,10))
axis tight
title('Moving speed of the animal')
xlabel('time, 30 KHz')
ylabel('')

disp('calculating power spectrum')
[f_expHP, pow_expHP] = powerSpectrum(dataHP,1/30000,0,'r');
[f_expV1, pow_expV1] = powerSpectrum(dataV1,1/30000,0,'b');



%power spectrum
figure;
loglog(f_expHP(1:HighLimFreq), f_expHP(1:HighLimFreq).*smooth(pow_expHP(1:HighLimFreq),30),'r')
hold on
loglog(f_expV1(1:HighLimFreq), f_expV1(1:HighLimFreq).*smooth(pow_expV1(1:HighLimFreq),30),'b')
title('Power spectrum in the stationary state')
xlabel('Frequency, Hz')
ylabel('Power')
axis tight




save statstate1.mat
saveas(3,'Stat1')
saveas(4,'Stat2')


%%%Running%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%load data
 
disp('working on RUNNING STATE')

animal='M120307_BALL';
iseries=322;
iexp=R_iexp;
ChnHP=R_chnHP;
ChnV1=R_chnV1;
t_in=R_t_in;
t_end=R_t_end;

clear dataHP dataV1 f_expHP pow_expHP f_expV1 pow_expV1 

if iexp~= St_iexp

clear VRdata dig_pho n_pho EyeX EyeY EyeMov Traj Speed eyeX eyeY eyeMov 


if iexp==106
load('VRDatasession106.mat')
TimeRec= 29527801;
elseif iexp==107
load('VRDatasession107.mat')
TimeRec= 33463922;
end

disp('Loading photodiode times')
NameTimes = [animal '_' num2str(iseries) '_' num2str(iexp) '_screenTimes.mat'];
filenameScreentime=['\\ZSERVER\Data\multichanspikes\' animal filesep num2str(iseries) filesep NameTimes];
load(filenameScreentime)

disp('Loading eye tracking data')
[EyeX,EyeY,EyeMov]=EyeTime(animal, iseries, iexp);

disp('Interpolating VR data')
Traj=interp1(dig_pho,VRdata.TRIAL.traj(2:length(VRdata.TRIAL.traj)),1:TimeRec);
Speed=interp1(dig_pho,VRdata.ballspeed(2:length(VRdata.ballspeed)),1:TimeRec);
eyeX=interp1(dig_pho(1:length(EyeX)),EyeX(1:length(EyeX)),1:TimeRec);
eyeY=interp1(dig_pho(1:length(EyeX)),EyeY(1:length(EyeX)),1:TimeRec);
eyeMov=interp1(dig_pho(1:length(EyeX)),EyeMov(1:length(EyeX)),1:TimeRec);


expName1 = [animal '_' num2str(iseries) '_' num2str(iexp) '.ns5'];
ns5file1 = ['\\ZSERVER\Data\Cerebus\' animal filesep num2str(iseries) filesep num2str(iexp) filesep expName1];

end


[~,SamplingRateInKHZ,nchan] = nsopen2(ns5file1);

disp('Loading LFP data') 
HP=find(CHANNELS_ORDER==ChnHP);
V1=find(CHANNELS_ORDER==ChnV1);
dataHP=double(pepNEV.ns.Data.data(HP,t_in:t_end));
dataV1=double(pepNEV.ns.Data.data(V1,t_in:t_end));

%general figure
figure;
supertitle('Running state')

subplot(5,1,1)
plot(resample(dataV1,1,10))
axis tight
title('LFP in visual cortex')
xlabel('time, 30 KHz')
ylabel('LFP')

subplot(5,1,2)
plot(resample(dataHP,1,10))
axis tight
title('LFP in hippocampus')
xlabel('time, 30 KHz')
ylabel('LFP')

subplot(5,1,3)
plot(resample(eyeX(t_in:t_end),1,10))
axis tight
title('X coordinate of eye pupil')
xlabel('time, 30 KHz')
ylabel('')

subplot(5,1,4)
plot(resample(eyeY(t_in:t_end),1,10))
axis tight
title('Y coordinate of eye pupil')
xlabel('time, 30 KHz')
ylabel('')

subplot(5,1,5)
plot(resample(Speed(t_in:t_end),1,10))
axis tight
title('Moving speed of the animal')
xlabel('time, 30 KHz')
ylabel('')

disp('calculating power spectrum')
[f_expHP, pow_expHP] = powerSpectrum(dataHP,1/30000,0,'r');
[f_expV1, pow_expV1] = powerSpectrum(dataV1,1/30000,0,'b');



saveas(5,'Run1')
%power spectrum
figure;
loglog(f_expHP(1:HighLimFreq), f_expHP(1:HighLimFreq).*smooth(pow_expHP(1:HighLimFreq),30),'r')
hold on
loglog(f_expV1(1:HighLimFreq), f_expV1(1:HighLimFreq).*smooth(pow_expV1(1:HighLimFreq),30),'b')
title('Power spectrum in the running state')
xlabel('Frequency, Hz')
ylabel('Power')
axis tight
saveas(6,'Run2')
%Spectrogram
flag=1;
clear dataV1 dataHP
dataV1=double(pepNEV.ns.Data.data(V1,:));  %I need the spectrogram for the whole session, also when animal is stationary
dataHP=double(pepNEV.ns.Data.data(HP,:));
[t,f,SV1,SHP,C,PHI,Speed,SV1_ord,SHP_ord,Speed_ord,T,SCross]=spectrogramFun(flag,dataV1,dataHP,VRdata,dig_pho);

%coherency
figure;
supertitle('Running state')
subplot(1,2,1)
plot_matrix(C,t,f,'n')  
title('coherency magnitude')
axis tight

subplot(1,2,2)
plot_matrix(PHI,t,f,'n')
title('coherency phase')
axis tight
saveas(7,'RunCoherency')
%spectrogram and animal speed
figure;
supertitle('Theta oscillation depends on the animal state')
subplot(3,1,1)
plot_matrix(SV1,t,f)
title('Spectrogram of visual cortex LFP')
axis tight

subplot(3,1,2)
plot_matrix(SHP,t,f) 
title('Spectrogram of hippocampus LFP')
axis tight

subplot(3,1,3)
plot(t,Speed)
title('Speed of the animal')
axis tight
saveas(8,'RunSPec1')
%Spectrogram with increasing speed
figure;
supertitle('Theta oscillation depends on the running speed')
subplot(3,1,1)
plot_matrix(SV1_ord,t,f)
title('Spectrogram of visual cortex LFP')
axis tight 
set(gca,'XTick',t(1):50:t(end))
set(gca,'XTickLabel',T(1:50:end))

subplot(3,1,2)
plot_matrix(SHP_ord,t,f) 
title('Spectrogram of hippocampus LFP')
axis tight
set(gca,'XTick',t(1):50:t(end))
set(gca,'XTickLabel',T(1:50:end))

subplot(3,1,3)
plot(t,Speed_ord)
title('Speed of the animal')
axis tight
set(gca,'XTick',t(1):50:t(end))
set(gca,'XTickLabel',T(1:50:end))

saveas(9,'RunSPec2')
save runstate1.mat

%plot theta power with increasing speed
minTh=find(f>7.,1);
maxTh=find(f<9,1,'last');
HP_ord_th=mean(SHP_ord(:,minTh:maxTh),2);
V1_ord_th=mean(SV1_ord(:,minTh:maxTh),2);

figure;
subplot(2,1,1)
plot(Speed_ord,V1_ord_th,'bo')
title('Theta power in visual cortex')
set(gca,'XTick',[])
axis tight

subplot(2,1,2)
plot(Speed_ord,HP_ord_th,'ro')
title('Theta power in hippocampus')
set(gca,'XTick',[])
axis tight

% subplot(3,1,3)
% plot(t,Speed_ord)
% title('Speed of the animal')
% axis tight
% set(gca,'XTick',t(1):50:t(end))
% set(gca,'XTickLabel',T(1:50:end))

%correlation coefficients
ThHP_CC=corr(Speed_ord,HP_ord_th); %0.799 
ThV1_CC=corr(Speed_ord,V1_ord_th); %0.6093 

%plot gamma power with increasing speed
minG=find(f>40,1);
maxG=find(f<60,1,'last');
HP_ord_g=mean(SHP_ord(:,minG:maxG),2);
V1_ord_g=mean(SV1_ord(:,minG:maxG),2);

figure;
subplot(2,1,1)
plot(Speed_ord,V1_ord_g,'bo')
title('Gamma power in visual cortex')
set(gca,'XTick',[])
axis tight

subplot(2,1,2)
plot(Speed_ord,HP_ord_g,'ro')
title('Gamma power in hippocampus')
set(gca,'XTick',[])
axis tight

% subplot(3,1,3)
% plot(t,Speed_ord)
% title('Speed of the animal')
% axis tight
% set(gca,'XTick',t(1):50:t(end))
% set(gca,'XTickLabel',T(1:50:end))

%correlation coefficients
GHP_CC=corr(Speed_ord,HP_ord_g); %0.7704
GV1_CC=corr(Speed_ord,V1_ord_g); %0.4811


     