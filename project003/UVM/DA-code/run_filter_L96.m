% function [] = run_filter_L96()
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



%% tunable parameters
numRuns = checkenv('NUMRUNS',1);
runTime = checkenv('RUNTIME',50); %  model units

%% part of experiment
obs_error_std = checkenv('OBSERROR',0.05);
obs_error_type = checkenv('ERRORDIST','normal');
windowAlpha = checkenv('SUBSAMPLEALPHA',1); 
I = checkenv('DIMENSION',4);
expCount = checkenv('EXPCOUNT',1);

%% fixed
J = 4;
dim = I*(J+1)+4;
tStep = 0.001;

fprintf('save file is\n');
fprintf('data/L96_%s_%g_%g_%g_%g_%g_%g_forecastEnds.csv\n',obs_error_type,obs_error_std,numRuns,runTime,windowAlpha,I,expCount);

%% set things based off of this
windowLen = windowAlpha*tStep;
modelname = 'lorenz96_paramEst';

%% build observation operator
H = zeros(dim-4,dim);
H(1:dim-4,1:dim-4) = eye(dim-4);
R = (obs_error_std+.001)*eye(dim-4);

%% initialize storage
num_windows = ceil(runTime/windowLen);
%%truth_vec = repmat(zeros(dim,num_windows+1),1,numRuns);
%% meaning of numRuns is not bootstrapping, but sampling IC now
truth_vec = ones(dim,num_windows+1);

%%  make a truth run
% truthmodel = str2func(modelname);
truthmodel = lorenz96_paramEst();
truthmodel.I = I;
truthmodel.init();
truthmodel.window = windowLen;
%% save the IC
truth_vec = ones((I+1)*J+4,num_windows+1); %J is fixed at 4
truth_vec(:,1) = truthmodel.x;
%% generate the truth x timeseries
for j=1:num_windows
	truthmodel.run()
	truth_vec(:,j+1) = truthmodel.x;
end

%% pass all of the observations, including time 0
switch obs_error_type
  case 'normal'
    obs_pert = truth_vec(1:end-4,:) + obs_error_std*randn(size(truth_vec(1:end-4,:)));
  case 'uniform'
    obs_pert = truth_vec(1:end-4,:) + obs_error_std*rand(size(truth_vec(1:end-4,:))) - obs_error_std/2*ones(size(truth_vec(1:end-4,:)));
end

%% store many runs (this will be output). first entry is truth
allForecasts = ones(dim,numRuns+1);
allForecasts(:,1) = truth_vec(:,end);
allAnalyses = allForecasts;

%% save the RMS skill of forecasts
forecastRMSSkill = zeros(1,numRuns);

%% now run a lot of them
for i=1:numRuns
  fprintf('on numRun %g\n',i);
  [tmp_EKF_f_vec,tmp_EKF_a_vec] = modelDAinterface(@lorenz96_paramEst,'EKF',obs_pert,0:windowLen:runTime,H,R,windowLen,0,0);
  allForecasts(:,i+1) = tmp_EKF_f_vec(:,end);
  allAnalyses(:,i+1) = tmp_EKF_a_vec(:,end);
  %% specifically, computing the RMSE of the the last five timesteps of prediction
  %% with the last five timesteps of observations
  %% this gives 5 RMSE values. then I'm averaging those
  forecastRMSSkill(i) = mean(sqrt(mean((tmp_EKF_a_vec(1:end-4,end-4:end)-obs_pert(:,end-4:end)).^2,1)));
end

%% find the best forecast
bestInd = find(forecastRMSSkill==min(forecastRMSSkill),1);

%% save all of the end
%% forecasts
csvwrite(sprintf('data/L96_%s_%g_%g_%g_%g_%g_%g_forecastEnds.csv',obs_error_type,obs_error_std,numRuns,runTime,windowAlpha,I,expCount),allForecasts);
csvwrite(sprintf('data/L96_%s_%g_%g_%g_%g_%g_%g_analysisEnds.csv',obs_error_type,obs_error_std,numRuns,runTime,windowAlpha,I,expCount),allAnalyses);
csvwrite(sprintf('data/L96_%s_%g_%g_%g_%g_%g_%g_bestParams.csv',obs_error_type,obs_error_std,numRuns,runTime,windowAlpha,I,expCount),allAnalyses(end-3:end,bestInd+1));

fprintf('success\n');







