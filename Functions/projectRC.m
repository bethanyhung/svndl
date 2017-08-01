function projectRC(eegCND, W, A, nComp, titles, timeCourseLen, dirResFigures,sector)
    %project on conditions
    cl = {'b', 'r'};
    
    timeCourse = linspace(0, timeCourseLen, size(eegCND{1, 1}, 1)); % 0 to 0.333 in 140 steps
    how.splitBy = titles;
    close all;
    nCnd = 2;
    h = cell(nCnd, 1);
    %% run the projections, plot the topography
      for c = 1:nComp
         
         subplot(nComp, 2, 2*c - 1);                
         color_idx = 1;        
         for cn = 1:nCnd  
             [muData_C, semData_C] = rcaProjectmyData(eegCND(cn, :), W);
             hs = shadedErrorBar(timeCourse, muData_C(:, c), semData_C(:, c), cl{color_idx}, 1); hold on
             h{cn} = hs.patch;
             color_idx = color_idx + 1;
         end
         legend([h{1:end}], [how.splitBy]'); hold on;
         title(['RC' num2str(c) ' time course']);
         subplot(nComp, 2, 2*c);
         plotOnEgi(A(:,c)); hold on;
      end
     
     if (~exist(dirResFigures, 'dir'))
         mkdir(dirResFigures)
     end
     name = strcat('rcaProject_', how.splitBy{:});
     saveas(gcf, fullfile(dirResFigures, sprintf('%s_%s',name,sector)), 'fig');
     close(gcf);     
end 