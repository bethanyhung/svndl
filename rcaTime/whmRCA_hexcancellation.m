%% ADD CODE BASES TO PATH
addpath(genpath('~/code/git/rcaBase'));
addpath(genpath('~/code/git/mrC'));
addpath(genpath('~/code/git/sweepAnalysis'));
addpath(genpath('~/code/git/svndl2017'));

%% SET UP: DEFINE VARIABLES & LOAD DATA
clear all
close all

parentDir = '/Users/babylab/Desktop/whm';
paradigm = 'whmHexCancellation';
stimFrq = 3;
nPol = 1;
newSubj = 0;

[RCA,RCAfolder] = raw2rca(parentDir,paradigm,stimFrq,newSubj);

%% PERFORM RCA        
timeCourseLen = round(1000./stimFrq);
tic
[rcaDataALL15913, ~, ~] = rcaRunProject(RCA([1 5 9 13],:), RCAfolder, timeCourseLen, 'UR', nPol);
[rcaDataALL261014, ~, ~] = rcaRunProject(RCA([2 6 10 14],:), RCAfolder, timeCourseLen, 'UL', nPol);
[rcaDataALL371115, ~, ~] = rcaRunProject(RCA([3 7 11 15],:), RCAfolder, timeCourseLen, 'LL', nPol);
[rcaDataALL481216, ~, ~] = rcaRunProject(RCA([4 8 12 16],:), RCAfolder, timeCourseLen, 'LR', nPol);
[rcaDataALL1234, ~, ~] = rcaRunProject(RCA([1:4],:), RCAfolder, timeCourseLen, 'F', nPol);
[rcaDataALL5678, ~, ~] = rcaRunProject(RCA([5:8],:), RCAfolder, timeCourseLen, 'P1', nPol);
[rcaDataALL9101112, ~, ~] = rcaRunProject(RCA([9:12],:), RCAfolder, timeCourseLen, 'P2', nPol);
toc

%% GENERATE PLOTS
tc = linspace(0, timeCourseLen, size(rcaDataALL15913{1,1}, 1));

[mu15913, s15913] = prepData(rcaDataALL15913);
[mu261014, s261014] = prepData(rcaDataALL261014);
[mu371115, s371115] = prepData(rcaDataALL371115);
[mu481216, s481216] = prepData(rcaDataALL481216);
[mu1234, s1234] = prepData(rcaDataALL1234);
[mu5678, s5678] = prepData(rcaDataALL5678);
[mu9101112, s9101112] = prepData(rcaDataALL9101112);

group_upper_mu = [mu15913(:, 1) mu261014(:, 1)]; % each grp should have all 3 polarities
group_lower_mu = [mu1920(:, 1) mu2526(:, 1) mu3132(:, 1)];   
group_upper_s = [s15913(:, 1) s261014(:, 1) s1314(:, 1)];
group_lower_s = [s1920(:, 1) s2526(:, 1) s3132(:, 1)];

[h1, h2] = subplotMultipleComponents(tc, {group_upper_27_mu, group_upper_27_s}, ... % each group = 1 cnd
        {group_lower_27_mu, group_lower_27_s}, {'Lower 2.73 Hz', 'Upper 2.73Hz'});
    saveas(h1, fullfile(RCAfolder, 'Group  2.73 Hz _byGroup.fig'));
    saveas(h2, fullfile(RCAfolder, 'Group  2.73 Hz _byRegion.fig'));
    
[h3, h4] = subplotMultipleComponents(tc, {group_upper_3_mu, group_upper_3_s}, ... % each group = 1 cnd
    {group_lower_3_mu, group_lower_3_s}, {'Lower 3 Hz', 'Upper 3 Hz'});
    saveas(h3, fullfile(RCAfolder, 'Group  3 Hz _byGroup.fig'));
    saveas(h4, fullfile(RCAfolder, 'Group  3 Hz _byRegion.fig'));