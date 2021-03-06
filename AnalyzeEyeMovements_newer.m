%function AnalyzeEyeMovements(server, animal, iseries, iexp, irepeat)
% 2011-06 AS & AP  created it to track eye movements
% 2011-07
% 2011-13 AS made the script a function in which inputs can be given

clear all
addpath \\ZSERVER\Code\Spikes
SetDefaultDirs;
addpath \\ZSERVER\Code\MouseEyeTrack\'Camera code'

% if nargin>1
%     switch server
%         case 'zserver2'
%             s = 1;
%         case 'zeye'
%             s = 2;
%     end
%     if s==2,
%         DIRS.EyeTrack = 'Z:\WORK\EyeTrack';
%         DIRS.EyeCamera = '\\zeye\C\Data\Camera';
%     elseif s==3,
%         DIRS.EyeCamera = '\\zi\C\Data\Camera';
%     end
% end

% addpath('\\Zserver\Code\MouseEyeTrack\Camera code','-begin');
% if nargin<5
    str = {'zserver2','zeye','zi'};
    [s,v] = listdlg('PromptString','Where is the data saved?:',...
        'SelectionMode','single','ListSize',[200 100],...
        'ListString',str);
    if s==2,
        DIRS.EyeTrack = 'Z:\WORK\EyeTrack';
        DIRS.EyeCamera = '\\zeye\C\Data\Camera';
    elseif s==3,
        DIRS.EyeCamera = '\\zi\C\Data\Camera';
    end
    
    %% select the experiment
    
    prompt={'Animal name:',...
        'Series number:',...
        'Experiment number:'...
        'Repeat:',...
    'Show VideoStream'};
    name='Input experiment pars (y/n)';
    numlines=1;
    %defaultanswer={sprintf('M%6.0f_BALL',str2double(datestr(date,'yymmdd'))),'2','2','0','y'};
    defaultanswer={'M120307_BALL','322','106','0','y'};
    
    options.Resize='on';
    options.WindowStyle='normal';
    options.Interpreter='tex';
    
    answer = inputdlg(prompt,name,numlines,defaultanswer,options);
    
    animal = answer{1};
    iseries = str2double(answer{2});
    iexp = str2double(answer{3});
    irepeat = str2double(answer{4});
    
% end

if answer{5}=='y',
    flag_plot = 1;
else
    flag_plot = 0;
end

if irepeat == 0
    all_reps = 1;
else
    all_reps = 0;
end

%% load the data

if iexp <100
    p = ProtocolLoad(animal,iseries,iexp);
    nstim = p.nstim;
    nreps = p.nrepeats;
else
    addpath \\ZSERVER\Code\MouseRoom\BallTools\'other related files'
    [VRdata, VRdata_o] = VRBallLoad(animal, iseries, iexp);
    nstim = 1;
    if iexp<200
        nreps = max(VRdata.TRIAL.trialIdx)-1;
    else
        nreps = max(VRdata_o.TRIAL.trialIdx)-1;
    end
    p(1).nstim = nstim;
    p(1).nreps = nreps;
    p(1).seqnums = 1:nreps;
    p(1).pfiledurs(1,1) = round(VRdata.EXP.maxTrialDuration*10);
    
end

DataDir = fullfile(DIRS.EyeCamera,animal,num2str(iseries),num2str(iexp));
SaveDir = fullfile(DIRS.EyeTrack,animal,num2str(iseries),num2str(iexp));
mkdir(SaveDir);

stimlist = (1:nstim);
% ns = length(stimlist);

if all_reps
    RepeatTensor = cell(nstim,nreps);
    
    for irepeat = 1:nreps
        for is = 1:nstim
            
            istim = stimlist(is);
            FileIndex = p.seqnums(istim,irepeat);
            FileName    = fullfile(DataDir,[animal '_' num2str(FileIndex) '.mat']);
            
            [Tensor,photoDiod,ttPD,ttCam] = loadOneCameraFile(FileName, p.pfiledurs(1,1));
            
            RepeatTensor{istim,irepeat} = single(Tensor);
            frames(istim, irepeat) = size(RepeatTensor{istim,irepeat},3);
            frameTimes{istim,irepeat} = ttCam;
        end
    end
