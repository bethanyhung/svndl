function [muData_C, semData_C] = rcaProjectmyData(eegCND, W)
%   INPUTS
%   eegCND: 1 x nSubj cell array; arrays = 3D arrays of timepts x channels
%   x trials
%   W: set of weights
%   OUTPUTS
%   muData_C:   2D array timecourse, avged over subjects + trials; 140 x nComp
%   semData_C:  2D array SEM timecourse, avged over subjects; 140 x nComp

nSubj = size(eegCND,2);
nTimept = size(eegCND{1,1},1);
nComp = size(W,2);

for s = 1:nSubj
    avgOverTrials{s} = squeeze(nanmean(eegCND{s},3));
    concatData(:,:,s) = avgOverTrials{s}; % 140 x 128 x 9 x 6
end

avgOverSubj = squeeze(nanmean(concatData,3)); % 140 x 128
rcaSEM = nanstd(concatData,0,3)./sqrt(nSubj);
W = W'; % W = 128 x 3

% apply filter, for all three RCs
for i = 1:nTimept
    for j = 1:nComp
        weighted(i,:,j) = avgOverSubj(i,:).*W(j,:); % 140 x 128 x 3
        weightedSEM(i,:,j) = rcaSEM(i,:).*W(j,:);
    end
end

muData_C = squeeze(nanmean(weighted,2));
semData_C = squeeze(nanstd(weighted,0,2)./sqrt(128));