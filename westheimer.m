%% ADD CODE BASES TO PATH
addpath(genpath('~/code/git/rcaBase'));
addpath(genpath('~/code/git/mrC'));
addpath(genpath('~/code/git/sweepAnalysis'));

%% SET UP: DEFINE VARIABLES & LOAD DATA
clear all
close all

paradigm = 'pilot5'; % 'whmMixed' | 'whmHexFreq' | 'whmSuperSet' | 'whmHexCancellation'
stimFrq = 3; % 3 for whmMixed, whmHexCancellation | [3.75,30/11,3] for whmHexFreq | [30/11,3,3.75] for whmSuperSet
folder = '/Users/babylab/Desktop/whm';
RCAfolder = sprintf('%s/RCA_pilot5',folder);
[dataFolder,dataSet,names] = getInfo(folder,paradigm);

tic
for s = 1:length(dataSet)
    fprintf('Running subject %s\n', names{s});
    curDataFolder = sprintf('%s/%s', dataFolder,dataSet{s});   
%     if length(stimFrq) == 1
%         [fullData(:,:,:,:,s), fnlData(:,:,:,s), nCnd] = loadData(curDataFolder,stimFrq);   
%     else
        [fullData{s},fnlData{s}, nCnd] = loadData(curDataFolder,stimFrq); % orig rearrByCnd: chan x timept x cnd x tri
%     end
end
toc
%% SORTING DATA FOR RCA
% (samples x channels x trials), or a cell array (conditions x subjects)
if length(stimFrq) == 1
%     rearrData = permute(fullData,[2 1 4 3 5]);
%     for a = 1:length(dataSet)
%         for c = 1:nCnd
%             RCA{c,a} = squeeze(rearrData(:,:,:,c,a));
%         end
%     end
%     if strcmp(paradigm,'whmHexCancellation')
%         allUR = RCA([1 5 9 13],:);
%         allUL = RCA([1 5 9 13]+1,:);
%         allLL = RCA([1 5 9 13]+2,:);
%         allLR = RCA([1 5 9 13]+3,:);
%         allF = RCA([1:4],:);
%         allP1 = RCA([1:4]+1,:);
%         allP2 = RCA([1:4]+2,:);
%     end
    
    for a = 1:length(dataSet)
        for c = 1:nCnd
            RCA{c,a} = squeeze(fullData{a}(:,:,:,c));
        end
    end
    
elseif strcmp(paradigm,'whmHexFreq')
    for s = 1:length(dataSet)
        freq1(:,:,:,:,s) = permute(fullData{s}{1},[2 1 3 4]); % timecourse x chan x tri x cnd x subj, extracted from cell
        freq2(:,:,:,:,s) = permute(fullData{s}{2},[2 1 3 4]);
        freq3(:,:,:,:,s) = permute(fullData{s}{3},[2 1 3 4]);       
    end
    for a = 1:length(dataSet)
        for c = 1:size(freq1,4)
            RCA_frq1{c,a} = squeeze(freq1(:,:,:,c,a)); % cell array with all 6 cnd of one freq
        end
        for c = 1:size(freq2,4)
            RCA_frq2{c,a} = squeeze(freq2(:,:,:,c,a));
        end
        for c = 1:size(freq3,4)
            RCA_frq3{c,a} = squeeze(freq3(:,:,:,c,a));
        end
    end
