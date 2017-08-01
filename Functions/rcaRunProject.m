function [rcaDataALL, W, A] = rcaRunProject(eegSrc, dirResData, timeCourseLen, sector, pol)

    %run RCA on eegSrc_p5
    nReg = 7;
    nComp = 3;
    if (~exist(dirResData, 'dir'))
        mkdir(dirResData);
    end
    
    fileRCA = fullfile(dirResData, sprintf('resultRCA_%s.mat',sector));
    
    % run RCA
    if(~exist(fileRCA, 'file'))
        [rcaDataALL, W, A, ~, ~, ~, ~] = rcaRun(eegSrc, nReg, nComp);
        save(fileRCA, 'rcaDataALL', 'W', 'A');
    else
        load(fileRCA);
    end
    % do the plots
    
    catDataAll = cat(3, rcaDataALL{:});
    muDataAll = nanmean(catDataAll, 3);
    muDataAll = muDataAll - repmat(muDataAll(1, :), [size(muDataAll, 1) 1]);
    semDataAll = nanstd(catDataAll, [], 3)/(sqrt(size(catDataAll, 3)));
    timeCourse = linspace(0, timeCourseLen, size(muDataAll, 1));
    close all;
    
    %% run the projections            
    for c = 1:nComp
        subplot(nComp, 2, 2*c - 1);
        shadedErrorBar(timeCourse, muDataAll(:, c), semDataAll(:, c));hold on;
        title(['RC' num2str(c) ' time course']);
        subplot(nComp, 2, 2*c);
        plotOnEgi(A(:,c)); hold on;
    end
    saveas(gcf, fullfile(dirResData, sprintf('rcaComponentsAll_%s',sector)), 'fig');
    close(gcf);
    
    %% Project increment/decrement
    if pol ~= 1
    projectRC(eegSrc, -W, -A, nComp, {'Inc', 'Dec'}, timeCourseLen, dirResData,sector);
    else
    end
end