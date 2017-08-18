function [data, avgedData, nCnd] = loadData(curDataFolder,stimFrq)
% Takes in data directories and stimulus info and outputs formatted,
% filtered data.
%
% INPUTS
%   curDataFolder:  String. Directory of subject-specific data.
%   stimFrq:        Double. Stimulus frequency.
%
% OUTPUTS
%   data:           Cell array, {1 x nCnd}(nChan x nTrials x nTimepts).
%                   Timecourse data sorted into conditions.
%   avgedData:      Cell array, {1 x nCnd}(nChan x nTimepts).
%                   Timecourse data averaged over trials.
%   nCnd:           Double. Number of conditions.
%
% Bethany H., 2017

% EXTRACTING RAW DATA AND EPOCH REJECTION FILTER
nFrq = length(stimFrq); % # of unique frq values
cndIdx = 1;  
dataFiles = mySubFiles(curDataFolder,'DFT',1);
data = readtable(sprintf('%s/%s',curDataFolder,dataFiles{1}));

