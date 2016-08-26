function PrintMedia(allTIFs, Hulls, saveto, bMakeMovie, bPrintTIFs, ImageAxis, trackColor)
if nargin < 7
    trackColor = [];
end

maxt = max([Hulls.t]);

if ~exist(saveto, 'dir');
    mkdir(saveto);
end

if bMakeMovie
    [~, name, ~] = fileparts(allTIFs{1});
    movname = [saveto name '.mp4'];    
    vidObj = VideoWriter(movname, 'MPEG-4');
    vidObj.Quality = 100;
    vidObj.FrameRate = 10;
    open(vidObj);
    mov = cell(maxt,1);
end

for i = 1:length(allTIFs)
    
    im = imread(allTIFs{i});
    DrawTracks(Hulls, im, i, ImageAxis, trackColor);
    
    if bPrintTIFs
        [~, name, ~] = fileparts(allTIFs{i});
        TIFname = [saveto name];
        print(TIFname, '-dtiff')
    end

    if bMakeMovie
        mov{i} = getframe(gca);
        A = mov{i}.cdata;

        fr = im2frame(A);
        writeVideo(vidObj, fr);
    end
    
end

if bMakeMovie
    close(vidObj);
end
    
end

function DrawTracks(Hulls, im, t, ImageAxis, trackColor)

if ~exist('trackColor') || isempty(trackColor)
    trackColor = [];
end

axes(ImageAxis); axis off
imagesc(im); colormap('gray');

imSize = size(im);

currHulls = Hulls([Hulls.t] == t);

for h = 1:length(currHulls);
    bw = zeros(size(im));
    if ~isfield(Hulls,'PixelIdxList');
        cm = currHulls(h).xyCenter;
        hold on; 
        if ~isempty(trackColor)
            plot(cm(1), cm(2), 'Color', trackColor, 'MarkerSize', 5, 'Marker', '.');
        else
            plot(cm(1), cm(2), 'Color', currHulls(h).Color, 'MarkerSize', 5, 'Marker', '.');
        end
    else
        bw(currHulls(h).PixelIdxList) = 1;
        BB = bwboundaries(bw);
        hold on;
        if ~isempty(trackColor)
            plot(BB{1}(:,2), BB{1}(:,1), 'Color', trackColor);
        else
            plot(BB{1}(:,2), BB{1}(:,1), 'Color', currHulls(h).Color);
        end
    end
end

drawnow
hold off
axis off

    
end