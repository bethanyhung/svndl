function results = extractAmpPhase(rcaStruct)
%   Takes in frequency-domain RCA data and outputs amplitude, phase, and
%   SEM values.
%
%   INPUT
%   rcaStruct - struct of RCA data from rcaSweep.m
%
%   OUTPUTS
%   results - struct with the following fields: 
%       RC_amp, RC_phase - calculated amplitude and unwrapped phase for each harmonic
%       RC_amp_neg_SEM, RC_phase_neg_SEM - lower bound for SEM, formatted for direct input into errorbar
%       RC_amp_pos_SEM, RC_phase_pos_SEM - upper bound ''
%       RC_cat_amp, RC_cat_phase - amplitudes and phase calculated for every subject and trial; for statistical testing
%       Oz_amp, Oz_phase - single-channel (ch. 75, non-RC) amplitude and phase (non-unwrapped) used for reference/comparison 
%
%   Bethany H. 2017

cndGroupings = length(rcaStruct);

for c = 1:cndGroupings
    RC{c} = rcaStruct(c).data;
    Oz{c} = rcaStruct(c).comparisonData;    
    for cnd = 1:size(RC{c},1)
        curRC = RC{c}(cnd,:);
        RC_cat{c}{cnd} = cat(3,curRC{:});
        for s = 1:size(RC{c},2)
            RC_avgOverTri = nanmean(RC{c}{cnd,s},3);
            Oz_avgOverTri = nanmean(Oz{c}{cnd,s},3);
            RC_cos(:,:,c,cnd,s) = RC_avgOverTri(1:5,:);
            RC_sin(:,:,c,cnd,s) = RC_avgOverTri(6:10,:);
            Oz_cos(:,:,c,cnd,s) = Oz_avgOverTri(1:5,:);
            Oz_sin(:,:,c,cnd,s) = Oz_avgOverTri(6:10,:);
        end
        RC_cat_cos(:,:,:,c,cnd) = RC_cat{c}{cnd}(1:5,:,:);
        RC_cat_sin(:,:,:,c,cnd) = RC_cat{c}{cnd}(6:10,:,:);
    end
end

RC_cos_avg = squeeze(nanmean(RC_cos,5)); % harmonics x components x cndgroupings x inc/dec
RC_sin_avg = squeeze(nanmean(RC_sin,5));

RC_amp = sqrt(RC_cos_avg.^2 + RC_sin_avg.^2);
RC_phase_raw = radtodeg(atan2(RC_sin_avg,RC_cos_avg));
RC_phase = unwrapPos(RC_phase_raw);

RC_cat_amp = sqrt(RC_cat_cos.^2 + RC_cat_sin.^2);
RC_cat_phase_raw = radtodeg(atan2(RC_cat_sin,RC_cat_cos));
RC_cat_phase = unwrapPos(RC_cat_phase_raw);

Oz_cos_avg = squeeze(nanmean(Oz_cos,5));
Oz_sin_avg = squeeze(nanmean(Oz_sin,5));
Oz_amp = sqrt(Oz_cos_avg.^2 + Oz_sin_avg.^2);
Oz_phase = radtodeg(atan2(Oz_sin_avg,Oz_cos_avg)); % still wrapped for PowerDiva reference purposes

% CALCULATING ERROR
for f = 1:size(RC_cos,1)
    for c = 1:size(RC_cos,2)
        for cndSet = 1:size(RC_cos,3)
            for cnd = 1:size(RC_cos,4)
                xyData = [squeeze(RC_cos(f,c,cndSet,cnd,:)),squeeze(RC_sin(f,c,cndSet,cnd,:))];
                [amplBounds,phaseBounds,~] = fitErrorEllipse(xyData,'SEM',0);
                lowerAmpBound(f,c,cndSet,cnd) = amplBounds(1);
                upperAmpBound(f,c,cndSet,cnd) = amplBounds(2);
                lowerPhaseBound(f,c,cndSet,cnd) = phaseBounds(1);
                upperPhaseBound(f,c,cndSet,cnd) = phaseBounds(2);
            end
        end
    end
end

% INVESTIGATE HIGH AMP ERROR BARS
f=5; c=1; cndSet=2; cnd=1;
xyData = [squeeze(RC_cos(f,c,cndSet,cnd,:)),squeeze(RC_sin(f,c,cndSet,cnd,:))];
RC_phase_raw(f,c,cndSet,cnd)
%%%%%%

RC_amp_neg_SEM = RC_amp - lowerAmpBound;
RC_amp_pos_SEM = upperAmpBound - RC_amp;
RC_phase_neg_SEM = RC_phase_raw - lowerPhaseBound;
RC_phase_pos_SEM = upperPhaseBound - RC_phase_raw;

% unwrapping
RC_phase_neg_SEM(RC_phase_neg_SEM < -90) = RC_phase_neg_SEM(RC_phase_neg_SEM < -90) + 360;
RC_phase_pos_SEM(RC_phase_pos_SEM < -90) = RC_phase_pos_SEM(RC_phase_pos_SEM < -90) + 360;
RC_phase_neg_SEM(RC_phase_neg_SEM > 90) = RC_phase_neg_SEM(RC_phase_neg_SEM > 90) - 360;
RC_phase_pos_SEM(RC_phase_pos_SEM > 90) = RC_phase_pos_SEM(RC_phase_pos_SEM > 90) - 360;

% FORMATTING FOR OUTPUT
results.RC_amp = RC_amp;
results.RC_phase = RC_phase;
results.RC_amp_neg_SEM = RC_amp_neg_SEM;
results.RC_amp_pos_SEM = RC_amp_pos_SEM;
results.RC_phase_neg_SEM = RC_phase_neg_SEM;
results.RC_phase_pos_SEM = RC_phase_pos_SEM;
results.RC_cat_amp = RC_cat_amp;
results.RC_cat_phase = RC_cat_phase;
results.Oz_amp = Oz_amp;
results.Oz_phase = Oz_phase;

end

% TESTING
% c=1;
% f=4;cndSet=1;cnd=2;
% RC_phase(f,c,cndSet,cnd)
% RC_phase_wrapped(f,c,cndSet,cnd)
% xyData = [squeeze(RC_cos(f,c,cndSet,cnd,:)),squeeze(RC_sin(f,c,cndSet,cnd,:))];
% [~,~,errorEllipse] = fitErrorEllipse(xyData,'SEM',1);
% 
% lowerPhaseBound(f,c,cndSet,cnd)
% upperPhaseBound(f,c,cndSet,cnd)
% RC_phase_neg_SEM(f,c,cndSet,cnd)
% RC_phase_pos_SEM(f,c,cndSet,cnd)

% OLD ERROR PROPAGATION
% rcSinError = nanstd(RC_sin,[],5)/(sqrt(length(dataSet)));
% rcCosError = nanstd(RC_cos,[],5)/(sqrt(length(dataSet)));
% rcSinSqError = RC_sin_avg.^2.*(2*(rcSinError./RC_sin_avg));
% rcCosSqError = RC_cos_avg.^2.*(2*(rcCosError./RC_cos_avg));
% rcAmpSqError = sqrt(rcSinSqError.^2 + rcCosSqError.^2);
% RC_amp_SEM = (RC_amp*0.5).*(rcAmpSqError./(RC_sin_avg.^2 + RC_cos_avg.^2));
% 
% rcSinOverCosError = (RC_sin_avg./RC_cos_avg).*(sqrt((rcSinError./RC_sin_avg).^2 + (rcCosError./RC_cos_avg).^2));
% RC_phase_SEM = radtodeg(rcSinOverCosError./(1+(RC_sin_avg./RC_cos_avg).^2));