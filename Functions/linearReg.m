function [yCalc, Rsq, latency, incDelay, slope_cat] = linearReg(results,fundFreq) 
% Takes in RC phase calculations; generates best-fit line y-values,
% statistics, and translates phase angle slope into latency. 
%
% INPUTS
%   results:    Struct. Output of extractAmpPhase.m.
%   fundFreq:   Double vector. The fundamental frequencies of the stimuli.
%
% OUTPUTS
%   yCalc:      Double vector. y values for linear best-fit line.
%   Rsq:        Pearson correlation coefficients for linear regression.
%   latency:    Double array. All latencies in milliseconds.
%   incDelay:   Increment latency - decrement latency.
%   slope_cat:  All slopes for all subjects and trials, for SEM
%               calculation.
%
% Bethany H., 2017

nFrq = size(results.RC_amp,1);
nCndSet = size(results.RC_amp,3);
freq = repmat(fundFreq, [1,nCndSet]); 

for c = 1:size(results.RC_phase,2)
    for cndSet = 1:size(results.RC_phase,3)
        for cnd = 1:size(results.RC_phase,4)
            x = [1:nFrq]'*fundFreq(cnd); 
            X = [ones(length(x),1) x];
            y = results.RC_phase(:,c,cndSet,cnd);
            slope(:,c,cndSet,cnd) = X\y;
            yCalc(:,c,cndSet,cnd) = X*slope(:,c,cndSet,cnd);
            Rsq(c,cndSet,cnd) = 1 - sum((y - yCalc(:,c,cndSet,cnd)).^2)/sum((y - mean(y)).^2);
            for TrixSubj = 1:size(results.RC_cat_phase,3)
                y = results.RC_cat_phase(:,c,TrixSubj,cndSet,cnd);
                slope_inter_cat(:,c,TrixSubj,cndSet,cnd) = X\y;
            end
        end
    end
end

slope_value = squeeze(slope(2,:,:,:));
for i = 1:size(slope_value,2)
    latency(:,i,:) = slope_value(:,i,:)*1000/(360*freq(i));
end
incDelay = latency(:,:,1) - latency(:,:,2);
slope_cat = squeeze(slope_inter_cat(2,:,:,:,:));

end