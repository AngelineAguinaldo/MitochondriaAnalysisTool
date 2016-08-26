function Tracks = MitochondriaTrackAnalysis(Hulls)

Tracks = struct;
id = unique([Hulls.ID]);

for m = 1:length(id)
    Tracks(m).ID = id(m);
    Tracks(m).HullIdx = [find([Hulls.ID] == id(m))];
    IDloc = Tracks(m).HullIdx;
    Tracks(m).Frame = [Hulls(IDloc).t];
    Tracks(m).Lifetime = length([Tracks(m).Frame]);
    Tracks(m).StartFrame = Tracks(m).Frame(1);
    Tracks(m).EndFrame = Tracks(m).Frame(end);
end

end