elseif strcmp(paradigm,'whmSuperSet')
    % EFFECT OF FREQ: POOLING OVER ECC + POL
    for s = 1:length(dataSet)
        for c = 1:length(fullData{s})
            fullData{s}{c} = permute(fullData{s}{c},[2 1 4 3]); % timept x chan x cnd x tri
        end
        reshapeByFrq{s} = reshape(fullData{s},length(stimFrq),[])';
    end
    for s = 1:length(dataSet)
        for c = 1:size(reshapeByFrq{s},1)
            cIdx = c*2-1;
            for p = 1:2                
                RCA_frq1{cIdx,s} = squeeze(reshapeByFrq{s}{c,1}(:,:,p,:)); 
                RCA_frq2{cIdx,s} = squeeze(reshapeByFrq{s}{c,2}(:,:,p,:));
                RCA_frq3{cIdx,s} = squeeze(reshapeByFrq{s}{c,3}(:,:,p,:));
                cIdx = cIdx + 1;
            end
        end
    end
    % EFFECT OF ECCENTRICITY: POOLING OVER TF + POL
    for s = 1:length(dataSet)
        reshapeByEcc{s} = reshape(fullData{s},[],6);
    end
    for s = 1:length(dataSet)
        for c = 1:size(reshapeByEcc{s},1)
            cIdx = c*2-1;
            for p = 1:2
                RCA_SF{cIdx,s} = squeeze(reshapeByEcc{s}{c,1}(:,:,p,:)); % broken here
                RCA_SP1{cIdx,s} = squeeze(reshapeByEcc{s}{c,2}(:,:,p,:));
                RCA_SP2{cIdx,s} = squeeze(reshapeByEcc{s}{c,3}(:,:,p,:));
                RCA_IF{cIdx,s} = squeeze(reshapeByEcc{s}{c,4}(:,:,p,:));
                RCA_IP1{cIdx,s} = squeeze(reshapeByEcc{s}{c,5}(:,:,p,:));
                RCA_IP2{cIdx,s} = squeeze(reshapeByEcc{s}{c,6}(:,:,p,:));
                cIdx = cIdx + 1;
            end
        end
    end
end

%% ALEXANDRA'S RCA CODE
% calculate error bars over # samples/epochs
subjToInclude = [1:6]; % pick from 'names' vector
timeCourseLen = 1/(3); %1/3.75; % 3 Hz
% make more folders 
tic
[rcaDataALL, W, A] = rcaRunProject(allUR(1,subjToInclude), RCAfolder, timeCourseLen, 'UR_F'); % RCA_SF(1:2,:) for superset | allP2 for hexCancellation
toc

%% ADAPTING MAX DIFF
cnd = [1,4];
for s = 1:length(names)-1
    data1{s} = squeeze(fullData(:,:,cnd(1),:,s));
    data1{s} = permute(data1{s},[3 1 2]);
    data2{s} = squeeze(fullData(:,:,cnd(2),:,s));
    data2{s} = permute(data2{s},[3 1 2]);
end
dataLabels = {'UR-F' 'LR-F'};
timeCourseLen = 1000/3;
maxDiff(data1, data2, dataLabels, folder, timeCourseLen)

%% MANUAL RCA
for a = 1:size(RCA_SF_2,1)
    for b = 1:size(RCA_SF_2,2)
        avgRCA_SF_2{a,b} = squeeze(nanmean(RCA_SF_2{a,b},3));
        for c = 1:size(avgRCA_SF_2{a,b},1)
            for d = 1:128
                filtered_SF_2{a,b}(c,d) = avgRCA_SF_2{a,b}(c,d)*W(d,1);
            end
        end
        RC1_SF_2{a,b} = squeeze(nanmean(filtered_SF_2{a,b},2));
    end
end

%% whmHexFreq timecourse plots
if strcmp(paradigm,'whmHexFreq')
    for s = 1:length(dataSet)
        frq1(:,:,:,s) = permute(fnlData{s}{1},[1,3,2,4]); % 128 x 6 x 112 x 3
        frq2(:,:,:,s) = permute(fnlData{s}{2},[1,3,2,4]); % 128 x 6 x 154 x 3
        frq3(:,:,:,s) = permute(fnlData{s}{3},[1,3,2,4]); % 128 x 2 x 140 x 3
    end
else
    for s = 1:length(dataSet)
        for c = 1:length(fnlData{s})
            fnlDataP{s}{c} = permute(fnlData{s}{c},[1 3 2]); % chan x cnd x timept
        end
        reshapeByFrq{s} = reshape(fnlDataP{s},length(stimFrq),[])';
    end
end

chanROI = 71:76;
cndROI = [1];
subj = '0011'; % '*AY' | '1368' | '1369' | 'avg'
yLim = [-600 300];
plotTimecourse(reshapeByFrq{1}{4,1},subj,yLim,chanROI,cndROI,cndLabels,names,folder)
% [nChan x nCnd x nTimept x nSubj]
%% PLOTTING EVERY CHANNEL
cnd = 'UL,F';
for i = 1:128
    subplot(16,8,i)
    hold on
    plot(squeeze(nanmean(fnlData(i,2,:,:),4)),'color','b')
    title(sprintf('%s, Ch. %d',cnd,i))
end