else
    RepeatTensor = cell(nstim,1);
    
    for is = 1:nstim
        
        istim = stimlist(is);
        FileIndex = p.seqnums(istim,irepeat);
        FileName    = fullfile(DataDir,[animal '_' num2str(FileIndex) '.mat']);
        
        [Tensor,photoDiod,ttPD,ttCam] = loadOneCameraFile(FileName);
        
        RepeatTensor{is} = single(Tensor);
        frames(istim) = size(RepeatTensor{istim},3);
        frameTimes{is} = ttCam;
    end
    
end

% AS commented out
% if nstim == 1
%     RepeatTensor = RepeatTensor{1};
% end


% frames = min(frames(:));


%% define a ROI
[nr,nc,nt] = size(RepeatTensor{1,1});
figure('Name','Set the ROI');

% S = RepeatTensor{1,1}(:,:,2);
% S = S/mean(S(:)); %normalize to the average light level AP Feb 12
% % ROI S = I(:,:)
% myfilter = fspecial('gaussian',[3 3], 1);
% S = (S - min(S(:)))./(max(S(:))-min(S(:)));
% S(S>0.35) = 0.35;
% S = (S - min(S(:)))./(max(S(:))-min(S(:)));
% S1 = imadjust(S);
% % smoothing
% S2 = imfilter(S1, myfilter, 'replicate');
% % contrast enhance
% S3 = imadjust(S2,[.15,1],[],.5);
% S = S3;
% clear S1 S2 S3;

%imagesc( S );
imagesc( RepeatTensor{1,1}(:,:,2) ); %
colormap bone
axis image
title('Stimulus 1 -- select a ROI or hit ctrl-C');
hold on

FlagDoNotCrop = true;

FlagDoNotCrop = waitforbuttonpress;
point1 = get(gca,'CurrentPoint');    % button down detected
finalRect = rbbox;                   % return figure units
point2 = get(gca,'CurrentPoint');    % button up detected
point1 = round(point1(1,1:2));              % extract x and y
point2 = round(point2(1,1:2));
pp = min(point1,point2);             % calculate locations
if pp(1)<1
    pp(1) = 1;
elseif pp(1)>nc
    pp(1) = nc;
end
if pp(2)<1
    pp(2)= 1;
elseif pp(2)>nr
    pp(2)= nr;
end
offset = abs(point1-point2);         % and dimensions
pp_plusoffset = pp + offset;
if pp_plusoffset(1)>nc,
    offset(1) = nc-pp(1);
end
if pp_plusoffset(2)>nr
    offset(2)= nr-pp(2);
end
x = pp(1) + [0 offset(1) offset(1) 0 0];
y = pp(2) + [0 0 offset(2) offset(2) 0];

plot(x,y,'r','linewidth',5)          % draw box around selected region

if FlagDoNotCrop, close(gcf); end

%% crop the tensor to the ROI
% nten = length(RepeatTensor);
if ~FlagDoNotCrop
    for irepeat = 1:nreps
        for istim = 1:nstim
            RepeatTensor{istim,irepeat} = RepeatTensor{istim,irepeat}( pp(2)+[0:offset(2)], pp(1)+[0:offset(1)], 1:frames(irepeat) );
        end
    end
end

%% track eye


%blink detection and removal
counter_blinking=0;

for irepeat = 1:nreps
for istim = 1:nstim
        
averageTensor=mean(RepeatTensor{istim,irepeat},3);


for tensor=2: size(RepeatTensor{istim,irepeat},3)
  Correlation(tensor)=corr(reshape(RepeatTensor{istim,irepeat}(:,:,tensor),[],1),reshape(averageTensor,[],1));
end

threshold=mean(Correlation)-2*std(Correlation);

for tensor=2: size(RepeatTensor{istim,irepeat},3)
  if Correlation(tensor)<threshold
    RepeatTensor{istim,irepeat}(:,:,tensor)=NaN;
    counter_blinking=counter_blinking+1;
  end
end

clear Correlation 

end
    
end


