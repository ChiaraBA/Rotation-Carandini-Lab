function [f,pow] = powerSpectrum(X,samp_interval, plot_flag, colour)

X = single(X);
L = length(X);
if nargin<2
    samp_interval = 1/30000;
end

if nargin<3
    plot_flag = 1;
end

NyLimit = (1/samp_interval)/2;

F = linspace(0,1,round(L/2))*NyLimit;

Y = fft(X)/L;

ampSpectrum = abs(Y(1:round(L/2)));
powerSpectrum = Y(1:round(L/2)).*conj(Y(1:round(L/2)));

if plot_flag
    figure;
    hold on;
    
    subplot(211)
    plot(F(1:50000),ampSpectrum(1:50000),'color', colour);
    title('Amplitude spectrum')
    xlabel('Frequency (Hz)')
    hold on;
    
    subplot(212)
    plot(F(1:50000),powerSpectrum(1:50000),'color', colour);
    title('Power spectrum')
    xlabel('Frequency (Hz)')
    hold on;

end

% data = single(X);
data = X;

%data = data - mean(data);
WL = (1/samp_interval)*10;
nO = round(WL*0.08);
[pow,f] = pwelch(data,WL,nO,[],(1/samp_interval));

range = find(f>0.5 & f<3000);% & ~(f>48 & f<52));

f = f(range);
pow = pow(range);
% end

% figure(2);
% for chan=14
%semilogy(f(range),pow(chan,range),'Color',rand(1,3)); hold on
% loglog(f,pow,'color', colour); hold on
% loglog(f,fastsmooth(pow,50,3,1),'color', colour, 'linewidth',1.5); hold on
% % end
% title('normalPlusShield2')
