function [yCalc, Rsq, latency, incDelay, slope_cat] = linearReg(results,freq) 

% LINEAR REGRESSION
nFrq = size(results.RC_amp,1);
x = [1:nFrq]'*3; 
X = [ones(length(x),1) x];
for c = 1:size(results.RC_phase,2)
    for cndSet = 1:size(results.RC_phase,3)
        for cnd = 1:size(results.RC_phase,4)
            y = results.RC_phase(:,c,cndSet,cnd);
            slope(:,c,cndSet,cnd) = X\y;
            yCalc(:,c,cndSet,cnd) = X*slope(:,c,cndSet,cnd);
            Rsq(c,cndSet,cnd) = 1 - sum((y - yCalc(:,c,cndSet,cnd)).^2)/sum((y - mean(y)).^2);
%             origslope(:,c,cndSet,cnd) = x\y;
%             origyCalc(:,c,cndSet,cnd) = x*origslope(:,c,cndSet,cnd);
%             Rsq2(c,cndSet,cnd) = 1 - sum((y - origyCalc(:,c,cndSet,cnd)).^2)/sum((y - mean(y)).^2);
            for TrixSubj = 1:size(results.RC_cat_phase,3)
                y = results.RC_cat_phase(:,c,TrixSubj,cndSet,cnd); % not sure if this is correct 
                slope_inter_cat(:,c,TrixSubj,cndSet,cnd) = X\y;
            end
        end
    end
end
slope_value = squeeze(slope(2,:,:,:));
latency = slope_value*1000/(360*freq);
incDelay = latency(:,:,1) - latency(:,:,2);
slope_cat = squeeze(slope_inter_cat(2,:,:,:,:));

end