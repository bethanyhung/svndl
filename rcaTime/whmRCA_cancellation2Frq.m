%% ADD CODE BASES TO PATH
addpath(genpath('~/code/git/rcaBase'));
addpath(genpath('~/code/git/mrC'));
addpath(genpath('~/code/git/sweepAnalysis'));
addpath(genpath('~/code/git/svndl2017'));

%% SET UP: DEFINE VARIABLES & LOAD DATA
clear all
close all

parentDir = '/Users/babylab/Desktop/whm';
paradigm = 'whmCancellation2Frq';
stimFrq = [30/11,3];
nPol = 1;
newSubj = 1;

[RCA,RCAfolder] = raw2rca(parentDir,paradigm,stimFrq,newSubj);

%% PERFORM RCA        
timeCourseLen = round(1000./stimFrq);
tic
[rcaDataALL13, ~, ~] = rcaRunProject(RCA([1 3],:), RCAfolder, timeCourseLen(1), '1n3', nPol);
[rcaDataALL24, ~, ~] = rcaRunProject(RCA([2 4],:), RCAfolder, timeCourseLen(2), '2n4', nPol);
[rcaDataALL57, ~, ~] = rcaRunProject(RCA([5 7],:), RCAfolder, timeCourseLen(1), '5n7', nPol);
[rcaDataALL68, ~, ~] = rcaRunProject(RCA([6 8],:), RCAfolder, timeCourseLen(2), '6n8', nPol);
[rcaDataALL911, ~, ~] = rcaRunProject(RCA([9 11],:), RCAfolder, timeCourseLen(1), '9n11', nPol);
[rcaDataALL1012, ~, ~] = rcaRunProject(RCA([10 12],:), RCAfolder, timeCourseLen(2), '10n12', nPol);
[rcaDataALL1314, ~, ~] = rcaRunProject(RCA([13 14],:), RCAfolder, timeCourseLen(1), '13n14', nPol);
[rcaDataALL1516, ~, ~] = rcaRunProject(RCA([15 16],:), RCAfolder, timeCourseLen(1), '15n16', nPol);
[rcaDataALL1718, ~, ~] = rcaRunProject(RCA([17 18],:), RCAfolder, timeCourseLen(2), '17n18', nPol);
[rcaDataALL1920, ~, ~] = rcaRunProject(RCA([19 20],:), RCAfolder, timeCourseLen(2), '19n20', nPol);

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
    
group_upper_27_mu = [mu12(:, 1) mu78(:, 1) mu1314(:, 1)];
group_lower_27_mu = [mu1920(:, 1) mu2526(:, 1) mu3132(:, 1)];   
group_upper_27_s = [s12(:, 1) s78(:, 1) s1314(:, 1)];
group_lower_27_s = [s1920(:, 1) s2526(:, 1) s3132(:, 1)];

group_upper_3_mu = [mu34(:, 1) mu910(:, 1) mu1516(:, 1)];
group_lower_3_mu = [mu2122(:, 1) mu2728(:, 1) mu3334(:, 1)];   
group_upper_3_s = [s34(:, 1) s910(:, 1) s1516(:, 1)];
group_lower_3_s = [s2122(:, 1) s2728(:, 1) s3334(:, 1)];

[h1, h2] = subplotMultipleComponents(tc, {group_upper_27_mu, group_upper_27_s}, ... % each group = 1 cnd
        {group_lower_27_mu, group_lower_27_s}, {'Lower 2.73 Hz', 'Upper 2.73Hz'});
    saveas(h1, fullfile(RCAfolder, 'Group  2.73 Hz _byGroup.fig'));
    saveas(h2, fullfile(RCAfolder, 'Group  2.73 Hz _byRegion.fig'));
    
[h3, h4] = subplotMultipleComponents(tc, {group_upper_3_mu, group_upper_3_s}, ... % each group = 1 cnd
    {group_lower_3_mu, group_lower_3_s}, {'Lower 3 Hz', 'Upper 3 Hz'});
    saveas(h3, fullfile(RCAfolder, 'Group  3 Hz _byGroup.fig'));
    saveas(h4, fullfile(RCAfolder, 'Group  3 Hz _byRegion.fig'));