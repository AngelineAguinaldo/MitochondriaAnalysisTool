function RunMitochondriaAnalysis(varStruct)

% INITIALIZE CONSTANTS -----------------------------------------------
    progHandle = varStruct.ProgressStringHandle;

    % Experiment Settings
    COND = {varStruct.Cond1_Label, varStruct.Cond2_Label};
    TOTEXP = [sum(arrayfun(@(x) ~strcmp(x,''), varStruct.Cond1_ExpDir)), ...
              sum(arrayfun(@(x) ~strcmp(x,''), varStruct.Cond2_ExpDir))];
    EXP1_DIR = varStruct.Cond1_ExpDir;
    EXP2_DIR = varStruct.Cond2_ExpDir;
    EXPDIR = [EXP1_DIR; EXP1_DIR];
%     parpool(sum(TOTEXP))
    
    % Print Settings
    bMakeMovie = varStruct.bRenderMov;
    bPrintTIFs = varStruct.bPrintTIFs;
    SAVEPATH = varStruct.SaveToPath;
    AXES = varStruct.ImageAxesHandle;
    
    % Analysis Settings
    bFisFus = varStruct.bFisFusAnalysis;
    bVelocity = varStruct.bVelocityAnalysis;
    bSpatial = varStruct.bSpatialAnalysis;
    
    FisFus_DXYMAX = varStruct.FisFus_DXYmax;
    FisFus_Life = varStruct.FisFus_LifeThresh;
    
    Vel_Life = varStruct.Velocity_LifeThresh;
    Vel_TotTime = varStruct.Velocity_TotalTime;
    Vel_Res = varStruct.Velocity_PixelRes;
    
    MAXT = str2num(varStruct.MaxTime);
    
    % Initialize Results Structure
    LabResults = struct('Condition', cell(sum(TOTEXP), 1), ...
                        'ExperimentNum', cell(sum(TOTEXP), 1), ...
                        'ImagePaths', cell(sum(TOTEXP), 1), ...
                        'Hulls', cell(sum(TOTEXP), 1), ...
                        'Tracks', cell(sum(TOTEXP), 1), ...
                        'TotalFission', cell(sum(TOTEXP), 1), ...
                        'TotalFusion', cell(sum(TOTEXP), 1), ...
                        'NormalizedFission', cell(sum(TOTEXP), 1), ...
                        'NormalizedFusion', cell(sum(TOTEXP), 1), ...
                        'AllVelocity', cell(sum(TOTEXP), 1), ...
                        'AverageVelocity', cell(sum(TOTEXP), 1), ...
                        'MedianVelocity', cell(sum(TOTEXP), 1), ...
                        'Spatial', cell(sum(TOTEXP), 1));
    
% RUN PARRALLEL POOL ------------------------------------------------------
%     parfor G = 1:sum(TOTEXP)
    G = 1;
    
        if any(G == linspace(1,TOTEXP(1)))
            C = 1;
            E = G;
        else
            C = 2;
            E = G - TOTEXP(1);
        end
        
        cond = COND{C};
        
        LabResults(G).Condition = cond;
        LabResults(G).ExperimentNum= E;
                
        allTIFs = FindWithExtension(EXPDIR{G}, '.tif');
        
        LabResults(G).ImagePaths = allTIFs;
        
        set(progHandle, 'String', ['Segmenting ' num2str(cond) '_0' num2str(E) '...']);
        [segHulls, imSize] = MitochondriaSegmentor(allTIFs, MAXT);
        
        set(progHandle, 'String', ['Tracking ' num2str(cond) '_0' num2str(E) '...']);
        Hulls = MitochondriaTracker(segHulls, 50, imSize, MAXT);
        Tracks = MitochondriaTrackAnalysis(Hulls);
        
        if bFisFus
            set(progHandle, 'String', ['Analyzing Fission and Fusion ' num2str(cond) '_0' num2str(E) ' ...']);
            [Hulls, Tracks, LabResults(G)] = FissionFusionAnalysis(Tracks, Hulls, FisFus_Life, FisFus_DXYMAX, LabResults(G));
        end
        
        if bVelocity
            set(progHandle, 'String', ['Analyzing Velocity ' num2str(cond) '_0' num2str(E) ' ...']);
            LabResults(G) = MitoVelocityAnalysis(Tracks, Hulls, LabResults(G), Vel_Life, Vel_totTime, MAXT, Vel_Res);
        end
        
        if bSpatial
            set(progHandle, 'String', ['Analyzing Spatialtemporal Distribution ' num2str(cond) '_0' num2str(E) ' ...']);
%             MitoSpatialAnalysis();
        end
        
        LabResults(G).Hulls = Hulls;
        LabResults(G).Tracks = Tracks;
        
        if bMakeMovie || bPrintTIFs
            set(progHandle, 'String', ['Printing Media ' num2str(cond) '_0' num2str(E) ' ...']);
            savemedia = [SAVEPATH '\' cond '\'];
            PrintMedia(allTIFs, Hulls, savemedia, bMakeMovie, bPrintTIFs, AXES);
        end
        
    ShowBoxplots(LabResults, COND);
    SaveAnalysisResults(SAVEPATH, COND, LabResults);
    
end

function FilesWithExt = FindWithExtension(ROOT, extString)
    currDir = dir(ROOT);
    bDesireExt = false(length(currDir),1);
    
    for i = 1:length(currDir)
        [~, ~, ext] = fileparts([ROOT '\' currDir(i).name]);
        if strcmp(ext, extString)
            bDesireExt(i) = true;
        end
    end
    
    allFnames = {currDir.name};
    NameWithExt = allFnames(bDesireExt);
    
    FilesWithExt = strcat([ROOT '\'], NameWithExt)';
end

function SaveAnalysisResults(path, conds, MitochondriaLabResults)

if ~strcmp(path(end), '\')
    path = [path '\'];
end

savefile = [path 'MitochondriaAnalysis_' conds{1} '-' conds{2} '_' datestr(now, 'mm-dd-yyyy') '.mat'];

save(savefile, 'MitochondriaLabResults');

end
