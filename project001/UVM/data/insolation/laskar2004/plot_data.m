% % insolation data calculation
% 
% % http://en.wikipedia.org/wiki/Milankovitch_cycles
% 
% load INSOLN.LA2004.BTL.ASC
% 
% plot_back = 800;
% 
% close all;
% figure;
% subplot(6,1,2);
% plot(INSOLN_LA2004_BTL_ASC(1:plot_back,1),INSOLN_LA2004_BTL_ASC(1:plot_back,2));
% title('eccentricity e')
% 
% subplot(6,1,1);
% plot(INSOLN_LA2004_BTL_ASC(1:plot_back,1),INSOLN_LA2004_BTL_ASC(1:plot_back,3));
% title('obliquity \epsilon')
% 
% subplot(6,1,3);
% plot(INSOLN_LA2004_BTL_ASC(1:plot_back,1),sin(INSOLN_LA2004_BTL_ASC(1:plot_back,4)));
% title('sin(\omega)')
% 
% subplot(6,1,4);
% plot(INSOLN_LA2004_BTL_ASC(1:plot_back,1),INSOLN_LA2004_BTL_ASC(1:plot_back,2).*sin(INSOLN_LA2004_BTL_ASC(1:plot_back,4)));
% title('e sin(\omega)')
% 
% s0 = 1367; % solar constant
% phi = deg2rad(65); % latitude
% theta = pi/2; % summer solstice
% 
% % insolation = zeros(length(INSOLN_LA2004_BTL_ASC(:,1)),1);
% % 
% % for i=1:length(INSOLN_LA2004_BTL_ASC(:,1))
% % 
% % e = INSOLN_LA2004_BTL_ASC(i,2); % eccentricity
% % eps = INSOLN_LA2004_BTL_ASC(i,3); % obliquity
% % pibar = INSOLN_LA2004_BTL_ASC(i,4); % perihelion distance
% % 
% % dist_sun = (1+e*cos(theta - pibar)); %/(1-e^2);
% % 
% % delta = eps; % at the summer solstice
% % 
% % h0 = acos(-tan(phi)*tan(delta));
% % q = s0/pi*dist_sun^2*(h0*sin(phi)*sin(delta)+cos(phi)*cos(delta)*sin(h0));
% % 
% % insolation(i) = q;
% % end
% 
% subplot(6,1,5);
% plot(INSOLN_LA2004_BTL_ASC(1:plot_back,1),insolation(1:plot_back));
% title('insolation')
% 
% subplot(6,1,6);
% plot(fliplr(-INSOLN_LA2004_BTL_ASC(1:plot_back,1)),fliplr(insolation(1:plot_back)));
% title('insolation, climate guys axis')

close all;
clear all;
%% make pretty plot

tmpfigh = gcf;
clf;
figshape(600,1000);
tmpfilename = 'insol_data2';
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

plot_back=1000;

tmp = load('INSOLN.LA2004.BTL.ASC');
time = tmp(1:plot_back,1);

% generate insolation data
insolation = zeros(length(tmp(:,1)),1);
s0 = 1367; % solar constant
phi = deg2rad(65); % latitude
theta = pi/2; % summer solstice
for i=1:length(tmp(:,1))
    e = tmp(i,2); % eccentricity
    eps = tmp(i,3); % obliquity
    pibar = tmp(i,4); % perihelion distance
    dist_sun = (1+e*cos(theta - pibar)); %/(1-e^2);
    delta = eps; % at the summer solstice
    %delta = asin(sin(eps)*sin(phi+pibar+pi));
    h0 = acos(-tan(phi)*tan(delta)); %sunrise, in hour angle
    insolation(i) = s0/pi*dist_sun^2*(h0*sin(phi)*sin(delta)+cos(phi)*cos(delta)*sin(h0));
end

data = {tmp(1:plot_back,2),tmp(1:plot_back,3),sin(tmp(1:plot_back,4))...
    ,tmp(1:plot_back,2).*sin(tmp(1:plot_back,4)),insolation(1:plot_back)};
insol_data = [tmp(:,1) tmp(:,2) tmp(:,3) sin(tmp(:,4))...
     tmp(:,2).*sin(tmp(:,4)) insolation(:)];
% without the sin
insol_data2 = [tmp(:,2) tmp(:,3) tmp(:,4)...
     insolation(:)];
 
ranges = zeros(2,5);

for i=1:5;
    ranges(:,i) = [min(data{i}) max(data{i})];
    plot(time,(data{i}-min(data{i}))/(max(data{i})-min(data{i}))+5-i,'Color',tmpcol{i},'LineWidth',3);
    hold on;
end

tmpxlab=xlabel('ky from J2000','fontsize',25,'verticalalignment','top','fontname','helvetica','interpreter','latex');
tmpylab=ylabel('$ \overline{Q}_{day}~~~~~~~~~~~~~~~~~~~~~~~~\sin (\overline{\omega})~~~~~~~~~~~~~~~~~~~~~~~~~$ e','fontsize',25,'verticalalignment','bottom','fontname','helvetica','interpreter','latex');

% disp(get(tmpxlab,'position'))
% 
set(tmpxlab,'position',get(tmpxlab,'position') - [0 .15 0]); % [x y 0]
set(tmpylab,'position',get(tmpylab,'position') + [.08 0 0]);

%set(gca,'xtick',months_cum_rank)
%month_names={'J','F','M','A','M','J','J','A','S','O','N','D'};
%set(gca,'xticklabel',month_names)

ylim([-0.2 5.1])
set(gca,'ytick',[0 .5 1 2 2.5 3 4 4.5 5]);
tmptmp = {'433' ''  '562' '-1' '' '1' '.004' '' '.057'};
set(gca,'yticklabel',tmptmp,'fontsize',16,'fontname','helvetica');

set(gca,'fontsize',16);
set(gca,'color','none');
set(gca,'Box','off');
axesPosition = get(gca,'Position');  
hNewAxes = axes('Position',axesPosition,...  %# Place a new axes on top...
                'Color','none',...           %#   ... with no background color
                'YLim',[-0.5 5.3],...            %#   ... and a different scale
                'YAxisLocation','right',...
                'Ytick',[1 1.5 2 3 3.5 4],...%#   ... located on the right
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
tmptmp = {'-.05' '' '.05' '.38' '' '.42'};
set(gca,'yticklabel',tmptmp,'fontsize',16,'fontname','helvetica');

tmpylab=ylabel('$\epsilon ~~~~~~~~~~~~~~~~~~~~~~~~ e \sin (\overline{\omega})$','fontsize',25,'verticalalignment','bottom','fontname','helvetica','interpreter','latex','rot',-90);
set(tmpylab,'position',get(tmpylab,'position') + [-0.02 -.01 0]);

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