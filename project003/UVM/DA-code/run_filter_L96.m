function [] = run_filter_L96()
% run_filter.m
%
% test parameter estimation of data assimilation
%
% Andy Reagan
% 2013-11-23

clear all
close all
%% ADDPATH does not play nice with the MCC compiler
if (~isdeployed)
  addpath(genpath('/Users/andyreagan/work/2013/2013-05data-assimilation/src'))
  addpath(genpath('/users/a/r/areagan/work/2013/data-assimilation/src'))
end

%% fixed
dim = 6;
tStep = 0.001;

%% tunable parameters
numRuns = checkenv('NUMRUNS',1);
runTime = checkenv('RUNTIME',50); %  model units

%% part of experiment
obs_error_std = checkenv('OBSERROR',0.05);
obs_error_type = checkenv('ERRORDIST','normal');
windowAlpha = checkenv('SUBSAMPLEALPHA',1); 
I = checkenv('DIMENSION',3);
expCount = checkenv('EXPCOUNT',1);

fprintf('save file is\n');
fprintf('data/L96_%s_%g_%g_%g_%g_%g_%g_forecastEnds.csv\n',obs_error_type,obs_error_std,numRuns,runTime,windowAlpha,I,expCount);

%% set things based off of this
windowLen = windowAlpha*tStep;
modelname = 'lorenz96_paramEst';

%% build observation operator
H = zeros(length(obsVar),dim);
H(obsVar,obsVar) = eye(length(obsVar));
R = obs_error_std*eye(length(obsVar));

%% initialize storage
num_windows = ceil(runTime/windowLen);
%%truth_vec = repmat(zeros(dim,num_windows+1),1,numRuns);
%% meaning of numRuns is not bootstrapping, but sampling IC now
truth_vec = ones(dim,num_windows+1);

%%  make a truth run
truthmodel = str2func(modelname);
truthmodel.I = I;
truthmodel.init();
truthmodel.window = windowLen;
%% save the IC
truth_vec = ones(I*5+4,num_windows+1); %J is fixed at 4
truth_vec(:,1) = truthmodel.x;
%% generate the truth x timeseries
for j=1:num_windows
	truthmodel.run()
	truth_vec(:,j+1) = truthmodel.x;
end

%% pass all of the observations, including time 0
switch obs_error_type
  case 'normal'
    obs_pert = truth_vec(obsVar,:) + obs_error_std*randn(size(truth_vec(obsVar,:)));
  case 'uniform'
    obs_pert = truth_vec(obsVar,:) + obs_error_std*rand(size(truth_vec(obsVar,:))) - obs_error_std/2*ones(size(truth_vec(obsVar,:)));
end

%% for running one of them, looking at the results
%% [EKF_f_vec,EKF_a_vec] = modelDAinterface(@lorenz63_paramEst,'EKF',obs_pert,0:windowLen:(runTime*numRuns),H,R,windowLen,0,0);
%% [ETKF_f_vec,ETKF_a_vec] = modelDAinterface(@lorenz63_paramEst,'ETKF',obs_pert,0:windowLen:(runTime*numRuns),H,R,windowLen,0,0); 

%% fprintf('initial parameters\n'); disp(EKF_f_vec(:,1))
%% fprintf('end of the truth\n'); disp(truth_vec(:,end-10:end))
%% fprintf('end of the EKF forecast\n'); disp(EKF_f_vec(:,end-10:end))
%% fprintf('end of the ETKF forecast\n'); disp(ETKF_f_vec(:,end-10:end))
%% fprintf('forecast errors of EKF\n'); disp(std(EKF_f_vec(1,floor(length(EKF_f_vec(1,:))/2):end)-truth_vec(1,floor(length(EKF_f_vec(1,:))/2):end)))
%% fprintf('analysis errors of EKF\n'); disp(std(EKF_a_vec(1,floor(length(EKF_a_vec(1,:))/2):end)-truth_vec(1,floor(length(EKF_a_vec(1,:))/2):end)))
%% fprintf('forecast errors of ETKF\n'); disp(std(ETKF_f_vec(1,floor(length(ETKF_f_vec(1,:))/2):end)-truth_vec(1,floor(length(ETKF_f_vec(1,:))/2):end)))
%% fprintf('analysis errors of ETKF\n'); disp(std(ETKF_a_vec(1,floor(length(ETKF_a_vec(1,:))/2):end)-truth_vec(1,floor(length(ETKF_a_vec(1,:))/2):end)))

%% store many runs (this will be output). first entry is truth
allForecasts = ones(dim,numRuns+1);
allForecasts(:,1) = truth_vec(:,end);
allAnalyses = allForecasts;

%% now run a lot of them
for i=1:numRuns
  fprintf('on numRun %g\n',i);
  [tmp_EKF_f_vec,tmp_EKF_a_vec] = modelDAinterface(@lorenz63_paramEst,'EKF',obs_pert,0:windowLen:runTime,H,R,windowLen,0,0);
  allForecasts(:,i+1) = tmp_EKF_f_vec(:,end);
  allAnalyses(:,i+1) = tmp_EKF_a_vec(:,end);
end

%% save all of the end
%% forecasts
csvwrite(sprintf('data/%s_%g_%g_%g_%g_%g_%g_%g_forecastEnds.csv',obs_error_type,obs_error_std,numRuns,runTime,windowAlpha,rho,obsVarLen,expCount),allForecasts);
csvwrite(sprintf('data/%s_%g_%g_%g_%g_%g_%g_%g_analysisEnds.csv',obs_error_type,obs_error_std,numRuns,runTime,windowAlpha,rho,obsVarLen,expCount),allAnalyses);

fprintf('success\n');





