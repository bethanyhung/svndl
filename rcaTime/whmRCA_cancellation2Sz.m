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
newSubj = 0;

[RCA,RCAfolder] = raw2rca(parentDir,paradigm,stimFrq,newSubj);

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
%%
timeCourseLen = round(1000./stimFrq);
tic
[rcaDataALL1, ~, ~] = rcaRunProject(RCA(1,:), RCAfolder, timeCourseLen, '1', nPol);
[rcaDataALL2, ~, ~] = rcaRunProject(RCA(2,:), RCAfolder, timeCourseLen, '2', nPol);
[rcaDataALL3, ~, ~] = rcaRunProject(RCA(3,:), RCAfolder, timeCourseLen, '3', nPol);
[rcaDataALL4, ~, ~] = rcaRunProject(RCA(4,:), RCAfolder, timeCourseLen, '4', nPol);
[rcaDataALL5, ~, ~] = rcaRunProject(RCA(5,:), RCAfolder, timeCourseLen, '5', nPol);
[rcaDataALL6, ~, ~] = rcaRunProject(RCA(6,:), RCAfolder, timeCourseLen, '6', nPol);
[rcaDataALL7, ~, ~] = rcaRunProject(RCA(7,:), RCAfolder, timeCourseLen, '7', nPol);
[rcaDataALL8, ~, ~] = rcaRunProject(RCA(8,:), RCAfolder, timeCourseLen, '8', nPol);
[rcaDataALL9, ~, ~] = rcaRunProject(RCA(9,:), RCAfolder, timeCourseLen, '9', nPol);
[rcaDataALL10, ~, ~] = rcaRunProject(RCA(10,:), RCAfolder, timeCourseLen, '10', nPol);
[rcaDataALL11, ~, ~] = rcaRunProject(RCA(11,:), RCAfolder, timeCourseLen, '11', nPol);
[rcaDataALL12, ~, ~] = rcaRunProject(RCA(12,:), RCAfolder, timeCourseLen, '12', nPol);
[rcaDataALL13, ~, ~] = rcaRunProject(RCA(13,:), RCAfolder, timeCourseLen, '13', nPol);
[rcaDataALL14, ~, ~] = rcaRunProject(RCA(14,:), RCAfolder, timeCourseLen, '14', nPol);
[rcaDataALL15, ~, ~] = rcaRunProject(RCA(15,:), RCAfolder, timeCourseLen, '15', nPol);
[rcaDataALL16, ~, ~] = rcaRunProject(RCA(16,:), RCAfolder, timeCourseLen, '16', nPol);
[rcaDataALL17, ~, ~] = rcaRunProject(RCA(17,:), RCAfolder, timeCourseLen, '17', nPol);
[rcaDataALL18, ~, ~] = rcaRunProject(RCA(18,:), RCAfolder, timeCourseLen, '18', nPol);
[rcaDataALL19, ~, ~] = rcaRunProject(RCA(19,:), RCAfolder, timeCourseLen, '19', nPol);
[rcaDataALL20, ~, ~] = rcaRunProject(RCA(20,:), RCAfolder, timeCourseLen, '20', nPol);
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
    
group_upper_f_mu = [mu12(:, 1) mu56(:, 1) mu910(:, 1)];
group_lower_f_mu = [mu34(:, 1) mu78(:, 1) mu1112(:, 1)];   
group_upper_f_s = [s12(:, 1) s56(:, 1) s910(:, 1)];
group_lower_f_s = [s34(:, 1) s78(:, 1) s1112(:, 1)];

% group_upper_3_mu = [mu34(:, 1) mu910(:, 1) mu1516(:, 1)];
% group_lower_3_mu = [mu2122(:, 1) mu2728(:, 1) mu3334(:, 1)];   
% group_upper_3_s = [s34(:, 1) s910(:, 1) s1516(:, 1)];
% group_lower_3_s = [s2122(:, 1) s2728(:, 1) s3334(:, 1)];

[h1, h2] = subplotMultipleComponents(tc, {group_upper_f_mu, group_upper_f_s}, ... % each group = 1 cnd
        {group_lower_f_mu, group_lower_f_s}, {'Lower fovea', 'Upper fovea'});
    saveas(h1, fullfile(RCAfolder, 'Group  2.73 Hz _byGroup.fig'));
    saveas(h2, fullfile(RCAfolder, 'Group  2.73 Hz _byRegion.fig'));
    
% [h3, h4] = subplotMultipleComponents(tc, {group_upper_3_mu, group_upper_3_s}, ... % each group = 1 cnd
%     {group_lower_3_mu, group_lower_3_s}, {'Lower 3 Hz', 'Upper 3 Hz'});
%     saveas(h3, fullfile(RCAfolder, 'Group  3 Hz _byGroup.fig'));
%     saveas(h4, fullfile(RCAfolder, 'Group  3 Hz _byRegion.fig'));