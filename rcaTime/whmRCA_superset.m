%% ADD CODE BASES TO PATH
addpath(genpath('~/code/git/rcaBase'));
addpath(genpath('~/code/git/mrC'));
addpath(genpath('~/code/git/sweepAnalysis'));
addpath(genpath('~/code/git/svndl2017'));

%% SET UP: DEFINE VARIABLES & LOAD DATA
clear all
close all

parentDir = '/Users/babylab/Desktop/whm';
paradigm = 'whmSuperSet';
stimFrq = [30/11,3,3.75];
nPol = 2;
newSubj = 0;

[RCA,RCAfolder] = raw2rca(parentDir,paradigm,stimFrq,newSubj);

%% PERFORM RCA
timeCourseLen = round(1000./stimFrq);
tic
[rcaDataALL12, ~, ~] = rcaRunProject(RCA([1 2],:), RCAfolder, timeCourseLen(1), '1v2', nPol);
[rcaDataALL34, ~, ~] = rcaRunProject(RCA([3 4],:), RCAfolder, timeCourseLen(2), '3v4', nPol);
[rcaDataALL56, ~, ~] = rcaRunProject(RCA([5 6],:), RCAfolder, timeCourseLen(3), '5v6', nPol);
[rcaDataALL78, ~, ~] = rcaRunProject(RCA([7 8],:), RCAfolder, timeCourseLen(1), '7v8', nPol);
[rcaDataALL910, ~, ~] = rcaRunProject(RCA([9 10],:), RCAfolder, timeCourseLen(2), '9v10', nPol);
[rcaDataALL1112, ~, ~] = rcaRunProject(RCA([11 12],:), RCAfolder, timeCourseLen(3), '11v12', nPol);
[rcaDataALL1314, ~, ~] = rcaRunProject(RCA([13 14],:), RCAfolder, timeCourseLen(1), '13v14', nPol);
[rcaDataALL1516, ~, ~] = rcaRunProject(RCA([15 16],:), RCAfolder, timeCourseLen(2), '15v16', nPol);
[rcaDataALL1718, ~, ~] = rcaRunProject(RCA([17 18],:), RCAfolder, timeCourseLen(3), '17v18', nPol);
[rcaDataALL1920, ~, ~] = rcaRunProject(RCA([19 20],:), RCAfolder, timeCourseLen(1), '19v20', nPol);
[rcaDataALL2122, ~, ~] = rcaRunProject(RCA([21 22],:), RCAfolder, timeCourseLen(2), '21v22', nPol);
[rcaDataALL2324, ~, ~] = rcaRunProject(RCA([23 24],:), RCAfolder, timeCourseLen(3), '23v24', nPol);
[rcaDataALL2526, ~, ~] = rcaRunProject(RCA([25 26],:), RCAfolder, timeCourseLen(1), '25v26', nPol);
[rcaDataALL2728, ~, ~] = rcaRunProject(RCA([27 28],:), RCAfolder, timeCourseLen(2), '27v28', nPol);
[rcaDataALL2930, ~, ~] = rcaRunProject(RCA([29 30],:), RCAfolder, timeCourseLen(3), '29v30', nPol);
[rcaDataALL3132, ~, ~] = rcaRunProject(RCA([31 32],:), RCAfolder, timeCourseLen(1), '31v32', nPol);
[rcaDataALL3334, ~, ~] = rcaRunProject(RCA([33 34],:), RCAfolder, timeCourseLen(2), '33v34', nPol);
[rcaDataALL3536, ~, ~] = rcaRunProject(RCA([35 36],:), RCAfolder, timeCourseLen(3), '35v36', nPol);
toc

%% GENERATE PLOTS
tc1 = linspace(0, timeCourseLen(1), size(rcaDataALL12{1, 1}, 1));
tc2 = linspace(0, timeCourseLen(2), size(rcaDataALL34{1, 1}, 1));
tc3 = linspace(0, timeCourseLen(3), size(rcaDataALL56{1, 1}, 1));

