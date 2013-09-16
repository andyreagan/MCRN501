close all;
clear all;
%% make pretty plot

tmpfigh = gcf;
clf;
figshape(600,600);
tmpfilename = 'd18O_lisiecki';
tmpfilenoname = sprintf('%s_noname',tmpfilename);

%set(gcf,'Color','none');

set(gcf,'DefaultAxesFontname','helvetica');
set(gcf,'DefaultLineColor','r');
set(gcf,'DefaultAxesColor','none');
set(gcf,'DefaultLineMarkerSize',5);
set(gcf,'DefaultLineMarkerEdgeColor','k');
set(gcf,'DefaultLineMarkerFaceColor','g');
set(gcf,'DefaultAxesLineWidth',0.5);
set(gcf,'PaperPositionMode','auto');

tmpsym = {'o','s','v','o','s','v'};
tmpcol = {'b','g',[101 45 93]/255,'r','k','m'};

positions(1).box = [.2 .2 .7 .7];
axesnum = 1;
tmpaxes(axesnum) = axes('position',positions(axesnum).box);

plot_back=1251;

tmp = load('LR04stack.csv');

plot(fliplr(-tmp(1:plot_back,1)),fliplr(-tmp(1:plot_back,2)),'Color',tmpcol{1},'LineWidth',3);



tmpxlab=xlabel('ky from J2000','fontsize',25,'verticalalignment','top','fontname','helvetica','interpreter','latex');
tmpylab=ylabel('$\delta ^{18}$ O','fontsize',25,'verticalalignment','bottom','fontname','helvetica','interpreter','latex');

% disp(get(tmpxlab,'position'))
% 
set(tmpxlab,'position',get(tmpxlab,'position') - [0 .05 0]); % [x y 0]
set(tmpylab,'position',get(tmpylab,'position') - [.05 0 0]);

%set(gca,'xtick',months_cum_rank)
%month_names={'J','F','M','A','M','J','J','A','S','O','N','D'};
%set(gca,'xticklabel',month_names)

%ylim([5.5 3])
set(gca,'ytick',fliplr([-3 -3.5 -4 -4.5 -5 -5.5]));
tmptmp = {'' '5'  '' '4' '' '3'};
set(gca,'yticklabel',tmptmp,'fontsize',16,'fontname','helvetica');

set(gca,'fontsize',16);
set(gca,'color','none');

% for i=1:12
%   ylabels{i}=num2str(2*i);
% end
% set(gca,'yticklabel',ylabels);

set(gca,'fontsize',16);
set(gca,'color','none');


psprintcpdf_keeppostscript(tmpfilenoname);
tmpcommand = sprintf('open %s.pdf;',tmpfilenoname);
system(tmpcommand);
close all;


%% plot just the insolation
% figure;
% plot_back=1000;
% plot(fliplr(-INSOLN_LA2004_BTL_ASC(1:plot_back,1)),fliplr(insolation(1:plot_back)));
% title('Solar insolation at 65N summer solstice')
% xlabel('W/m^2')
% ylabel('ky from J2000')