function [dataFolder,dataSet,names,RCAfolder] = getInfo(folder,paradigm)
% Takes in parent directory & paradigm; outputs necessary variables for
% data sorting.
%
% INPUTS
%   folder:     String. Parent dir where everything relevant (non-code) is stored.
%   paradigm:   String. Stimulus paradigm; same name as data folder.
%
% OUTPUTS
%   dataFolder:     String. Directory where paradigm-specific data is stored.
%   dataSet:        Cell array, 1 x nSubj. Names of indiv subject data folders.
%   names:          Cell array, 1 x nSubj + 1. Extracted names of subj, plus 'avg' at end.
%   RCAfolder:      String. Directory to store RCA .fig & .mat files.
%
% Bethany H., 2017

dataFolder = sprintf('%s/Data/%s',folder,paradigm);
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

RCAfolder = sprintf('%s/RCA_%s',folder,paradigm);
if exist(RCAfolder) ~= 7
    mkdir(RCAfolder)
end

end