%if there are more than one dark region, the user identifies the pupil at the first timepoint
S = RepeatTensor{1,1}(:,:,2);
eyetrack(1,1,1)= trackEyeParam3(S,1);
if  length(eyetrack(1,1,1).pupil)>1 
     disp('found more than one dark region:')
     
     for i=1:length(eyetrack(1,1,1).pupil)  
       disp(['region number ', num2str(i)])
       xy_coordinates_of_centroid=eyetrack(1,1,1).pupil(i).Centroid
       area=eyetrack(1,1,1).pupil(i).Area
     end
     
     truePupil=input('which region is the pupil?');
     previousPupil=eyetrack(1,1,1).pupil(truePupil);
      
end



%eye track

for irepeat = 1:nreps
    for istim = 1:nstim
        [nr,nc,nt] = size(RepeatTensor{istim,irepeat});
        for t = 2:nt
            
            S = RepeatTensor{istim,irepeat}(:,:,t);
            eyetrack(istim,irepeat,t-1)= trackEyeParam3(S,flag_plot);



            %if it finds more than one dark region, it saves only the region
            %closer to the pupil that was found at the previous time step
            if length(eyetrack(istim,irepeat,t-1).pupil)>1
                
                for ellipse=1:length(eyetrack(istim,irepeat,t-1).pupil)
                   dist(ellipse)=sqrt((previousPupil.Centroid(1)-eyetrack(istim,irepeat,t-1).pupil(ellipse).Centroid(1))^2+ (previousPupil.Centroid(2)-eyetrack(istim,irepeat,t-1).pupil(ellipse).Centroid(2))^2); 
                end
                eyetrack(istim,irepeat,t-1).pupil=eyetrack(istim,irepeat,t-1).pupil(find(dist==min(dist)));
                clear dist     
            end
            
              
             %save the last pupil that was found 
             if ~isempty(eyetrack(istim,irepeat,t-1).pupil)   
                 previousPupil= eyetrack(istim,irepeat,t-1).pupil;
             end
            
            
             
        end
    end
end


%plot
Area = zeros(nreps*nstim*nt,1);
Center = zeros(nreps*nstim*nt,2);
Reflectance = zeros(nreps*nstim*nt,1);
figure('Name','Center')
set(gca, 'YDir', 'reverse');

hold on;
ti = 1;
counter_missingdata=0;
for istim=1:nstim
    for irepeat= 1:nreps

        for t=1:(size(RepeatTensor{istim,irepeat},3)-1)
            if ~isempty(eyetrack(istim,irepeat,t).pupil) 
                Area(ti) = eyetrack(istim,irepeat,t).pupil.Area;
                Center(ti,:) = eyetrack(istim,irepeat,t).pupil.Centroid;
                Reflectance(ti) = eyetrack(istim,irepeat,t).reflectance;
                plot(eyetrack(istim,irepeat,t).pupil.Centroid(1),eyetrack(istim,irepeat,t).pupil.Centroid(2), '.', 'markersize',10)
                hold on
                axis([ 0 size(S,2) 0  size(S,1)]);
                ti = ti + 1;
            else 
                disp(['pupil not found on stim ' num2str(istim) ' and irepeat ' num2str(irepeat) ' and time ' num2str(t)]);
                counter_missingdata=counter_missingdata+1;
            end
            
        end
    end
end

disp(['pupil not found ' num2str(counter_missingdata) ' times out of ' num2str(ti+counter_missingdata) ' frames' ]);
disp(['number of blinks detected: ' num2str(counter_blinking) ]);


figure('Name','Area vs Time')
plot(Area)
figure('Name','Reflectance vs Time')
plot(Reflectance)

%% save tracking information and processed tensor of ROI
saveFileName = fullfile(SaveDir,[animal '_' num2str(iseries) '_' num2str(iexp) '_eyetrack.mat']);
save (saveFileName, 'RepeatTensor','eyetrack','x','y', 'frameTimes','VRdata');
saveas(2,fullfile(SaveDir,'pupil.fig'))
saveas(3,fullfile(SaveDir,'center.fig'))
saveas(4,fullfile(SaveDir,'area.fig'))
saveas(5,fullfile(SaveDir,'reflectance.fig'))