[mu12, s12] = prepData(rcaDataALL12);
[mu34, s34] = prepData(rcaDataALL34);
[mu56, s56] = prepData(rcaDataALL56);
[mu78, s78] = prepData(rcaDataALL78);
[mu910, s910] = prepData(rcaDataALL910);
[mu1112, s1112] = prepData(rcaDataALL1112);
[mu1314, s1314] = prepData(rcaDataALL1314);
[mu1516, s1516] = prepData(rcaDataALL1516);
[mu1718, s1718] = prepData(rcaDataALL1718);
[mu1920, s1920] = prepData(rcaDataALL1920);
[mu2122, s2122] = prepData(rcaDataALL2122);
[mu2324, s2324] = prepData(rcaDataALL2324);
[mu2526, s2526] = prepData(rcaDataALL2526);
[mu2728, s2728] = prepData(rcaDataALL2728);
[mu2930, s2930] = prepData(rcaDataALL2930);
[mu3132, s3132] = prepData(rcaDataALL3132);
[mu3334, s3334] = prepData(rcaDataALL3334);
[mu3536, s3536] = prepData(rcaDataALL3536);
    
group_upper_27_mu = [mu12(:, 1) mu78(:, 1) mu1314(:, 1)];
group_lower_27_mu = [mu1920(:, 1) mu2526(:, 1) mu3132(:, 1)];   
group_upper_27_s = [s12(:, 1) s78(:, 1) s1314(:, 1)];
group_lower_27_s = [s1920(:, 1) s2526(:, 1) s3132(:, 1)];

group_upper_3_mu = [mu34(:, 1) mu910(:, 1) mu1516(:, 1)];
group_lower_3_mu = [mu2122(:, 1) mu2728(:, 1) mu3334(:, 1)];   
group_upper_3_s = [s34(:, 1) s910(:, 1) s1516(:, 1)];
group_lower_3_s = [s2122(:, 1) s2728(:, 1) s3334(:, 1)];

group_upper_37_mu = [mu56(:, 1) mu1112(:, 1) mu1718(:, 1)];
group_lower_37_mu = [mu2324(:, 1) mu2930(:, 1) mu3536(:, 1)];   
group_upper_37_s = [s56(:, 1) s1112(:, 1) s1718(:, 1)];
group_lower_37_s = [s2324(:, 1) s2930(:, 1) s3536(:, 1)];

[h1, h2] = subplotMultipleComponents(tc1, {group_upper_27_mu, group_upper_27_s}, ... % each group = 1 cnd
        {group_lower_27_mu, group_lower_27_s}, {'Lower 2.73 Hz', 'Upper 2.73Hz'});
    saveas(h1, fullfile(RCAfolder, 'Group  2.73 Hz _byGroup.fig'));
    saveas(h2, fullfile(RCAfolder, 'Group  2.73 Hz _byRegion.fig'));
    
[h3, h4] = subplotMultipleComponents(tc2, {group_upper_3_mu, group_upper_3_s}, ... % each group = 1 cnd
    {group_lower_3_mu, group_lower_3_s}, {'Lower 3 Hz', 'Upper 3 Hz'});
    saveas(h3, fullfile(RCAfolder, 'Group  3 Hz _byGroup.fig'));
    saveas(h4, fullfile(RCAfolder, 'Group  3 Hz _byRegion.fig'));
    
[h5, h6] = subplotMultipleComponents(tc3, {group_upper_37_mu, group_upper_37_s}, ... % each group = 1 cnd
    {group_lower_37_mu, group_lower_37_s}, {'Lower 3.75 Hz', 'Upper 3.75 Hz'});
    saveas(h5, fullfile(RCAfolder, 'Group  3.75 Hz _byGroup.fig'));
    saveas(h6, fullfile(RCAfolder, 'Group  3.75 Hz _byRegion.fig'));