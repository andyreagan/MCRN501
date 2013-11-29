% run_filter.m
%
% test parameter estimation of data assimilation
%
% Andy Reagan
% 2013-11-23

clear all
close all
addpath(genpath('/Users/andyreagan/work/2013/2013-05data-assimilation/src'))
addpath(genpath('/users/a/r/areagan/work/2013/data-assimilation/src'))

%% fixed
dim = 6;
tStep = 0.01;

%% tunable parameters
numRuns = checkenv('NUMRUNS',1);
runTime = checkenv('RUNTIME',50); %  model units

%% part of experiment
obs_error_std = checkenv('OBSERROR',0.05);
obs_error_type = checkenv('OBSERRORDIST','normal');
windowAlpha = checkenv('SUBSAMPLEALPHA',1); 
rho = checkenv('RHO',28);
obsVarLen = checkenv('OBSVAR',3);
obsVar = 1:obsVarLen;

%% set things based off of this
windowLen = windowAlpha*tStep;
modelname = 'lorenz63';
params = {8/3,10,rho};

%% build observation operator
H = zeros(length(obsVar),dim);
H(obsVar,obsVar) = eye(length(obsVar));
R = obs_error_std*eye(length(obsVar));

%% initialize storage
num_windows = ceil(runTime/windowLen);
truth_vec = repmat(zeros(dim,num_windows+1),1,numRuns);

%%  make a truth run
truthmodel = lorenz63();
truthmodel.params = params;
truthmodel.init();
truthmodel.window = windowLen;
%% save the IC
tmp_truth_vec(1:3,1) = truthmodel.x;
%% generate the truth x timeseries
for j=1:num_windows
	truthmodel.run()
	tmp_truth_vec(1:3,j+1) = truthmodel.x;
end
truth_vec(1:3,1) = tmp_truth_vec(1:3,1);
truth_vec(1:3,2:end) = repmat(tmp_truth_vec(:,2:end),1,numRuns);
%% fill in the truth parameters
truth_vec(4:6,:) = repmat([params{1};params{2};params{3}],1,length(truth_vec(1,:)));

%% pass all of the observations, including time 0
switch obs_error_type
  case 'normal'
    obs_pert = truth_vec(obsVar,:) + obs_error_std*randn(size(truth_vec(obsVar,:)));
  case 'uniform'
    obs_pert = truth_vec(obsVar,:) + obs_error_std*rand(size(truth_vec(obsVar,:))) - obs_error_std/2*ones(size(truth_vec(obsVar,:)));
end

[EKF_f_vec,EKF_a_vec] = modelDAinterface(@lorenz63_paramEst,'EKF',obs_pert,0:windowLen:(runTime*numRuns),H,R,windowLen,0,0);
%% [ETKF_f_vec,ETKF_a_vec] = modelDAinterface(@lorenz63_paramEst,'ETKF',obs_pert,0:windowLen:(runTime*numRuns),H,R,windowLen,0,0); 
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
