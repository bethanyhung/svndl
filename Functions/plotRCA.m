function [pooledRCA] = plotRCA(rcaDataALL,yLim,cndLabels,folder,addData)
% Plots given RCA data.
%
% INPUTS
%   rcaDataALL: nSubj x nCnd cell array, of nTimept x nComp x nTrial arrays. RCA output.
%   yLim:       Double vector. Y axis limits.
%   cndLabels:  Cell string vector. Names of conditions.
%   folder:     String. Directory in which to save the final figure.
%   addData:    Double array, same size as 1 cell of rcaDataALL. Any additional data to be overlaid.

nSubj = size(rcaDataALL,1);
nTimept = size(rcaDataALL{1,1},1);
nComp = size(rcaDataALL{1,1},2);
nCnd = size(rcaDataALL,2);

if nargin < 5
    addData = nan(nTimept,nComp,nCnd);
end

for c = 1:nCnd
    for s = 1:nSubj
        concatData(:,:,:,c,s) = rcaDataALL{s,c}; % 140 x 3 x 9 x 10 x 7
    end
end

permuted = permute(concatData,[1 2 4 3 5]); % for SEM purposes only
totaled = reshape(permuted,nTimept,nComp,nCnd,[]); % for SEM purposes only
avgOverTrials = squeeze(nanmean(concatData,3)); % 140 x 3 x 10 x 7
avgOverSubj = squeeze(nanmean(avgOverTrials,4)); % 140 x 3 x 10
rcaSEM = nanstd(totaled,0,4)./sqrt(nSubj-1);

pooledRCA = avgOverSubj;

gcaOpts = {'XTick',linspace(0,nTimept,5),'XTickLabel',{'0','83.33','166.67','250','333.33'},...
    'XLim',[0 nTimept],'YLim',yLim,'box','off','tickdir','out',...
    'fontname','Helvetica','linewidth',1.5,'fontsize',10};
red25 = [255 191 191]/255;
blue25 = [191 191 255]/255;

% Generating the plot
figure
for i = 1:nCnd/2
    for j = 1:nComp
        subplot(nCnd/2,nComp,nComp*(i-1)+j)
            hold on
            shadedEB(avgOverSubj(:,j,2*i-1),rcaSEM(:,j,2*i-1),blue25);           
            shadedEB(avgOverSubj(:,j,2*i),rcaSEM(:,j,2*i),red25);
            pH(1,:) = plot(avgOverSubj(:,j,2*i-1),'color','b');
            pH(2,:) = plot(avgOverSubj(:,j,2*i),'color','r');  
            plot(addData(:,j,i),'color','g')
        title(sprintf('RC%d timecourse: %s',j,cndLabels{i}))
        set(gca,gcaOpts{:})
        xlabel('Time (ms)');
        ylabel('Potential (µV)');
        legend(pH,{'inc','dec'},'Location','northwest')
    end
end
saveas(gcf, fullfile(folder, 'rcaTimecourses'), 'fig');