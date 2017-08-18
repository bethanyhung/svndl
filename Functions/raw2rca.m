function [RCA,RCAfolder] = raw2rca(parentDir,paradigm,stimFrq,newSubj)

[dataFolder,dataSet,names,RCAfolder] = getInfo(parentDir,paradigm);
fileRCAData = fullfile(RCAfolder, sprintf('processedData_%s.mat',paradigm));
    
if ~exist(fileRCAData, 'file') || newSubj
    tic
    for s = 1:length(dataSet)
        fprintf('Running subject %s\n', names{s});
        curDataFolder = sprintf('%s/%s', dataFolder,dataSet{s});   
        [data{s},~, nCnd] = loadData(curDataFolder,stimFrq); % data: nChan x nTimept x nTri x nCnd
        for c = 1:nCnd
            RCA{c,s} = squeeze(data{s}{c}); % FORMAT: cell array {cnd x subj}(samples x channels x trials)
        end
    end
    toc
    tic
    save(fileRCAData, 'RCA', '-v7.3');
    toc
    fprintf('New file saved.\n');

else
    tic
    RCA = load(fileRCAData);
    RCA = RCA.RCA;
    fprintf('File loaded.\n');
    toc

end

end