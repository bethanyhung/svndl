function [muData, semData] = prepData(rcaDataALL)
    catData = cat(3, rcaDataALL{:});
    muData = nanmean(catData, 3);
    muData = muData - repmat(muData(1, :), [size(muData, 1) 1]); % baselining
    semData = nanstd(catData, [], 3)/(sqrt(size(catData, 3)));
end