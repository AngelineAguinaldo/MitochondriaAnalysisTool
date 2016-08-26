function [Hulls, imSize] = MitochondriaSegmentor(imFiles, maxt)
    Hulls = [];
    
    for t = 1:maxt;
        
        im = imread(imFiles{t});
        
        imSize = size(im);
        
        nh = struct('ID', [], 't', [], 'xyzCenter', [], 'PixelIdxList', [], 'Color', []);
        
        MF=5;
%         colormap(gray)
%         imagesc(im); axis off
        im = mat2gray(im);

        h = fspecial('gaussian',9,.5); %[9 9] filter size, 0.5 stddev
        imfilt = imfilter(im, h, 'symmetric');

        for j=1:25
            imfilt = imfilter(imfilt, h, 'symmetric'); %applying recursive Guassian filtering on the filtered image
        end

        imhfreq = max((im - imfilt), zeros(size(im))); %if im-imfilt is negative, make it 0
        imf = medfilt2(imhfreq,[MF MF]); %med filter applied
        imf = mat2gray(imf);
%         imagesc(imf);

%         hold off
%         imagesc(im); axis off
%         hold on

        levelRaw = graythresh(im);
        bwRaw = im2bw(im,levelRaw); %black and white of raw image

        pix=imf(bwRaw); %?

        level=graythresh(pix);
        bw=im2bw(imf,level); %black and white of filtered image

        bw = bwareafilt(bw, [10, Inf]);

        CC = bwconncomp(bw);
        hullsProp = regionprops(CC,'centroid');

        %Create hulls
        for h = 1:CC.NumObjects
            nh(h).ID = -1;
            nh(h).t = t;
            nh(h).xyzCenter = hullsProp(h).Centroid;
            nh(h).PixelIdxList = CC.PixelIdxList{h};
        end
        
        Hulls = [Hulls nh];
    end
    
end