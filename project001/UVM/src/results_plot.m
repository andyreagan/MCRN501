% plot results


load ../data/dO18/d18o.txt
load odeData.txt
load discreteData.txt

tmpfigh = gcf;
clf;
figshape(800,800);
tmpfilename = 'results_plot';
tmpfilenoname = sprintf('%s_noname',tmpfilename);

set(gcf,'DefaultAxesFontname','helvetica');
set(gcf,'DefaultLineColor','r');
set(gcf,'DefaultAxesColor','none');
set(gcf,'DefaultLineMarkerSize',5);
set(gcf,'DefaultLineMarkerEdgeColor','k');
set(gcf,'DefaultLineMarkerFaceColor','g');
set(gcf,'DefaultAxesLineWidth',0.5);
set(gcf,'PaperPositionMode','auto');

tmpsym = {'o','s','v','o','s','v'};
tmpcol = {'b','g',[125, 38, 205]/255,'r','k','m'};

positions(1).box = [.2 .2 .7 .7];
axesnum = 1;
tmpaxes(axesnum) = axes('position',positions(axesnum).box);

plot(odeData(:,1),(odeData(:,2)-mean(odeData(:,2)))./max(odeData(:,2)-mean(odeData(:,2)))+1,'Color',tmpcol{1},'LineWidth',3)
hold on;
plot(discreteData(:,1),(discreteData(:,2)-0.2785)./(max(discreteData(:,2)-0.2785)+.3)+3,'Color',tmpcol{3},'LineWidth',3)
plot(d18o(:,1),(d18o(:,2)-mean(d18o(:,2)))./max(d18o(:,2)-mean(d18o(:,2)))+5,'Color',tmpcol{2},'LineWidth',3)

ylim([-.2 6])
xlim([-1000 20])
% shift = 3.5;
set(gca,'ytick',[0 1 2 4 5 6])
set(gca,'yticklabel',{-1,0,1,-1,0,1})

% line(1) = plot(fliplr(insol_data(1:-start_time,1)),params{4}.*ones(length(1:-start_time),1)+shift,'b--','LineWidth',1.1);
% line(2) = plot(fliplr(insol_data(1:-start_time,1)),params{1}.*ones(length(1:-start_time),1)+shift,'r--','LineWidth',1.2);
% plot(fliplr(insol_data(1:-start_time,1)),fliplr(insol_data(1:-start_time,6))+shift,'Color',tmpcol{2},'LineWidth',3);
% legend(line,{'i_3','i_0'});



tmpxlab=xlabel('ky from J2000','fontsize',25,'verticalalignment','top','fontname','helvetica','interpreter','latex');
tmpylab=ylabel('ODE Model$~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ~~\delta ^{18}$O','fontsize',25,'verticalalignment','bottom','fontname','helvetica','interpreter','latex');

% disp(get(tmpxlab,'position'))

% set(tmpxlab,'position',get(tmpxlab,'position') - [0 .15 0]); % [x y 0]
set(tmpylab,'position',get(tmpylab,'position') + [0 -.15 0]);

set(gca,'fontsize',15);

set(gca,'color','none');
set(gca,'Box','off');
axesPosition = get(gca,'Position');  
hNewAxes = axes('Position',axesPosition,...  %# Place a new axes on top...
                'Color','none',...           %#   ... with no background color
                'YLim',[-0.5 5.3],...            %#   ... and a different scale
                'YAxisLocation','right',...
                'Ytick',[2.15 3 3.85]-0.5,...%#   ... located on the right
                'XTick',[],...               %#   ... with no x tick marks
                'Box','off');                %#   ... and no surrounding box
% set(gcf,'DefaultAxesFontname','helvetica');
% set(gcf,'DefaultLineColor','r');
% set(gcf,'DefaultAxesColor','none');
% set(gcf,'DefaultLineMarkerSize',5);
% set(gcf,'DefaultLineMarkerEdgeColor','k');
% set(gcf,'DefaultLineMarkerFaceColor','g');
% set(gcf,'DefaultAxesLineWidth',0.5);
% set(gcf,'PaperPositionMode','auto');
tmptmp = {'g','i','G'};
set(gca,'yticklabel',tmptmp,'fontsize',16,'fontname','helvetica');

tmpylab=ylabel('Discrete Model','fontsize',25,'verticalalignment','bottom','fontname','helvetica','interpreter','latex','rot',-90);
%set(tmpylab,'position',get(tmpylab,'position') + [-0.02 -.01 0]);




psprintcpdf_keeppostscript(tmpfilenoname);
tmpcommand = sprintf('open %s.pdf;',tmpfilenoname);
system(tmpcommand);
