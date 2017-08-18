function e = groupedBarErrorbar(amps,SEMs)

ngroups = size(amps, 1);
nbars = size(amps, 2);
groupwidth = min(0.8, nbars/(nbars + 1.5));
for i = 1:nbars
    x = (1:ngroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*nbars);
    e = errorbar(x, amps(:,i), SEMs(:,i), 'k', 'linestyle', 'none');
end