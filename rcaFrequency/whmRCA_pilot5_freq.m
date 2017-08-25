%% ADD CODE BASES TO PATH
addpath(genpath('~/code/git/rcaBase'));
addpath(genpath('~/code/git/mrC'));
addpath(genpath('~/code/git/sweepAnalysis'));
addpath(genpath('~/code/git/matlab_lib'));
addpath(genpath('~/code/git/svndl2017'));

%% DEFINE PARAMETERS & PERFORM RCA
clear all
close all

parentDir = '/Users/babylab/Desktop/whm'; % top-level directory with data and RCA figure subfolders
paradigm = 'whmPilot5'; % name of data folder
domain = 'freq';  % name of data subfolder; 'time' | 'freq'
population = 'ctrl(age)'; % name of data subfolder: 'clinical' | 'normal' | 'ctrl(age)'
runAgain = 0; % run RCA again?
fundFreq = 3; % fundamental frequencies

[dataFolder,dataSet,names,RCAfolder] = genDirectories(parentDir,paradigm,domain,population);
fileRCAData = fullfile(RCAfolder, sprintf('processedData_%s_%s.mat',paradigm,population));

for s = 1:length(dataSet)
    subjDataFolder{s} = sprintf('%s/%s', dataFolder,dataSet{s});  
end

binsToUse = 0; % 0 for non-sweep data
freqsToUse = 1:4; % vector of frequency indices to include in RCA [1]
condsToUse = {[1 5],[2 6],[3 7],[4 8],[9 10]}; % vector of conditions to use
trialsToUse = []; % vector of indices of trials to use
nReg = 9; % RCA regularization parameter (defaults to 9)
nComp = 3; % number of RCs to retain (defaults to 3)
dataType = 'DFT'; % 'DFT' | 'RLS'
compareChan = 75; % comparison channel index between 1 and the total number of channels in the specified dataset
show = 1; % 1 to see a figure of sweep amplitudes for each harmonic and component (defaults to 1), 0 to not display
rcPlotStyle = 'matchMaxSignsToRc1'; % 'matchMaxSignsToRc1' | 'orig'; see 'help rcaRun'

if ~exist(fileRCAData) || runAgain
    for c = 1:length(condsToUse)
        rcaStruct(c) = rcaSweep(subjDataFolder,binsToUse,freqsToUse,condsToUse{c},trialsToUse,nReg,nComp,dataType,compareChan,show,rcPlotStyle);
    end
    rcaStruct = fixNans(rcaStruct);
    save(fileRCAData,'rcaStruct');
else
    rcaStruct = load(fileRCAData);
    rcaStruct = rcaStruct.rcaStruct;
end

% CALCULATING AMPLITUDE + PHASE AND SEM

results = extractAmpPhase(rcaStruct);

RC1_amp = squeeze(results.RC_amp(:,1,:,:));
RC1_amp_neg_SEM = squeeze(results.RC_amp_neg_SEM(:,1,:,:));
RC1_amp_pos_SEM = squeeze(results.RC_amp_pos_SEM(:,1,:,:));

RC1_phase = squeeze(results.RC_phase(:,1,:,:));
RC1_phase_neg_SEM = squeeze(results.RC_phase_neg_SEM(:,1,:,:));
RC1_phase_pos_SEM = squeeze(results.RC_phase_pos_SEM(:,1,:,:));

%% STATISTICS

% LINEAR REGRESSION
[yCalc, Rsq, latency, incDelay, slope_cat] = linearReg(results,fundFreq);

% PAIRED T-TEST
for f = 1:length(freqsToUse)
    for cmp = 1:nComp
        for cndSet = 1:length(condsToUse)
            incAmp = squeeze(results.RC_cat_amp(f,cmp,:,cndSet,1));
            decAmp = squeeze(results.RC_cat_amp(f,cmp,:,cndSet,2));
            [hAmp(f,cmp,cndSet),pAmp(f,cmp,cndSet),~,statsAmp(f,cmp,cndSet)] = ttest(incAmp,decAmp);
            
            incSlope = squeeze(slope_cat(cmp,:,cndSet,1));
            decSlope = squeeze(slope_cat(cmp,:,cndSet,2));
            [hSlope(cmp,cndSet),pSlope(cmp,cndSet),~,statsSlope(cmp,cndSet)] = ttest(incSlope',decSlope');
        end
    end
end

%% PLOTTING
phaseYLim = [-200 1400];
cndNames = {'10.4'' ped.','19.9'' ped.','30.3'' ped.','79.6'' ped.','100.4'' ped.'};
gcaOptsAmp = {'XTick',freqsToUse,'XTickLabel',{'1F1','2F1','3F1','4F1'},...
    'YLim',[0 3],'box','off','tickdir','out',...
    'fontname','Helvetica','linewidth',1.5,'fontsize',10};
