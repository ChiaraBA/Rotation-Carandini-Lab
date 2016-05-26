

animal='M120307_BALL';
iseries=322;
iexp=106;

addpath \\zserver\Code\Spikes
global pepNEV;
global DIRS;

SetDefaultDirs;

expName2 = [animal '_' num2str(iseries) '_session_' num2str(iexp) '_trial001.mat'];
VRData = ['\\zserver\Data\ball\' animal filesep num2str(iseries) filesep expName2];
load(VRData)

CHANNELS_ORDER = MichiganGetLayout(animal,iseries,33);
expName1 = [animal '_' num2str(iseries) '_' num2str(iexp) '.ns5'];
ns5file1 = ['\\ZSERVER\Data\Cerebus\' animal filesep num2str(iseries) filesep num2str(iexp) filesep expName1];
[~,SamplingRateInKHZ,nchan] = nsopen2(ns5file1);

NameTimes = [animal '_' num2str(iseries) '_' num2str(iexp) '_screenTimes.mat'];
filenameScreentime=['\\ZSERVER\Data\multichanspikes\' animal filesep num2str(iseries) filesep NameTimes];
load(filenameScreentime)

Traj=interp1(dig_pho,VRdata.TRIAL.traj(2:length(VRdata.TRIAL.traj)),1:length(n_pho));
Speed=interp1(dig_pho,VRdata.ballspeed(2:length(VRdata.ballspeed)),1:length(n_pho));

timeframe_st=1;
timeframe_end=60*30000*3;

CHANNELS_ORDER = MichiganGetLayout(animal,iseries,33);
HP=find(CHANNELS_ORDER==29);
V1=find(CHANNELS_ORDER==12);
chnHP=pepNEV.ns.Data.data(HP,timeframe_st:timeframe_end);
chnV1=pepNEV.ns.Data.data(V1,timeframe_st:timeframe_end);


figure;
subplot(4,1,1)
plot(Traj(timeframe_st:timeframe_end))
title('traj')
axis tight

subplot(4,1,2)
plot(Speed(timeframe_st:timeframe_end))
title('speed')
axis tight

subplot(4,1,3)
plot(chnHP)
title('hippocampus')
axis tight

subplot(4,1,4)
plot(chnV1)
title('V1')
axis tight

[f_expHP, pow_expHP] = powerSpectrum(chnHP(1,2852727:3416184),1/30000,0,'r');
[f_expV1, pow_expV1] = powerSpectrum(chnV1(1,2852727:3416184),1/30000,0,'b');


figure;
loglog(f_expHP(1:5230), f_expHP(1:5230).*smooth(pow_expHP(1:5230),20),'r')
hold on
loglog(f_expV1(1:5230), f_expV1(1:5230).*smooth(pow_expV1(1:5230),20),'b')
title('run, timepoints 2852727:3416184 timeframe_st=1; ')
axis tight

