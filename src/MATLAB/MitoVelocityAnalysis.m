function ResultsStruct = MitoVelocityAnalysis(Tracks, Hulls, ResultsStruct, lifethresh, totTime, maxt, res)

if isempty(lifethresh) || ~exist('lifethresh')
    lifethresh = 5;
end

if isempty(totTime) || nargin < 5
    error('Need total time for velocity calculation.');
end

if isempty(maxt) || nargin < 6
    error('Need total frames for velocity calculation.')
end

if isempty(res) || nargin < 7
    error('Need pixel resolution for velocity calculation.')
end

[allVel, avgVel, medVel] = CalculateMitoVelocity(Tracks, Hulls, lifethresh, totTime, maxt, res);

ResultsStruct.AllVelocity = allVel;
ResultsStruct.AverageVelocity = avgVel;
ResultsStruct.MedianVelocity = medVel;

end

function [allVel, avgVel, medVel] = CalculateMitoVelocity(Tracks, Hulls, lifethresh, totTime, maxt, res)

tpf = totTime/maxt;

allVel = cell(length(Tracks), 1);
avgVel = zeros(length(Tracks), 1);
medVel = zeros(length(Tracks), 1);

for i = 1:length(Tracks);
    
    xyzCenters = CollectTrackCentroids(Tracks(i), Hulls);
    
    if size(xyzCenters,2) ~= length(res)
        error('Pixel Resolution Dimensions does not equal dimensions of Hulls')
    end
    xyzCenters = xyzCenters .* repmat(res, size(xyzCenters,1), 1);
    
    dxyz = diff(xyzCenters);
    
    if size(dxyz,1) < 2
        continue
    end
    
    dist = zeros(length(dxyz), 1);
    for dd = 1:length(dxyz);
        dist(dd) = norm(dxyz(dd,:));
    end
    
    velocity = dist./tpf;
    allVel{i} = velocity;
    avgVel(i) = mean(velocity);
    medVel(i) = median(velocity);
    
end

end

function xyzCenters = CollectTrackCentroids(Track, Hulls)

hh = [Track.HullIdx];
xyzCenters = [Hulls(hh).xyzCenter];
xyzCenters = reshape(xyzCenters, length([Hulls(1).xyzCenter]), [])';

end



