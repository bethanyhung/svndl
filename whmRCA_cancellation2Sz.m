%% ADD CODE BASES TO PATH
addpath(genpath('~/code/git/rcaBase'));
addpath(genpath('~/code/git/mrC'));
addpath(genpath('~/code/git/sweepAnalysis'));
addpath(genpath('~/code/git/svndl'));

%% SET UP: DEFINE VARIABLES & LOAD DATA
clear all
close all

parentDir = '/Users/babylab/Desktop/whm';
paradigm = 'whmCancellation2Sz';
stimFrq = 3;
nPol = 1;

[RCA,RCAfolder] = raw2rca(parentDir,paradigm,stimFrq);

% 1. Raw EEG data is loaded into one big matrix: nSubj (rows) x nTotalConditions(col)  at this step  we only replace bad epochs with NaN and that is it. Each element is nTolalDataSamplePoints x nElectrodes x nTrials.
% 
% 2. Group entries for resampling (extracting samples relevant to each update cycle): each entry in our big matrix will be reshaped from nTolalDataSamplePoints x nElectrodes x nTrials  
% into nCycleSamplePoints x nElectrodes x (nTrials *nCycles ). This data is later fed into RC analysis. No extra processing is being done at this step. 
% 
% RCA's input data should look like this:
% nSubjects (rows) x nDatasetConditions (columns), where each element is nCycleSamplePoints x nElectrodes x (nTrials *nCycles ).
% 
% 3. Plotting a condition: for the error bar width, all subjects' RC data (same dimensions as input: nSubj x nDatasetConditions, except each element now has 
% nCycleSamplePoints x nRCComponents  x (nTrials *nCycles ))  is collapsed and concatenated along 3rd dimension and the working matrix catDataAll is 
% nCycleSamplePoints x nElectrodes x (nSubj * nTrials *nCycles*nDatasetConditions).
% 
% mean: muDataAll = nanmean(catDataAll, 3);
% baseline mean: muDataAll = muDataAll - repmat(muDataAll(1, :), [size(muDataAll, 1) 1]);
% errorbars: semDataAll = nanstd(catDataAll, [], 3)/(sqrt(size(catDataAll, 3)));


%% PERFORM RCA

% RCA_20 = RCA([1,3,5,7,9,11,13:16],:);
% RCA_14 = RCA([2,4,6,8,10,12,17:20],:);
% RCA_F = RCA([1:4],:);
% RCA_P1 = RCA([1:4]+4,:);
% RCA_P2 = RCA([1:4]+8,:);
% RCA_UR = RCA([1,2,5,6,9,10,15,19],:);
% RCA_LR = RCA([3,4,7,8,11,12,16,20],:);
% RCA_UH = RCA([13,17],:);
% RCA_LH = RCA([14,18],:);
        
timeCourseLen = round(1000./stimFrq);
tic
[rcaDataALL12, ~, ~] = rcaRunProject(RCA([1 2],:), RCAfolder, timeCourseLen, '1v2', nPol);
[rcaDataALL34, ~, ~] = rcaRunProject(RCA([3 4],:), RCAfolder, timeCourseLen, '3v4', nPol);
[rcaDataALL56, ~, ~] = rcaRunProject(RCA([5 6],:), RCAfolder, timeCourseLen, '5v6', nPol);
[rcaDataALL78, ~, ~] = rcaRunProject(RCA([7 8],:), RCAfolder, timeCourseLen, '7v8', nPol);
[rcaDataALL910, ~, ~] = rcaRunProject(RCA([9 10],:), RCAfolder, timeCourseLen, '9v10', nPol);
[rcaDataALL1112, ~, ~] = rcaRunProject(RCA([11 12],:), RCAfolder, timeCourseLen, '11v12', nPol);
[rcaDataALL1317, ~, ~] = rcaRunProject(RCA([13 17],:), RCAfolder, timeCourseLen, '13v17', nPol);
[rcaDataALL1418, ~, ~] = rcaRunProject(RCA([14 18],:), RCAfolder, timeCourseLen, '14v18', nPol);
[rcaDataALL1519, ~, ~] = rcaRunProject(RCA([15 19],:), RCAfolder, timeCourseLen, '15v19', nPol);
[rcaDataALL1620, ~, ~] = rcaRunProject(RCA([16 20],:), RCAfolder, timeCourseLen, '16v20', nPol);
toc

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