function rcaStruct = fixNans(rcaStruct)
%   RCA replaces NaNs with zeroes; this fixes it. Excerpted from Peter &
%   Frank's numeroOddball paradigm analysis code.
%   Input & output are the rcaStruct from rcaSweep.m

nanDims = [1,2]; % if all time points are zero, or all channels are zero
structVars = {'data','noiseData','comparisonData','comparisonNoiseData'};
noiseVars = {'lowerSideBand','higherSideBand'};
for z=1:length(structVars)
    if strfind(lower(structVars{z}),'noise')
        for n = 1:length(noiseVars)
            for f=1:length(rcaStruct)
                rcaStruct(f).(structVars{z}).(noiseVars{n}) = cellfun(@(x) Zero2NaN(x,nanDims),rcaStruct(f).(structVars{z}).(noiseVars{n}),'uni',false);
            end
        end
    else
        for f=1:length(rcaStruct)
            rcaStruct(f).(structVars{z}) = cellfun(@(x) Zero2NaN(x,nanDims),rcaStruct(f).(structVars{z}),'uni',false);
        end
    end
end