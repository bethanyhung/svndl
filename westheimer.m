%%  NOTE
%   This version of the Westheimer analysis script is compatible with the
%   following paradigms: whmSuperSet, whmHexCancellation, &
%   whmCancellation2Sz. whmMixed and whmHexFreq have been moved to a
%   separate script.

%% ADD CODE BASES TO PATH
addpath(genpath('~/code/git/rcaBase'));
addpath(genpath('~/code/git/mrC'));
addpath(genpath('~/code/git/sweepAnalysis'));
addpath(genpath('~/code/git/svndl'));

%% SET UP: DEFINE VARIABLES & LOAD DATA
clear all
close all

paradigm = 'pilot5'; % 'whmSuperSet' | 'whmHexCancellation' | 'whmCancellation2Sz'
stimFrq = [3]; % 3 for whmHexCancellation, whmCancellation2Sz | [30/11,3,3.75] for whmSuperSet
nPol = 2;
parentDir = '/Users/babylab/Desktop/whm';
[dataFolder,dataSet,names,RCAfolder] = getInfo(parentDir,paradigm);

tic
for s = 1:length(dataSet)
    fprintf('Running subject %s\n', names{s});
    curDataFolder = sprintf('%s/%s', dataFolder,dataSet{s});   
    [data{s},avgedData{s}, nCnd] = loadData(curDataFolder,stimFrq); % data: nChan x nTimept x nTri x nCnd
end
toc

%% SORTING DATA FOR RCA
% FORMAT: cell array {cnd x subj}(samples x channels x trials)

for a = 1:length(dataSet)
    for c = 1:nCnd
        RCA{c,a} = squeeze(data{a}{c});
    end
end

switch paradigm    
    case 'whmSuperSet'
        % EFFECT OF FREQ: POOLING OVER ECC + POL
        frq1 = RCA([1:2,7:8,13:14,19:20,25:26,31:32],:);
        frq2 = RCA([1:2,7:8,13:14,19:20,25:26,31:32]+2,:);
        frq3 = RCA([1:2,7:8,13:14,19:20,25:26,31:32]+4,:);
        % EFFECT OF ECCENTRICITY: POOLING OVER TF + POL
        SF = RCA([1:6],:);
        SP1 = RCA([1:6]+6,:);
        SP2 = RCA([1:6]+12,:);
        IF = RCA([1:6]+18,:);
        IP1 = RCA([1:6]+24,:);
        IP2 = RCA([1:6]+30,:);        
    case 'whmHexCancellation'
        RCA_UR = RCA([1 5 9 13],:); 
        RCA_UL = RCA([1 5 9 13]+1,:);
        RCA_LL = RCA([1 5 9 13]+2,:);
        RCA_LR = RCA([1 5 9 13]+3,:);
        RCA_F = RCA([1:4],:);
        RCA_P1 = RCA([1:4]+1,:);
        RCA_P2 = RCA([1:4]+2,:);       
    case 'whmCancellation2Sz'
        all20 = RCA([1,3,5,7,9,11,13:16],:);
        all14 = RCA([2,4,6,8,10,12,17:20],:);
end

%% RUN RCA
time = 1000/3; % [1000/(30/11),1000/3,1000/3.75] 
timeCourseLen = repmat(time,[1,7]); 
cnds = {RCA_UR RCA_UL RCA_LL RCA_LR RCA_F RCA_P1 RCA_P2}; % {allUL allLL allF allP1 allP2} | {frq1 frq2 frq3}
cndNames = {'UR' 'UL' 'LL' 'LR' 'F' 'P1' 'P2'}; % {'allUL' 'allLL' 'allF' 'allP1' 'allP2'} | {'frq1' 'frq2' 'frq3'}
tic
for i = 1:length(cnds)
    [rcaDataALL, W, A] = rcaRunProject(cnds{i}, RCAfolder, timeCourseLen(i), cndNames{i}, nPol);
%     [rcaDataALL, W, A] = rcaRunProject(RCA(9:10,:), RCAfolder, 1000/3, 'cnd9v10', nPol);
end
toc

%% AVERAGED TIMECOURSE PLOTS / INCOMPLETE

chanROI = 71:76;
cndROI = [1];
subj = '0011'; % '*AY' | '1368' | '1369' | 'avg'
yLim = [-600 300];
plotTimecourse(reshapeByFrq{1}{4,1},subj,yLim,chanROI,cndROI,cndLabels,names,parentDir)
% [nChan x nCnd x nTimept x nSubj]

%% CODE CHECK: RAW TIMECOURSE PLOTS
cnd = 'UR,F';
numTimept = size(avgedData{2}{1},1);
yLim = [-300 300];
gcaOpts = {'XTick',linspace(0,numTimept,5),'XTickLabel',{'0','83.33','166.67','250','333.33'},...
    'XLim',[0 numTimept],'YLim',yLim,'box','off','tickdir','out',...
    'fontname','Helvetica','linewidth',1.5,'fontsize',10};

for i = 1:128
    subplot(16,8,i)
    hold on
    plot([1:numTimept],zeros(1,numTimept),'color','k')
    plot(squeeze(avgedData{2}{1}(:,i)),'color','b')  
    title(sprintf('%s, Ch. %d',cnd,i))
    set(gca,gcaOpts{:})
end