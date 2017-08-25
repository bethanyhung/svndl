%% ADD CODE BASES TO PATH
addpath(genpath('~/code/git/rcaBase'));
addpath(genpath('~/code/git/mrC'));
addpath(genpath('~/code/git/sweepAnalysis'));
addpath(genpath('~/code/git/svndl2017'));

%% SET UP: DEFINE VARIABLES & LOAD DATA
clear all
close all

parentDir = '/Users/babylab/Desktop/whm';
paradigm = 'whmCancellation2Sz';
stimFrq = 3;
nPol = 1;
newSubj = 1;

[RCA,RCAfolder] = raw2rca(parentDir,paradigm,stimFrq,newSubj);

%% PERFORM RCA        
timeCourseLen = round(1000./stimFrq);
tic
[rcaDataALL12, ~, ~] = rcaRunProject(RCA([1 2],:), RCAfolder, timeCourseLen, '1n2', nPol);
[rcaDataALL34, ~, ~] = rcaRunProject(RCA([3 4],:), RCAfolder, timeCourseLen, '3n4', nPol);
[rcaDataALL56, ~, ~] = rcaRunProject(RCA([5 6],:), RCAfolder, timeCourseLen, '5n6', nPol);
[rcaDataALL78, ~, ~] = rcaRunProject(RCA([7 8],:), RCAfolder, timeCourseLen, '7n8', nPol);
[rcaDataALL910, ~, ~] = rcaRunProject(RCA([9 10],:), RCAfolder, timeCourseLen, '9n10', nPol);
[rcaDataALL1112, ~, ~] = rcaRunProject(RCA([11 12],:), RCAfolder, timeCourseLen, '11n12', nPol);
[rcaDataALL1317, ~, ~] = rcaRunProject(RCA([13 17],:), RCAfolder, timeCourseLen, '13n17', nPol);
[rcaDataALL1418, ~, ~] = rcaRunProject(RCA([14 18],:), RCAfolder, timeCourseLen, '14n18', nPol);
[rcaDataALL1519, ~, ~] = rcaRunProject(RCA([15 19],:), RCAfolder, timeCourseLen, '15n19', nPol);
[rcaDataALL1620, ~, ~] = rcaRunProject(RCA([16 20],:), RCAfolder, timeCourseLen, '16n20', nPol);

%% GENERATE PLOTS
tc = linspace(0, timeCourseLen(1), size(rcaDataALL12{1,1}, 1));

[mu12, s12] = prepData(rcaDataALL12);
[mu34, s34] = prepData(rcaDataALL34);
[mu56, s56] = prepData(rcaDataALL56);
[mu78, s78] = prepData(rcaDataALL78);
[mu910, s910] = prepData(rcaDataALL910);
[mu1112, s1112] = prepData(rcaDataALL1112);
[mu1317, s1317] = prepData(rcaDataALL1317);
[mu1418, s1418] = prepData(rcaDataALL1418);
[mu1519, s1519] = prepData(rcaDataALL1519);
[mu1620, s1620] = prepData(rcaDataALL1620);
    
group_upper_mu = [mu12(:, 1) mu56(:, 1) mu910(:, 1)];
group_lower_mu = [mu34(:, 1) mu78(:, 1) mu1112(:, 1)];   
group_upper_s = [s12(:, 1) s56(:, 1) s910(:, 1)];
group_lower_s = [s34(:, 1) s78(:, 1) s1112(:, 1)];

[h1, h2] = subplotMultipleComponents(tc, {group_upper_mu, group_upper_s}, ... % each group = 1 cnd
        {group_lower_mu, group_lower_s}, {'Lower fovea', 'Upper fovea'});
    saveas(h1, fullfile(RCAfolder, 'Group 3 Hz _byGroup.fig'));
    saveas(h2, fullfile(RCAfolder, 'Group 3 Hz _byRegion.fig'));
    
% [h3, h4] = subplotMultipleComponents(tc, {group_upper_3_mu, group_upper_3_s}, ... % each group = 1 cnd
%     {group_lower_3_mu, group_lower_3_s}, {'Lower 3 Hz', 'Upper 3 Hz'});
%     saveas(h3, fullfile(RCAfolder, 'Group  3 Hz _byGroup.fig'));
%     saveas(h4, fullfile(RCAfolder, 'Group  3 Hz _byRegion.fig'));