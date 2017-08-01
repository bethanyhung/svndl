function plotTimecourse(fnlData,subj,yLim,chanROI,cndROI,cndLabels,names,folder)
% Plots given data.
%
% INPUTS
%   fnlData:    Array double, [nChan x nCnd x nTimept x nSubj]. Timecourse data.
%   subj:       String. Subject you want to plot, or average ('avg').
%   chanROI:    Vector double. Channels you want to see plotted.
%   cndROI:     Vector double. INCREMENT conditions you want to see plotted.
%   cndLabels:  Cell string vector. Names of conditions.
%   names:      Cell string vector. Names of subjects.
%   folder:     String. Directory in which to save the final figure.

% Obtaining the correct data
subjIdx = 1;
if strcmp(subj,'avg')
    data = squeeze(nanmean(fnlData,4));
    SEM = nanstd(fnlData,0,4)./sqrt(length(names)-1);
else
    data = fnlData;
    while ~strcmp(subj,names{subjIdx})
        subjIdx = subjIdx+1;
    end
end

% Setting plot aesthetics
numTimept = size(fnlData,3);
gcaOpts = {'XTick',linspace(0,numTimept,5),'XTickLabel',{'0','83.33','166.67','250','333.33'},...
    'XLim',[0 numTimept],'YLim',yLim,'box','off','tickdir','out',...
    'fontname','Helvetica','linewidth',1.5,'fontsize',10};
red25 = [255 191 191]/255;
blue25 = [191 191 255]/255;

% Generating the plot
figure
for i = 1:length(cndROI)
    for j = 1:length(chanROI)
        subplot(length(cndROI),length(chanROI),j+(i-1)*length(chanROI))
            hold on
            if strcmp(subj,'avg')
                shadedEB(data(chanROI(j),cndROI(i),:),SEM(chanROI(j),cndROI(i),:),blue25);           
                shadedEB(data(chanROI(j),cndROI(i)+1,:),SEM(chanROI(j)+1,cndROI(i),:),red25);
            end
            pH(1,:) = plot(squeeze(data(chanROI(j),cndROI(i),:,subjIdx)),'color','b');
            pH(2,:) = plot(squeeze(data(chanROI(j),cndROI(i)+1,:,subjIdx)),'color','r');           
        title(sprintf('%s: %s, Ch. %d',subj,cndLabels{ceil(cndROI(i)/2)},chanROI(j)))
        set(gca,gcaOpts{:})
        xlabel('Time (ms)');
        ylabel('Potential (mV)');
        legend(pH,{'inc','dec'},'Location','southwest')
    end
end

saveas(gcf, fullfile(folder, 'rawTimecourses'), 'fig');