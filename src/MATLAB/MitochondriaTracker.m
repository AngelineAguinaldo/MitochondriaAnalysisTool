function Hulls = MitochondriaTracker(Hulls, DXY_MAX, imSize, tmax)

if isempty('DXY_MAX') || ~exist('DXY_MAX');
    DXY_MAX = 25;
end

if nargin < 4 || isempty(tmax)
    tmax=max([Hulls.t]);
end

set(0,'RecursionLimit',900)

for p = 1; %labeling IDs
    ID = 0;
    for i=1:length(Hulls)
        if Hulls(i).t == p;
            ID = ID + 1;
            Hulls(i).ID=ID;
        else
            Hulls(i).ID=-1;
        end
    end
end

for t=1:tmax-1
    th=find([Hulls.t]==t);
    th1=find([Hulls.t]==t+1);
    
    if isempty(th) | isempty(th1)
        continue
    end
    
    d=[];
    for i=1:length(th)
        
        for j=1:length(th1)
            d(i,j)=Inf;
            xyz=Hulls(th(i)).xyzCenter; 
            xyz1=Hulls(th1(j)).xyzCenter;
            dxy=norm([xyz-xyz1]); %Euclidean distance between two points
                       
            if dxy>DXY_MAX
                continue
            end
            
            indPixels = Hulls(th(i)).PixelIdxList;
            indPixels1 = Hulls(th1(j)).PixelIdxList;
            dpixel = PixelMatching(indPixels, indPixels1, DXY_MAX, imSize);
            
            lifetime=length(find([Hulls.ID]==Hulls(th(i)).ID));
            
            d(i,j)=10*dxy/DXY_MAX + 25*dpixel; %dxy/DXY_MAX normalizes distance based on given max distance
            
            d(i,j)=d(i,j)*(t/(lifetime))^2; 
            
        end
    end
       
    [ass cost]=assignmentoptimal(d);
    
    for i=1:length(ass)
        if 0==ass(i)
            continue
        end
        Hulls(th1(ass(i))).ID=Hulls(th(i)).ID;
    end
    
    %if not tracked to anything from previous frame, will label as new track
    newTracks = find([Hulls.ID]==-1);
    maxID = max([Hulls.ID]);
    
    for b = 1:length(newTracks)
        maxID = maxID+1;
        Hulls(newTracks(b)).ID=maxID;
    end
    
end

Hulls = AssignColors(Hulls, 8);

end

function Hulls = AssignColors(Hulls, int)
    CM = jet(int);
    ColorAssign = struct('TrackID', [], 'Color', []);
    count = 1;
    for i = 1:max([Hulls.ID]);
        ColorAssign(i).TrackID = i;
        ColorAssign(i).Color = CM(count, :);
        count = count + 1;
        if count > size(CM,1)
            count = 1;
        end
    end
    
    for T = 1:length(ColorAssign);
        trackHulls = find([Hulls.ID] == T);
        for TT = 1:length(trackHulls);
            Hulls(trackHulls(TT)).Color = [ColorAssign(T).Color];
        end
    end
end

function dpixel = PixelMatching(indPixels, indPixels1, rad, imSize)

dpixel = Inf;

% unflatten index pixels
[r0 c0] = ind2sub(imSize, indPixels);
[r1 c1] = ind2sub(imSize, indPixels1);

cm0 = [mean(r0), mean(c0)]; % find center of mass

% create circular window with given radius, centered at cm
L = linspace(0, 2.*pi, 360);
windx = rad.*cos(L)' + cm0(2);
windy = rad.*sin(L)' + cm0(1);

% conduct pixel matching only for pixels within window
inWind = inpolygon(c1, r1, windx, windy); 

if all(~inWind)
    return
elseif any(inWind)
    r1 = r1(inWind);
    c1 = c1(inWind);
end

xy0 = [c0 r0];
xy1 = [c1 r1];

dAll = zeros(size(xy0,1),1);

for i = 1:size(xy0,1);
    dist = [];
    for j = 1:size(xy1,1)
         dtmp = norm(abs([xy0(i,:) - xy1(j,:)]));
         dist = [dist; dtmp];
    end
    dAll(i) = min(dist); % find closest pixel distance
end

dpixel = mean(dAll); % take mean of all pixel distances

end
