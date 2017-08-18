function [avgedData, nCnd] = loadDataBins(curDataFolder,stimFrq)
% Takes in data directories and stimulus info and outputs formatted,
% filtered data.
%
% INPUTS
%   curDataFolder:  String. Directory of subject-specific data.
%   stimFrq:        Double. Stimulus frequency.
%
% OUTPUTS
%   data:           Cell array, {1 x nCnd}(nChan x nTrials x nTimepts).
%                   Timecourse data sorted into conditions.
%   avgedData:      Cell array, {1 x nCnd}(nChan x nTimepts).
%                   Timecourse data averaged over trials.
%   nCnd:           Double. Number of conditions.
%
% Bethany H., 2017

% EXTRACTING RAW DATA AND EPOCH REJECTION FILTER
nFrq = length(stimFrq); % # of unique frq values
cndIdx = 1;  
dataFiles = mySubFiles(curDataFolder,'Raw',1);
RTsegPath = sprintf('%s/RTSeg_s002.mat',curDataFolder);
if exist(RTsegPath, 'file') == 2
    RTseg = load(RTsegPath);
else
    RTseg = load(sprintf('%s/RTSeg_s001.mat',curDataFolder));
end
nCnd = length(RTseg.CndTiming);
nTri = length(dataFiles)/nCnd;

for t = 1:length(dataFiles)
    filePath_complete = sprintf('%s/%s',curDataFolder,dataFiles{t});
    cnd(t) = str2double(filePath_complete(end-10:end-9)); 
    pre = RTseg.CndTiming(cnd(t)).preludeDurSec;
    post = RTseg.CndTiming(cnd(t)).postludeDurSec;
    epochLength(t) = RTseg.CndTiming(cnd(t)).stepDurSec;
    allData = load(filePath_complete);
    sampRate = allData.FreqHz;    
    nPre = pre/epochLength(t);
    nPost = post/epochLength(t);
    if cnd(t) == 1 || cnd(t) == cnd(t-1)
        raw_cutTemp(:,:,t-nTri*(cndIdx-1)) = double(allData.RawTrial(round(sampRate*pre+1):end-round(sampRate*post),1:128)); % removing pre/postludes
        isEpochOKTemp(:,:,t-nTri*(cndIdx-1)) = allData.IsEpochOK(1+nPre:end-nPost,:);
        if t == length(dataFiles)
            raw_cut{cndIdx} = raw_cutTemp;
            isEpochOK{cndIdx} = isEpochOKTemp;
        end
    elseif cnd(t) ~= cnd(t-1)
        raw_cut{cndIdx} = raw_cutTemp;
        isEpochOK{cndIdx} = isEpochOKTemp;
        clear raw_cutTemp
        clear isEpochOKTemp 
        cndIdx = cndIdx + 1;
        raw_cutTemp(:,:,t-nTri*(cndIdx-1)) = double(allData.RawTrial(round(sampRate*pre+1):end-round(sampRate*post),1:128));
        isEpochOKTemp(:,:,t-nTri*(cndIdx-1)) = allData.IsEpochOK(1+nPre:end-nPost,:);
    end
end

% REARRANGING & FILTERING OUT BAD DATA 

for c = 1:nCnd
    numEpochs = size(isEpochOK{c},1);
    rearrByEpoch = reshape(raw_cut{c},[],numEpochs,128,nTri); % nTimept x nEpoch x nChan x nTri
    isEpochOKLog = logical(isEpochOK{c});
    rearrByEpoch(:,~isEpochOKLog) = NaN;   
    meanOverBin = squeeze(nanmean(rearrByEpoch,2));
    meanOverTri = squeeze(nanmean(meanOverBin,3));
    avgedData{c} = meanOverTri; % avged over trials
end