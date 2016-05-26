function [stats] = trackEyeParam(S,flag_plot)


% ROI S = I(:,:)
myfilter = fspecial('gaussian',[3 3], 1);
S = (S - min(S(:)))./(max(S(:))-min(S(:)));
S(S>0.35) = 0.35;
S = (S - min(S(:)))./(max(S(:))-min(S(:)));

S1 = imadjust(S);

% smoothing
S2 = imfilter(S1, myfilter, 'replicate');

% contrast enhance
S3 = imadjust(S2);
S3=S2;
% thresholding for pupil
S4 = S3<0.15; %original 0.4
R4  = S3>0.8;

%removing borders
S4(1:2,:) = 0;
S4(end-1:end,:) = 0;
S4(:,1:2) = 0;
S4(:,end-1:end) = 0;

se = strel('disk',10);
% removing small objects
S5 = bwareaopen(S4,10); %S5 = bwareaopen(S4,40);
S5 = imclose(S5, se);
R5 = bwareaopen(R4,10); %R5 = bwareaopen(R4,40);



stats.pupil = regionprops(S5, 'Centroid', 'MajorAxisLength', 'MinorAxisLength', 'Area', 'Orientation'); %pupil parameters
disp([stats.pupil.Area     sum(S(S4))])
stats.reflection = regionprops(R5, 'Centroid', 'MajorAxisLength', 'MinorAxisLength', 'Area', 'Orientation'); %reflectance from the LED
stats.reflectance = sum(S(S4))/stats.pupil.Area; %average light reflected by a pupil pixel AP 1-2011

if nargin>1 && flag_plot,
    
    figure(2)
    subplot(2,5,1)
    imagesc(S); axis off
    colormap(gray)
    operation = ['Normalization '];
    title(operation);
    
    subplot(2,5,2)
    imagesc(S2); axis off
    operation = 'Filtering';
    title(operation);
    
    subplot(2,5,3)
    imagesc(S3); axis off
    operation = 'Contrast enhancing';
    title(operation);
    
    subplot(2,5,4)
    imagesc(S4); axis off
    operation = 'Pupil';
    title(operation);
    
    subplot(2,5,5)
    imagesc(S5); axis off
    operation = 'fill and remove';
    title(operation);
    for i=1:size(stats.pupil,1)
        hold on
        plot(stats.pupil(i).Centroid(1),stats.pupil(i).Centroid(2),'or')
    end
    
    subplot(2,5,9)
    imagesc(R4); axis off
    operation = 'Reflection';
    title(operation);
    
    subplot(2,5,10)
    imagesc(R5); axis off
    operation = 'remove';
    title(operation);
    for i=1:size(stats.reflection,1)
        hold on
        plot(stats.reflection(i).Centroid(1),stats.reflection(i).Centroid(2),'or')
    end
end