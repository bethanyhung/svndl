function plotTimecourse(avgedData,subj,yLim,chanROI,cndROI,cndLabels,names,folder)
% Timecourse comparison of two conditions, averaged over cycle and post
% artifact rejection.
%
% INPUTS
%   avgedData:  Cell array, {1 x subj}{1 x cnd}(timept x channel). Timecourse data.
%   subj:       String. Subject you want to plot, or average ('avg').
%   yLim:       Vector double. Min and max of y axis.
%   chanROI:    Vector double. Channels you want to see plotted.
%   cndROI:     Vector double. INCREMENT conditions you want to see plotted.
%   cndLabels:  Cell string vector. Names of conditions.
%   names:      Cell string vector. Names of subjects.
%   folder:     String. Directory in which to save the final figure.
%
% Bethany H., 2017

% Obtaining the correct data
subjIdx = 1;
if strcmp(subj,'avg')
    for i = 1:length(avgedData)
        for c = 1:length(cndROI)
            extractData(:,:,c,i) = avgedData{i}{cndROI(c)};
        end
    end
    data = squeeze(nanmean(extractData,4));
    SEM = nanstd(extractData,0,4)./sqrt(length(avgedData));
else
    while ~strcmp(subj,names{subjIdx})
        subjIdx = subjIdx+1;
    end
    for c = 1:length(cndROI)
        data(:,:,c) = avgedData{subjIdx}{cndROI(c)};
    end
end

% Setting plot aesthetics
numTimept = size(data,1);
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
                shadedEB(squeeze(data(:,chanROI(j),1)),squeeze(SEM(:,chanROI(j),1)),blue25);           
                shadedEB(squeeze(data(:,chanROI(j),2)),squeeze(SEM(:,chanROI(j),2)),red25);
            end
            pH(1,:) = plot(squeeze(data(:,chanROI(j),1)),'color','b');
            pH(2,:) = plot(squeeze(data(:,chanROI(j),2)),'color','r');           
        title(sprintf('%s: %s, Ch. %d',subj,cndLabels{cndROI(i)},chanROI(j)))
        set(gca,gcaOpts{:})
        xlabel('Time (ms)');
        ylabel('Potential (mV)');
        legend(pH,{cndLabels{cndROI(1)},cndLabels{cndROI(2)}},'Location','southwest')
    end
end

saveas(gcf, fullfile(folder, sprintf('rawTimecourses_%s_%s_vs_%s',subj,cndLabels{cndROI(1)},cndLabels{cndROI(2)})), 'fig');