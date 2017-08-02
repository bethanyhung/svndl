%% ADD CODE BASES TO PATH
addpath(genpath('~/code/git/rcaBase'));
addpath(genpath('~/code/git/mrC'));
addpath(genpath('~/code/git/sweepAnalysis'));
addpath(genpath('~/code/git/svndl'));

%% SET UP: DEFINE VARIABLES & LOAD DATA
clear all
close all

paradigm = 'whmHexFreq';
stimFrq = [3.75,30/11,3];
pol = 2;
folder = '/Users/babylab/Desktop/whm';
[dataFolder,dataSet,names,RCAfolder] = getInfo(folder,paradigm);

tic
for s = 1:length(dataSet)
    fprintf('Running subject %s\n', names{s});
    curDataFolder = sprintf('%s/%s', dataFolder,dataSet{s});   
    [fullData{s},fnlData{s}, nCnd] = loadDataHexFreq(curDataFolder,stimFrq); % fullData: chan x timept x cnd x tri
end
toc
%% SORTING DATA FOR RCA
% (samples x channels x trials), or a cell array (conditions x subjects)

for a = 1:length(dataSet)
    fprintf('Running subj %d\n',a)
    for c = 1:nCnd
        if length(stimFrq) == 1
            RCA{c,a} = squeeze(fullData{a}(:,:,:,c));
        else
            RCA{c,a} = squeeze(fullData{a}{c});
        end
    end
end

switch paradigm    
    case 'whmHexFreq'
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

    case 'whmSuperSet'
        % EFFECT OF FREQ: POOLING OVER ECC + POL
        frq1 = RCA([1:2,7:8,13:14,19:20,25:26,31:32],:);
        frq2 = RCA([1:2,7:8,13:14,19:20,25:26,31:32]+2,:);
        frq3 = RCA([1:2,7:8,13:14,19:20,25:26,31:32]+4,:);

        % EFFECT OF ECCENTRICITY: POOLING OVER TF + POL
        RCA_SF = RCA([1:6],:);
        RCA_SP1 = RCA([1:6]+6,:);
        RCA_SP2 = RCA([1:6]+12,:);
        RCA_IF = RCA([1:6]+18,:);
        RCA_IP1 = RCA([1:6]+24,:);
        RCA_IP2 = RCA([1:6]+30,:);
        
    case 'whmHexCancellation'
        allUR = RCA([1 5 9 13],:); 
        allUL = RCA([1 5 9 13]+1,:);
        allLL = RCA([1 5 9 13]+2,:);
        allLR = RCA([1 5 9 13]+3,:);
        allF = RCA([1:4],:);
        allP1 = RCA([1:4]+1,:);
        allP2 = RCA([1:4]+2,:);
        
    case 'whmCancellation2Sz'
        all20 = RCA([1,3,5,7,9,11,13:16],:);
        all14 = RCA([2,4,6,8,10,12,17:20],:);
end

%% ALEXANDRA'S RCA CODE

timeCourseLen = [1000/3,1000/3]; % [1000/(30/11),1000/3,1000/3.75] 
cnds = {all20 all14}; % {allUL allLL allF allP1 allP2} | {frq1 frq2 frq3}
cndNames = {'all20' 'all14'}; % {'allUL' 'allLL' 'allF' 'allP1' 'allP2'} | {'frq1' 'frq2' 'frq3'}
tic
for i = 1:length(cnds)
[rcaDataALL, W, A] = rcaRunProject(cnds{i}, RCAfolder, timeCourseLen(i), cndNames{i}, pol);
end
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
cnd = 'UR,20,F';
numTimept = size(fnlData{1},1);
yLim = [-200 200];
gcaOpts = {'XTick',linspace(0,numTimept,5),'XTickLabel',{'0','83.33','166.67','250','333.33'},...
    'XLim',[0 numTimept],'YLim',yLim,'box','off','tickdir','out',...
    'fontname','Helvetica','linewidth',1.5,'fontsize',10};

for i = 1:128
    subplot(16,8,i)
    hold on
    plot([1:numTimept],zeros(1,numTimept),'color','k')
    plot(squeeze(fnlData{1}(:,i,1)),'color','b')  
    title(sprintf('%s, Ch. %d',cnd,i))
    set(gca,gcaOpts{:})
end