gcaOptsPhase = {'XTick',freqsToUse*3,... 
    'YLim',phaseYLim,'box','off','tickdir','out',...
    'fontname','Helvetica','linewidth',1.5,'fontsize',10};
nCndSet = length(cndNames);

figure
for c = 1:nCndSet
    subplot(nCndSet,5,c*5-4:c*5-3)        
        hold on
        x = repmat([1;2;3;4],[1,2]);
        amps = squeeze(RC1_amp(:,c,:));
        SEMs = [squeeze(RC1_amp_neg_SEM(:,c,:)),squeeze(RC1_amp_pos_SEM(:,c,:))];
        b = bar(x,amps,'BarWidth',1);
            b(1).FaceColor = 'blue';
            b(2).FaceColor = 'red';              
        e = groupedBarErrorbar(amps,SEMs);
        
        for f = 1:length(freqsToUse)
            if hAmp(f,1,c)
                plot([f-0.28 f+0.28], [1 1]*max(amps(f,:))+0.2, '-k', 'LineWidth',1)
                plot(f, max(amps(f,:))+0.35, '*k')
            end
        end

        legend([b,e],{'inc','dec','SEM'})
        title(sprintf('RC1 amps, %s - %s',cndNames{c},population))
        set(gca,gcaOptsAmp{:})
        if c == nCndSet
            xlabel('Harmonic')
        end
        ylabel('Amplitude (uV)')
        
    subplot(nCndSet,5,c*5-2:c*5-1)
        hold on
        x = freqsToUse*3;
        inc = squeeze(RC1_phase(:,c,1));
        dec = squeeze(RC1_phase(:,c,2));
        incSEM = [squeeze(RC1_phase_neg_SEM(:,c,1)),squeeze(RC1_phase_pos_SEM(:,c,1))];
        decSEM = [squeeze(RC1_phase_neg_SEM(:,c,2)),squeeze(RC1_phase_pos_SEM(:,c,2))]; 
        
        p(3,:) = plot(x',squeeze(yCalc(:,1,c,1)),'color','blue');
        p(4,:) = plot(x',squeeze(yCalc(:,1,c,2)),'color','red');
        p(1,:) = plot(x,inc,'o','color','blue');
        h(1,:) = errorbar(x',inc,incSEM(:,1),incSEM(:,2),'blue','linestyle','none');
        p(2,:) = plot(x,dec,'o','color','red');
        h(2,:) = errorbar(x',dec,decSEM(:,1),decSEM(:,2),'red','linestyle','none'); 
        
        if hSlope(1,c)
            plot(x(end),inc(1), '*k')
            text(x(1)-.3,phaseYLim(2)-520,sprintf('h = 1, p = %.3f',pSlope(1,c)),'FontSize',9,'Color','k');
        end
        
        text(x(1)-.3,phaseYLim(2)-100,sprintf('inc: %.2f ms, R^2 = %.3f',latency(1,c,1),Rsq(1,c,1)),'FontSize',9,'Color','b');
        text(x(1)-.3,phaseYLim(2)-230,sprintf('dec: %.2f ms, R^2 = %.3f',latency(1,c,2),Rsq(1,c,2)),'FontSize',9,'Color','r');
        text(x(1)-.3,phaseYLim(2)-390,sprintf('latency diff inc-dec = %.2f ms',incDelay(1,c)),'FontSize',9,'Color','k');
        
        title(sprintf('RC1 phase, %s - %s',cndNames{c},population))
        set(gca,gcaOptsPhase{:})
        ylabel('Degrees')
        if c == nCndSet
            xlabel('Hz')
        end
        
    subplot(nCndSet,5,c*5)
        A = rcaStruct(c).A(:,1);
        plotOnEgi(A);
        title(sprintf('RC1 topography, %s',cndNames{c}))
end

fprintf('Saving figures...\n')
saveas(gcf, fullfile(RCAfolder, sprintf('%s_RC1_%s',paradigm,population)), 'fig');
fig = gcf;
fig.PaperUnits = 'inches';
fig.PaperPosition = [0 0 10 10];
print(fullfile(RCAfolder, sprintf('%s_RC1_%s',paradigm,population)),'-dpng')
fprintf('Figures saved.\n')

%% POLAR PLOTS
% close all
% figure
% % hold on
% polar([0,squeeze(subjMeanPhase(1,1,1,1))],[0,squeeze(subjMeanAmp(1,1,1,1))],'o-')
% figure
% polar([0,squeeze(subjMeanPhase(2,1,1,1))],[0,squeeze(subjMeanAmp(2,1,1,1))],'o-')
