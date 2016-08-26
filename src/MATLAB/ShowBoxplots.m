function ShowBoxplots(LabResults, cond)
    
    XPos = 1.15;
    YFactor_Pval = 0.75;
    YFactor_mu1 = 0.70;
    YFactor_mu2 = 0.65;
    
    cond1IDs = find(arrayfun(@(x) strcmp(x.Condition, cond{1}), LabResults));
    cond2IDs = find(arrayfun(@(x) strcmp(x.Condition, cond{2}), LabResults));
    
    % Fission/Fusion boxplots
    Fission_Cond1 = reshape([LabResults(cond1IDs).TotalFission], [], 1);
    Fission_Cond2 = reshape([LabResults(cond2IDs).TotalFission], [], 1);
    if ~any([isempty(Fission_Cond1), isempty(Fission_Cond2)]);
        fFis = figure('Visible', 'off');
        boxplot([[Fission_Cond1], [Fission_Cond2]], 'notch', 'on', ...
            'Labels', cond); 
        title('Normalized Fission Events Per Frame');
        [mu1, mu2, pFis] = GetStats(Fission_Cond1, Fission_Cond2);
        text(XPos, YFactor_Pval*max(ylim), ['Rank Sum p-value: ' sprintf('%f', pFis)]);
        text(XPos, YFactor_mu1*max(ylim), ['Mean ' cond{1} ': ' sprintf('%f', mu1)]);
        text(XPos, YFactor_mu2*max(ylim), ['Mean ' cond{2} ': ' sprintf('%f', mu2)]);
        fFis.Visible = 'on';
    end
    
    Fusion_Cond1 = reshape([LabResults(cond1IDs).TotalFusion], [], 1);
    Fusion_Cond2 = reshape([LabResults(cond2IDs).TotalFusion], [], 1);
    if ~any([isempty(Fusion_Cond1), isempty(Fusion_Cond2)])
        fFus = figure('Visible', 'off');
        boxplot([[Fusion_Cond1], [Fusion_Cond2]], 'notch', 'on', ...
            'Labels', cond); 
        title('Normalized Fusion Events Per Frame');
        [mu1, mu2, pFus] = GetStats(Fusion_Cond1, Fusion_Cond2);
        text(XPos, YFactor_Pval*max(ylim), ['Rank Sum p-value: ' sprintf('%f', pFus)]);
        text(XPos, YFactor_mu1*max(ylim), ['Mean ' cond{1} ': ' sprintf('%f', mu1)]);
        text(XPos, YFactor_mu2*max(ylim), ['Mean ' cond{2} ': ' sprintf('%f', mu2)]);
        fFus.Visible = 'on';
    end
    
    Fission_Cond1 = reshape([LabResults(cond1IDs).NormalizedFission], [], 1);
    Fission_Cond2 = reshape([LabResults(cond2IDs).NormalizedFission], [], 1);
    if ~any([isempty(Fission_Cond1), isempty(Fission_Cond2)]);
        fNormFis = figure('Visible', 'off');
        boxplot([[Fission_Cond1], [Fission_Cond2]], 'notch', 'on', ...
            'Labels', cond); 
        title('Normalized Fission Events Per Frame');
        [mu1, mu2, pNormFis] = GetStats(Fission_Cond1, Fission_Cond2);
        text(XPos, YFactor_Pval*max(ylim), ['Rank Sum p-value: ' sprintf('%f', pNormFis)]);
        text(XPos, YFactor_mu1*max(ylim), ['Mean ' cond{1} ': ' sprintf('%f', mu1)]);
        text(XPos, YFactor_mu2*max(ylim), ['Mean ' cond{2} ': ' sprintf('%f', mu2)]);
        fNormFis.Visible = 'on';
    end

    Fusion_Cond1 = reshape([LabResults(cond1IDs).NormalizedFusion], [], 1);
    Fusion_Cond2 = reshape([LabResults(cond2IDs).NormalizedFusion], [], 1);
    if ~any([isempty(Fusion_Cond1), isempty(Fusion_Cond2)])
        fNormFus = figure('Visible', 'off');
        boxplot([[Fusion_Cond1], [Fusion_Cond2]], 'notch', 'on', ...
            'Labels', cond); 
        title('Normalized Fusion Events Per Frame');
        [mu1, mu2, pNormFus] = GetStats(Fusion_Cond1, Fusion_Cond2);
        text(XPos, YFactor_Pval*max(ylim), ['Rank Sum p-value: ' sprintf('%f', pNormFus)]);
        text(XPos, YFactor_mu1*max(ylim), ['Mean ' cond{1} ': ' sprintf('%f', mu1)]);
        text(XPos, YFactor_mu2*max(ylim), ['Mean ' cond{2} ': ' sprintf('%f', mu2)]);
        fNormFus.Visible = 'on';
    end
    
    % Velocity boxplots
    Velocity_Cond1 = reshape([LabResults(cond1IDs).AverageVelocity], [], 1);
    Velocity_Cond2 = reshape([LabResults(cond2IDs).AverageVelocity], [], 1);
    if ~any([isempty(Velocity_Cond1), isempty(Velocity_Cond2)])
        fVel = figure('Visible', 'off');
        boxplot([[Velocity_Cond1], [Velocity_Cond2]], 'notch', 'on', ...
            'Labels', cond); 
        title('Velocity Per Frame');
        [mu1, mu2, pVel] = GetStats(Velocity_Cond1, Velocity_Cond2);
        text(XPos, YFactor_Pval*max(ylim), ['Rank Sum p-value: ' sprintf('%f', pVel)]);
        text(XPos, YFactor_mu1*max(ylim), ['Mean ' cond{1} ': ' sprintf('%f', mu1)]);
        text(XPos, YFactor_mu2*max(ylim), ['Mean ' cond{2} ': ' sprintf('%f', mu2)]);
        fVel.Visible = 'on';
    end
    
    Velocity_Cond1 = reshape([LabResults(cond1IDs).MedianVelocity], [], 1);
    Velocity_Cond2 = reshape([LabResults(cond2IDs).MedianVelocity], [], 1);
    if ~any([isempty(Velocity_Cond1), isempty(Velocity_Cond2)])
        fVel = figure('Visible', 'off');
        boxplot([[Velocity_Cond1], [Velocity_Cond2]], 'notch', 'on', ...
            'Labels', cond); 
        title('Median Velocity Per Frame');
        [mu1, mu2, pVel] = GetStats(Velocity_Cond1, Velocity_Cond2);
        text(XPos, YFactor_Pval*max(ylim), ['Rank Sum p-value: ' sprintf('%f', pVel)]);
        text(XPos, YFactor_mu1*max(ylim), ['Mean ' cond{1} ': ' sprintf('%f', mu1)]);
        text(XPos, YFactor_mu2*max(ylim), ['Mean ' cond{2} ': ' sprintf('%f', mu2)]);
        fVel.Visible = 'on';
    end
    
    % Spatial boxplots
    Spatial_Cond1 = reshape([LabResults(cond1IDs).Spatial], [], 1);
    Spatial_Cond2 = reshape([LabResults(cond2IDs).Spatial], [], 1);
    if ~any([isempty(Spatial_Cond1), isempty(Spatial_Cond2)])
        fSpatial = figure('Visible', 'off');
        boxplot([[Spatial_Cond1], [Spatial_Cond2]], 'notch', 'on', ...
            'Labels', cond); 
        title('Spatiotemporal Distribution Per Frame');
        [mu1, mu2, pSpatial] = GetStats(Spatial_Cond1, Spatial_Cond2);
        text(XPos, YFactor_Pval*max(ylim), ['Rank Sum p-value: ' sprintf('%f', pSpatial)]);
        text(XPos, YFactor_mu1*max(ylim), ['Mean ' cond{1} ': ' sprintf('%f', mu1)]);
        text(XPos, YFactor_mu2*max(ylim), ['Mean ' cond{2} ': ' sprintf('%f', mu2)]);
        fSpatial.Visible = 'on';
    end
    
end

function [mu1, mu2, pRankSum] = GetStats(G1, G2)
    mu1 = mean(G1);
    mu2 = mean(G2);
    pRankSum = ranksum(G1, G2);
end