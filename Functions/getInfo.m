function [dataFolder,dataSet,names,RCAfolder] = getInfo(folder,paradigm,domain,population)
% Takes in parent directory & paradigm; outputs necessary variables for
% data sorting.
%
% INPUTS
%   folder:     String. Parent dir where everything relevant (non-code) is stored.
%   paradigm:   String. Stimulus paradigm; same name as data folder.
%   domain:     String. 'freq' or 'time' denoting the domain of the data export
%   population: String. Name of folder containing group of people you want
%               to use; optional. Defaults to none.
%
% OUTPUTS
%   dataFolder:     String. Directory where paradigm-specific data is stored.
%   dataSet:        Cell array, 1 x nSubj. Names of indiv subject data folders.
%   names:          Cell array, 1 x nSubj + 1. Extracted names of subj, plus 'avg' at end.
%   RCAfolder:      String. Directory to store RCA .fig & .mat files.
%
% Bethany H., 2017

if nargin<4
    dataFolder = sprintf('%s/Data/%s/%s',folder,paradigm,domain);
else
    dataFolder = sprintf('%s/Data/%s/%s/%s',folder,paradigm,domain,population);
end

result = textscan(ls(dataFolder),'%s');
dataSet = result{1}';

for s = 1:length(dataSet)
    if isstrprop(dataSet{s}(end),'alpha')
        names{s} = sprintf('*%s',dataSet{s}(end-1:end));
    else
        names{s} = dataSet{s}(end-3:end);
    end
end
names = sort(names);
if length(names) > 1
    names{length(names)+1} = 'avg';
else
end

RCAfolder = sprintf('%s/RCA_%s_%s',folder,paradigm,domain);
if exist(RCAfolder) ~= 7
    mkdir(RCAfolder)
end

end