function [fnlRearrByCnd, fnlData, nCnd] = loadDataHexFreq(curDataFolder,stimFrq)
% Takes in data directories and stimulus info and outputs formatted,
% filtered data.
%
% INPUTS
%   curDataFolder:  String. Directory of subject-specific data.
%   stimFrq:        Double. Stimulus frequency.
%
% OUTPUTS
%   rearrByCnd:     Double array, [nChan x nTrials x nCond x nTimepts].
%                   Timecourse data sorted into conditions.
%   fnlData:        Double array, [nChan x nCond x nTimepts]. rearrByCnd,
%                   averaged over trials.
%   nCnd:           Double. Number of conditions.

% EXTRACTING RAW DATA AND EPOCH REJECTION FILTER

nFrq = length(stimFrq); % # of unique frq values
frqIdx = 1;
dataFiles = mySubFiles(curDataFolder,'Raw',1);
RTsegPath = sprintf('%s/RTSeg_s002.mat',curDataFolder);
if exist(RTsegPath, 'file') == 2
    RTseg = load(RTsegPath);
else
    RTseg = load(sprintf('%s/RTSeg_s001.mat',curDataFolder));
end
nCnd = length(RTseg.CndTiming);
nTri = length(dataFiles)/nCnd;

for c = 1:nCnd
    stepDur(c) = RTseg.CndTiming(c).stepDurSec;
end
nCndPerFrq = 1;
for s = 1:length(stepDur)
    if stepDur(s) == stepDur(s+1)
        nCndPerFrq = nCndPerFrq + 1;
    else
        break
    end
end
nTxC = nCndPerFrq*nTri;

for t=1:length(dataFiles)
    filePath_complete = sprintf('%s/%s',curDataFolder,dataFiles{t});
    cnd = str2double(filePath_complete(end-10:end-9)); 
    pre = RTseg.CndTiming(cnd).preludeDurSec;
    post = RTseg.CndTiming(cnd).postludeDurSec;
    epochLength(t) = RTseg.CndTiming(cnd).stepDurSec(1);
    allData = load(filePath_complete);
    sampRate = allData.FreqHz;    
    nPre = pre/epochLength(t);
    nPost = post/epochLength(t);    
    if t == 1 || epochLength(t) == epochLength(t-1) % continue if same freq
        raw_cutTemp(:,:,t-nTxC*(frqIdx-1)) = double(allData.RawTrial(round(sampRate*pre+1):end-round(sampRate*post),1:128));     
        isEpochOKTemp(:,:,t-nTxC*(frqIdx-1)) = allData.IsEpochOK(1+nPre:end-nPost,:);
        if t == length(dataFiles)
            raw_cut{frqIdx} = raw_cutTemp;
            isEpochOK{frqIdx} = isEpochOKTemp;
        end
    elseif epochLength(t) ~= epochLength(t-1) 
        raw_cut{frqIdx} = raw_cutTemp;
        isEpochOK{frqIdx} = isEpochOKTemp;
        clear raw_cutTemp
        clear isEpochOKTemp
        frqIdx = frqIdx + 1;  
        raw_cutTemp(:,:,t-nTxC*(frqIdx-1)) = double(allData.RawTrial(round(sampRate*pre+1):end-round(sampRate*post),1:128));
        isEpochOKTemp(:,:,t-nTxC*(frqIdx-1)) = allData.IsEpochOK(1+nPre:end-nPost,:);           
    end
end

% REARRANGING & FILTERING OUT BAD DATA 
cIdx = repmat([1:nFrq],[1,length(raw_cut)/nFrq]);
for c = 1:length(raw_cut)
    numTr = size(raw_cut{c},3);
    numEpochs = size(isEpochOK{c},1);
    rearrByEpoch = reshape(raw_cut{c},[],numEpochs,128,numTr); % nTimept x nEpoch x nChan x nTri*nCnd
    isEpochOKLog = logical(isEpochOK{c});
    rearrByEpoch(:,~isEpochOKLog) = NaN;
    rearrByCyc = reshape(rearrByEpoch,sampRate/stimFrq(cIdx(c)),[],numEpochs,128, numTr); 
    rearr = permute(rearrByCyc,[2 3 5 4 1]); % nCyc x nEpoch x nTxC x nChn x nTimept
    rearrBySamp = reshape(rearr,size(rearr,1)*numEpochs*numTr,128,[]); % nEpoch*nTxC x nChan x nTimept / MAKE SURE THIS IS CORRECT 

    % BASELINING
    firstVal = rearrBySamp(:,:,1);
    for i = 1:size(rearrBySamp,3)
        baselined(:,:,i) = rearrBySamp(:,:,i) - firstVal;
    end

    rearrByCnd = reshape(baselined,[],2,128,size(baselined,3)); 
%         rearrByCnd = reshape(baselined,[],nTri,128,size(baselined,3)); 
    permuted = permute(rearrByCnd,[4 3 1 2]);
    fnlRearrByCnd{c*2-1} = permuted(:,:,:,1); % samples x chan x tri x cnd
    fnlRearrByCnd{c*2} = permuted(:,:,:,2); % samples x chan x tri x cnd
    fnlData{c} = squeeze(nanmean(fnlRearrByCnd{c},3)); % avged over trials
    clear baselined
end