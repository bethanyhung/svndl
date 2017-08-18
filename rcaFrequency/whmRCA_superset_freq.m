%% ADD CODE BASES TO PATH
addpath(genpath('~/code/git/rcaBase'));
addpath(genpath('~/code/git/mrC'));
addpath(genpath('~/code/git/sweepAnalysis'));
addpath(genpath('~/code/git/matlab_lib'));
addpath(genpath('~/code/git/svndl'));

clear all
% close all

parentDir = '/Users/babylab/Desktop/whm';
paradigm = 'whmSuperSet';
domain = 'freq';
runAgain = 0;

[dataFolder,dataSet,names,RCAfolder] = getInfo(parentDir,paradigm,domain);
fileRCAData = fullfile(RCAfolder, sprintf('processedData_%s.mat',paradigm));

for s = 1:length(dataSet)
    subjDataFolder{s} = sprintf('%s/%s', dataFolder,dataSet{s});  
end

binsToUse = 0; % 0 for non-sweep data
freqsToUse = 1:5; % vector of frequency indices to include in RCA [1]
condsToUse = {[1 2],[3 4],[5 6],[7 8],[9 10],[11 12],[13 14],[15 16],[17 18],[19 20],[21 22],[23 24],[25 26],[27 28],[29 30],[31 32],[33 34],[35 36]}; % vector of conditions to use
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
    save(fileRCAData,'rcaStruct');
else
    rcaStruct = load(fileRCAData);
    rcaStruct = rcaStruct.rcaStruct;
end

%% AMPLITUDE/PHASE PLOTS
for c = 1:length(condsToUse)
    RC{c} = rcaStruct(c).data;
    Oz{c} = rcaStruct(c).comparisonData;
    for cnd = 1:length(condsToUse{1})
        for s = 1:length(dataSet)
            RC_avgOverTri = nanmean(RC{c}{cnd,s},3);
            Oz_avgOverTri = nanmean(Oz{c}{cnd,s},3);
            RC_cos = RC_avgOverTri(1:5,:);
            RC_sin = RC_avgOverTri(6:10,:);
%             RC_cos = RC_avgOverTri([1 3 5 7 9],:);
%             RC_sin = RC_avgOverTri([2 4 6 8 10],:);
            RC_amp(:,:,c,cnd,s) = sqrt(RC_cos.^2 + RC_sin.^2); % 5 3 5 2 7 = coeff x comp x cndGroupings x cnd x subj
            RC_phase(:,:,c,cnd,s) = radtodeg(atan(RC_sin./RC_cos)); % NOT BEING CALCULATED CORRECTLY...
            Oz_cos = Oz_avgOverTri(1:5,:);
            Oz_sin = Oz_avgOverTri(6:10,:);
%             Oz_cos = Oz_avgOverTri([1 3 5 7 9],:);
%             Oz_sin = Oz_avgOverTri([2 4 6 8 10],:);
            Oz_amp(:,:,c,cnd,s) = sqrt(Oz_cos.^2 + Oz_sin.^2); % 5 1 5 2 7 = coeff x comp x cndGroupings x cnd x subj
            Oz_phase(:,:,c,cnd,s) = radtodeg(atan(Oz_sin./Oz_cos));
        end
    end
end

RC_amp_avg = squeeze(nanmean(RC_amp,5));
RC_phase_avg = squeeze(nanmean(RC_phase,5));
Oz_amp_avg = squeeze(nanmean(Oz_amp,5));
Oz_phase_avg = squeeze(nanmean(Oz_phase,5));

RC_amp_SEM = nanstd(RC_amp,[],5)/(sqrt(size(RC_amp,5)));
RC_phase_SEM = nanstd(RC_phase,[],5)/(sqrt(size(RC_phase,5)));
Oz_amp_SEM = nanstd(Oz_amp,[],5)/(sqrt(size(Oz_amp,5)));
Oz_phase_SEM = nanstd(Oz_phase,[],5)/(sqrt(size(Oz_phase,5)));

RC1_amp = squeeze(RC_amp_avg(:,1,:,:)); % 5 5 2
RC1_amp_SEM = squeeze(RC_amp_SEM(:,1,:,:)); % 5 5 2
RC1_phase = squeeze(RC_phase_avg(:,1,:,:)); % 5 5 2
RC1_phase_SEM = squeeze(RC_phase_SEM(:,1,:,:)); % 5 5 2
Oz_amp = Oz_amp_avg; % 5 5 2
Oz_phase = Oz_phase_avg; % 5 5 2
Oz_amp_SEM = squeeze(Oz_amp_SEM);
Oz_phase_SEM = squeeze(Oz_phase_SEM);

%%
cndNames = {'SF 2.73','SF 3','SF 3.75'};
gcaOptsAmp = {'XTick',1:5,'XTickLabel',{'1F1','2F1','3F1','4F1','5F1'},...
    'YLim',[0 2],'box','off','tickdir','out',...
    'fontname','Helvetica','linewidth',1.5,'fontsize',10};
gcaOptsPhase = {'XTick',1:5,'XTickLabel',{'1F1','2F1','3F1','4F1','5F1'},...
    'YLim',[-120 120],'box','off','tickdir','out',...
    'fontname','Helvetica','linewidth',1.5,'fontsize',10};

figure
for c = 1:3
    subplot(length(cndNames),2,c*2-1)
        x = repmat([1;2;3;4;5],[1,4]);
        amps = [squeeze(RC1_amp(:,c,:)),squeeze(Oz_amp_avg(:,c,:))];
        SEMs = [squeeze(RC1_amp_SEM(:,c,:)),squeeze(Oz_amp_SEM(:,c,:))];
        b = bar(x,amps);
        b(1).FaceColor = 'blue';
        b(2).FaceColor = 'red';
        b(3).FaceColor = [0 1 1];
        b(4).FaceColor = [1 0 1];
%         errorbar(x,amps,SEMs);
        legend(b,{'inc','dec','inc Oz','dec Oz'});
        title(sprintf('RC1 harmonic amplitudes, %s',cndNames{c}))
        set(gca,gcaOptsAmp{:})
        ylabel('Amplitude (uV)');
    subplot(length(cndNames),2,c*2)
    hold on
        p(1,:) = plot(squeeze(RC1_phase(:,c,1)),'o-','color','blue');
        p(2,:) = plot(squeeze(RC1_phase(:,c,2)),'o-','color','red');
        p(3,:) = plot(squeeze(Oz_phase(:,c,1)),'o-','color',[0 1 1]);
        p(4,:) = plot(squeeze(Oz_phase(:,c,2)),'o-','color',[1 0 1]);
        legend(p,{'inc','dec','inc Oz','dec Oz'}); % 
        title(sprintf('RC1 phase shift, %s',cndNames{c}))
        set(gca,gcaOptsPhase{:})
        ylabel('Degrees');
end
%% POLAR PLOTS
close all
figure
% hold on
polar([0,squeeze(subjMeanPhase(1,1,1,1))],[0,squeeze(subjMeanAmp(1,1,1,1))],'o-')
figure
polar([0,squeeze(subjMeanPhase(2,1,1,1))],[0,squeeze(subjMeanAmp(2,1,1,1))],'o-')
