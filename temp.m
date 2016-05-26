
n_cell=16;
n_position=150;
n_trials=max(es.trialID)-1;
SpkCnt=zeros(n_cell,n_position,n_trials);
TimeSpent=zeros(n_cell,n_position,n_trials);

for trial=1:n_trials
    
t_in=min(find(es.trialID==trial));
t_end=max(find(es.trialID==trial));
traj=round(es.traj(t_in:t_end));


for cel=1:n_cell

for pos=1:n_position
    tpos=find(traj==pos);
    if ~isempty(tpos)
      tspike=find(es.spikeTrain(t_in+tpos,cel)>0);
      multiplespikes=sum((es.spikeTrain(tspike,cel)>1).*(es.spikeTrain(tspike,cel)-1));
      SpkCnt(cel,pos,trial) = (length(tspike)+multiplespikes);
      TimeSpent(cel,pos,trial) = (max(tpos)-min(tpos))/60;
      clear tspike
    else
      SpkCnt(cel,pos,trial) =NaN;
      TimeSpent(cel,pos,trial) =NaN;
    end
    clear tpos
end

end

clear traj

end


%calculate average over trials

stdev = std(SpkCnt./TimeSpent,0,3);
TimeSpent = nanmean(TimeSpent,3);
SpkCnt = nanmean(SpkCnt,3);

%smoothing
FRsmthwin   = 20;
sGrid = 80; s = (-sGrid:sGrid)/sGrid;
sfilt = exp(-s.^2/(1/FRsmthwin)^2/2);
sfilt = sfilt./sum(sfilt);

TimeSpentSmoo=zeros(n_cell,n_position);
SpkCntSmoo=zeros(n_cell,n_position);


for cel=1:n_cell
TimeSpentSmoo(cel,:) = conv(TimeSpent(cel,:), sfilt,'same'); 
SpkCntSmoo(cel,:) = conv(SpkCnt(cel,:), sfilt,'same'); 
end

avFreq = SpkCntSmoo./TimeSpentSmoo;


%plot
figure;
for cel=1:n_cell
subplot(4,4,cel)
plot(avFreq(cel,:))
%errorbar(avFreq(cel,:),stdev(cel,:))
xlim([0 150])
str=['cell' num2str(cel)];
title(str)
end

% figure;
% for cel=1:n_cell
% subplot(4,4,cel)
% plot(TimeSpentSmoo(cel,:))
% %xlim([-2 160])
% title('Time')
% end
% 
% figure;
% for cel=1:n_cell
% subplot(4,4,cel)
% plot(SpkCntSmoo(cel,:))
% %xlim([-2 160])
% str=['cell' num2str(cel)];
% title('spike count')
% end

