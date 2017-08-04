function [data, avgedData, nCnd] = loadData(curDataFolder,stimFrq)
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

possibleLen = sampRate./stimFrq;

for c = 1:nCnd
    numEpochs = size(isEpochOK{c},1);
    rearrByEpoch = reshape(raw_cut{c},[],numEpochs,128,nTri); % nTimept x nEpoch x nChan x nTri
    isEpochOKLog = logical(isEpochOK{c});
    rearrByEpoch(:,~isEpochOKLog) = NaN;   
    for i = 1:length(possibleLen) % only works if freq are not multiples of each other
        if floor(size(rearrByEpoch,1)/possibleLen(i)) ~= size(rearrByEpoch,1)/possibleLen(i)        
        else
            len = possibleLen(i);
            break
        end
    end
    rearrByCyc = reshape(rearrByEpoch,len,[],numEpochs,128,nTri); % nTimept x nCyc x nEpoch x nChan x nTri
    rearr = permute(rearrByCyc,[2 3 5 4 1]); % nCyc x nEpoch x nTri x nChn x nTimept
    rearrBySamp = reshape(rearr,[],128,size(rearrByCyc,1));
    data{c} = permute(rearrBySamp,[3 2 1]);
    avgedData{c} = squeeze(nanmean(data{c},3)); % avged over trials
end

% TEST PLOTS
% check: rearrByEpoch
% figure; hold on;
% plot(squeeze(raw_cut{1}(:,1,1)))
% plot(squeeze(rearrByEpoch(:,1,1,1)))
% x = [421:840];
% plot(x,squeeze(rearrByEpoch(:,2,1,1)))
% 
% % check rearrByEpoch after filtering
% % for nl0040, epochs1-10 chan 3 tri 1 has bad epochs
% c=3; t=1;
% figure
% for i = 1:10
%     subplot(5,2,i)
%     plot(squeeze(rearrByEpoch(:,i,c,t)))
%     title(i)
% end % should be NaNs for i = 1 2 3 8
% 
% % check rearrByCyc
% figure; hold on;
% plot(squeeze(rearrByEpoch(:,1,1,1)))
% plot(squeeze(rearrByCyc(:,1,1,1,1)))
% x = [141:140*2];
% plot(x,squeeze(rearrByCyc(:,2,1,1,1)))
% 
% % CHECKING rearrBySamp (1,2) + baselining (3)
%     c=3;e=7;t=1;
%     figure
%     plot(squeeze(rearr(c,e,t,1,:))) % 1
%     hold on
%     plot(squeeze(rearrBySamp(c+3*(e-1)+30*(t-1),1,:))) % 2
%     plot(squeeze(baselined(c+3*(e-1)+30*(t-1),1,:))) % 3