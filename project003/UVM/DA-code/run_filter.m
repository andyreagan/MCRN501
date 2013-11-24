% run_filter.m
%
% test parameter estimation of data assimilation
%
% Andy Reagan
% 2013-11-23

clear all
close all
addpath(genpath('/Users/andyreagan/work/2013/2013-05data-assimilation/src'))

%% fixed
dim = 6;

%% tunable parameters
numRuns = 1;
obs_error_std = 0.05;
runTime = 50; %  model units
window = .5; %  window
modelname = 'lorenz63';
params = {8/3,10,28};
obsVar = 1:3;

%% build observation operator
H = zeros(length(obsVar),dim);
H(obsVar,obsVar) = eye(length(obsVar));
R = obs_error_std*eye(length(obsVar));

%% initialize storage
num_windows = ceil(runTime/window);
truth_vec = repmat(zeros(dim,num_windows+1),1,numRuns);

%%  make a truth run
truthmodel = lorenz63();
truthmodel.params = params;
truthmodel.init();
truthmodel.window = window;
% save the IC because I've give the DA,noDA runs good IC?
tmp_truth_vec(1:3,1) = truthmodel.x;
% generate the truth x timeseries
for j=1:num_windows
	truthmodel.run()
	tmp_truth_vec(1:3,j+1) = truthmodel.x;
end
truth_vec(1:3,1) = tmp_truth_vec(1:3,1);
truth_vec(1:3,2:end) = repmat(tmp_truth_vec(:,2:end),1,numRuns);
% fill in the truth parameters
truth_vec(4:6,:) = repmat([params{1};params{2};params{3}],1,length(truth_vec(1,:)));

% pass all of the observations, including time 0
obs_pert = truth_vec(obsVar,:) + obs_error_std*randn(size(truth_vec(obsVar,:)));
[EKF_f_vec,EKF_a_vec] = modelDAinterface(@lorenz63_paramEst,'EKF',obs_pert,0:window:(runTime*numRuns),H,R,window,0,0);
[ETKF_f_vec,ETKF_a_vec] = modelDAinterface(@lorenz63_paramEst,'ETKF',obs_pert,0:window:(runTime*numRuns),H,R,window,0,0); 
fprintf('initial parameters\n')
disp(EKF_f_vec(:,1))

fprintf('end of the truth\n')
disp(truth_vec(:,end-10:end))

fprintf('end of the EKF forecast\n')
disp(EKF_f_vec(:,end-10:end))

fprintf('end of the ETKF forecast\n')
disp(ETKF_f_vec(:,end-10:end))

fprintf('forecast errors of EKF\n')
disp(std(EKF_f_vec(1,floor(length(EKF_f_vec(1,:))/2):end)-truth_vec(1,floor(length(EKF_f_vec(1,:))/2):end)))

fprintf('analysis errors of EKF\n')
disp(std(EKF_a_vec(1,floor(length(EKF_a_vec(1,:))/2):end)-truth_vec(1,floor(length(EKF_a_vec(1,:))/2):end)))

fprintf('forecast errors of ETKF\n')
disp(std(ETKF_f_vec(1,floor(length(ETKF_f_vec(1,:))/2):end)-truth_vec(1,floor(length(ETKF_f_vec(1,:))/2):end)))

fprintf('analysis errors of ETKF\n')
disp(std(ETKF_a_vec(1,floor(length(ETKF_a_vec(1,:))/2):end)-truth_vec(1,floor(length(ETKF_a_vec(1,:))/2):end)))



% compute the running RMS error of each of those forecasts
for j=1:num_windows+1
	% for each variable
	for k=1:dim
		%errors_DA(k,j) = errors_DA(k,j)+rmse(truth_vec(k,1:j),ETKF_f_vec(k,1:j));
		%errors_direct(k,j) = errors_direct(k,j)+rmse(truth_vec(k,1:j),direct_f_vec(k,1:j));
		%errors_none(k,j) = errors_none(k,j)+rmse(truth_vec(k,1:j),none_f_vec(k,1:j));
	end
end

% correct for number of runs
% errors_DA = errors_DA./numRuns;
% errors_direct = errors_direct./numRuns;
% errors_none = errors_none./numRuns;

%% plot it

% figure;
% 
% set(gcf,'DefaultAxesFontname','helvetica');
% set(gcf,'DefaultLineColor','r');
% set(gcf,'DefaultLineMarkerSize',5);
% set(gcf,'DefaultLineMarkerEdgeColor','k');
% set(gcf,'DefaultLineMarkerFaceColor','g');
% set(gcf,'DefaultAxesLineWidth',0.5);
% set(gcf,'PaperPositionMode','auto');
% 
% tmpsym = {'o','s','v','o','s','v'};
% tmpcol = {'g','b','r','k','c','m'};
% 
% % plot grey lines
% plot(0:window:runTime,errors_DA(1,:),'Color',0.7*[1 1 1]);
% hold on;
% %plot(0:window:runTime,errors_direct(1,:),'Color',0.7*[1 1 1]);
% plot(0:window:runTime,errors_none(1,:),'Color',0.7*[1 1 1]);
% 
% % plot some marks
% i=2;
% tmph(i) = plot(0:window:runTime,errors_DA(1,:),'Marker',tmpsym{4},'MarkerFaceColor',tmpcol{4},'LineStyle','none');
% legendcell{i} = 'ETKF';
% i=1;
% tmph(i) = plot(0:window:runTime,errors_none(1,:),'Marker',tmpsym{5},'MarkerFaceColor',tmpcol{5},'LineStyle','none');
% legendcell{i} = 'No Obs';
% i=3;
% %tmph(i) = plot(0:window:runTime,errors_none(1,:),'Marker',tmpsym{i},'MarkerFaceColor',tmpcol{i},'LineStyle','none');
% 
% %
% tmpxlab=xlabel('Time $t$', ...
% 	'fontsize',30,'verticalalignment','top','fontname','helvetica','interpreter','latex');
% %set(tmpxlab,'position',get(tmpxlab,'position') - [0 .07 0]);
% 
% tmpylab=ylabel('RMS Error $\epsilon$','fontsize',30,'verticalalignment','bottom','fontname','helvetica','interpreter','latex');
% %set(tmpylab,'position',get(tmpylab,'position') + [.05 4 0]);
% 
% tmplh = legend(tmph,legendcell,'location','northeast'); %,'No Obs'
% set(tmplh,'position',get(tmplh,'position')+[-.1 -0.3 0 0])
% % change font
% tmplh = findobj(tmplh,'type','text');
% set(tmplh,'FontSize',30);
% % remove box:
% legend boxoff
% 
% %xlim([0 25]);
% 
% %psprintcpdf_keeppostscript('DA_test_noname011');
% 
% %xlim([0 70]);
% 
% %psprintcpdf_keeppostscript('DA_test_noname006');
