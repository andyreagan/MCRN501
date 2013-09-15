% run_model.m
%
% run model

% load the insolation data as insol_data
load ../data/insolation/INSOLN.LA2004.BTL.mat

% renormalize the insolation data to zero mean and unit variance
insol_data(:,6) = insol_data(:,6)-mean(insol_data(:,6)); % zero mean
insol_data(:,6) = insol_data(:,6)/std(insol_data(:,6)); % unit variance

start_time = -900; % kYr
tstep = 1; % timestep of our insolation data

initial_state = 'G';

% initialize all of the model variables (constructor...)
curr_state = initial_state;
curr_state_time = 0;
tipI3flag = 0;
params = {-0.75,0,0,1,33}; % {i0,i1,i2,i3,t_g}; % paillard {-0.75,0,0,1,33}

% to save the data (for plotting)
state_vec = zeros(abs(start_time),1);

count = 0; % keep track of iterations
for time = start_time:tstep:0
    count = count + 1; % ++
    insol = insol_data(-time+1,6); % load data
    
    [curr_state,curr_state_time,tipI3flag] = paillard_discrete(curr_state,insol,curr_state_time,tstep,tipI3flag,params);

    % save the states
    switch curr_state
        case 'i'
            state_vec(count) = 1;
        case 'g'
            state_vec(count) = 0;
        case 'G'
            state_vec(count) = -1;
    end
    
end

tmpfigh = gcf;
clf;
figshape(800,800);
tmpfilename = 'discrete_plot';
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
tmpcol = {'b','g',[101 45 93]/255,'r','k','m'};

positions(1).box = [.2 .2 .7 .7];
axesnum = 1;
tmpaxes(axesnum) = axes('position',positions(axesnum).box);

plot(start_time:tstep:0,state_vec,'Color',tmpcol{1},'LineWidth',3)
hold on;
ylim([-1.2 6])
shift = 3.5;
set(gca,'ytick',[-1 0 1 shift-1 shift shift+1])
set(gca,'yticklabel',{'G','g','i',-1,'',1})

line(1) = plot(fliplr(insol_data(1:-start_time,1)),params{4}.*ones(length(1:-start_time),1)+shift,'b--','LineWidth',1.1);
line(2) = plot(fliplr(insol_data(1:-start_time,1)),params{1}.*ones(length(1:-start_time),1)+shift,'r--','LineWidth',1.2);
plot(fliplr(insol_data(1:-start_time,1)),fliplr(insol_data(1:-start_time,6))+shift,'Color',tmpcol{2},'LineWidth',3);
legend(line,{'i_3','i_0'});



tmpxlab=xlabel('ky from J2000','fontsize',25,'verticalalignment','top','fontname','helvetica','interpreter','latex');
tmpylab=ylabel('Model State $~~~~~~~$Normalized Insolation','fontsize',25,'verticalalignment','bottom','fontname','helvetica','interpreter','latex');

% disp(get(tmpxlab,'position'))
% 
set(tmpxlab,'position',get(tmpxlab,'position') - [0 .15 0]); % [x y 0]
set(tmpylab,'position',get(tmpylab,'position') + [-20 -.5 0]);

set(gca,'fontsize',15);

psprintcpdf_keeppostscript(tmpfilenoname);
tmpcommand = sprintf('open %s.pdf;',tmpfilenoname);
system(tmpcommand);
