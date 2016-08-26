function [Hulls, Tracks, ResultsStruct]= FissionFusionAnalysis(Tracks, Hulls, lifethresh, DXY_MAX, ResultsStruct)

    [Tracks, Hulls] = FindFissionOrFusion(Tracks, Hulls, lifethresh, DXY_MAX, 'Fission');
    [Tracks, Hulls] = FindFissionOrFusion(Tracks, Hulls, lifethresh, DXY_MAX, 'Fusion');
    
    [normFisPerFrame, normFusPerFrame] = NumFisFusPerFrame(Hulls, 'normalized');
    [FisPerFrame, FusPerFrame] = NumFisFusPerFrame(Hulls);
    
    % Save results
    ResultsStruct.NormalizedFission = normFisPerFrame;
    ResultsStruct.NormalizedFusion = normFusPerFrame;
    ResultsStruct.TotalFission = FisPerFrame;
    ResultsStruct.TotalFusion = FusPerFrame;
    
end

function [Tracks, Hulls] = FindFissionOrFusion(Tracks, Hulls, lifethresh, DXY_MAX, tag)
    
    switch tag
        case 'Fission'
            for s = 1:length([Tracks.StartFrame])
                f = Tracks(s).StartFrame;
                if f == 1 | Tracks(s).Lifetime < lifethresh;
                    continue;
                else
                    idx = [Tracks(s).HullIdx];
                    Hullsidx = idx(1); %starting hull
                    XY0 = Hulls(Hullsidx).xyzCenter; 
                    tn1 = f - 1;
                    HullsPrev = [find([Hulls.t] == tn1)]; 
                    [ origID mindist ] = NearestSelf( XY0, HullsPrev, Hulls );
                    if mindist > DXY_MAX
                        continue;
                    else
                        Tracks(s).OriginTrack = origID;
                        Hulls(Hullsidx).EventFission = 1;
                    end
                end
            end
        case 'Fusion'
            for s = 1:length([Tracks.EndFrame])
                f = Tracks(s).EndFrame;
                if f == max([Hulls.t]) | Tracks(s).Lifetime < lifethresh;
                    continue;
                else
                    idx = [Tracks(s).HullIdx];
                    Hullidx = idx(end);
                    XY0 = Hulls(Hullidx).xyzCenter;
                    tp1 = f + 1;
                    HullsFut = [find([Hulls.t] == tp1)];
                    [ mergeID mindist ] = NearestSelf( XY0, HullsFut, Hulls );
                    if mindist > DXY_MAX
                        continue;
                    else
                        Tracks(s).MergeTrack = mergeID;
                        Hulls(Hullidx).EventFusion = 1;
                    end
                end
            end
    end
end

function [ otherID mindist ] = NearestSelf( XY0, HullsOther, Hulls )

dist = []; 

    for k = 1:length(HullsOther); 
        XYn1 = Hulls(HullsOther(k)).xyzCenter;
        IDn1 = Hulls(HullsOther(k)).ID;
        diff = XY0-XYn1;
        d = norm([diff]);  
        dist = [dist; d XYn1 IDn1]; 
    end
    
[mindist idxmin] = min(dist(:,1));

otherID = dist(idxmin,end);

end

function [FisPerFrame, FusPerFrame] = NumFisFusPerFrame(Hulls, tag)

if ~exist('tag') || isempty(tag)
    tag = '';
end

if strcmp(tag, 'normalized')
    fPixels = CountForegroundPixels(Hulls);
end

maxt = max([Hulls.t]);
FisPerFrame = zeros(maxt,1);
FusPerFrame = zeros(maxt,1);

for t = 1:maxt;
    
    HullsCurrent = Hulls(find([Hulls.t] == t));
    
    NumFis = sum([HullsCurrent.EventFission]);
    NumFus = sum([HullsCurrent.EventFusion]);
    
    if strcmp(tag, 'normalized')
        FisPerFrame(t) = NumFis/fPixels(t);
        FusPerFrame(t) = NumFus/fPixels(t);
    else
        FisPerFrame(t) = NumFis;
        FusPerFrame(t) = NumFus;
    end
    
end
end

function fPixels = CountForegroundPixels(Hulls)

fPixels = [];

for t = 1:max([Hulls.t]);
    HullsCurrent = Hulls(find([Hulls.t] == t));
    Pix = 0;
    for k = 1:length(HullsCurrent);
        FPixFrame = length(HullsCurrent(k).PixelIdxList);
        Pix = Pix + FPixFrame;                
    end
    fPixels(t) = Pix;
end
fPixels = fPixels';
end