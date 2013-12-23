function [] = checkModel()

clear all
close all
test = lorenz96_paramEst();
test.init();

windowLen = .005;
test.window = windowLen;
runTime = 1;
numSaves = floor(runTime/windowLen)+1;
savedStates = zeros(test.I*(test.J+1),numSaves);
savedStates(:,1) = test.x(1:end-4);
for i=1:numSaves    
    test.run()
    savedStates(:,i+1) = test.x(1:end-4);
end

%%
% look at the 1st slow oscillator
plot(1:length(savedStates(1,:)),savedStates(15,:));
figure
plot(1:length(savedStates(1,1:100)),savedStates(15,1:100));


state = rand(54,1);
params = {10,4};
tic;
new = lorenz96_model_new(0,state,params);
toc;
tic;
old = lorenz96_model_old(0,state,params);
toc;
disp(new);
disp(new-old);

end

function dstate=lorenz96_model_new(~,state,params)
I = params{1};
J = params{2};
h=state(end-3);b=state(end-2);c=state(end-1);F=state(end);
% morgan's reshape [ fast, it's slow; fast, it's slow ...]
state=reshape(state(1:end-4),I,J+1);

X=state(:,1); % just the fast guys

% RHS for X_k, as a column vector
state(:,1)=X(mod(-1:I-2,I)+1).*(X(mod(1:I,I)+1)-X(mod(-2:I-3,I)+1))-X+F*ones(I,1)-...
    (h*c/b)*sum(state(:,2:end),2);

% turn all of the slow guys into a row vector,
% and a row vector of their corresponding X below it
IJ=I*J;
Ys=reshape(state(:,2:end)',1,IJ);
Xs=reshape(ones(I,J)'*diag(X),1,IJ);

Ys=-c*b*Ys(mod(1:IJ,IJ)+1).*(Ys(mod(2:IJ+1,IJ)+1)-Ys(mod(-1:IJ-2,IJ)+1))...
    -c*Ys+(h*c/b)*Xs;

state(:,2:end)=reshape(Ys,J,I)';

dstate=[reshape(state,numel(state),1);(0*(1:4))'];
end

function dstate=lorenz96_model_old(~,state,params)
I = params{1};
J = params{2};
h=state(end-3);b=state(end-2);c=state(end-1);F=state(end);
% morgan's reshape [ fast, it's slow; fast, it's slow ...]
state=reshape(state(1:end-4),I,J+1);

X=state(:,1); % just the fast guys

% RHS for X_k, as a column vector
state(:,1)=X(mod(-1:I-2,I)+1).*(X(mod(1:I,I)+1)-X(mod(-2:I-3,I)+1))-X+F*ones(I,1)-...
    (h*c/b)*sum(state(:,2:end),2);

% turn all of the slow guys into a row vector,
% and a row vector of their corresponding X below it
IJ=I*J;
Ys=zeros(1,IJ);
Xs=zeros(1,IJ);
% Ys is the outer ring of fast oscillators
for i=1:I
    Ys((i-1)*J+1:i*J)=state(i,2:end);
    Xs((i-1)*J+1:i*J)=X(i,1)*ones(1,J);
end;

Ys=-c*b*Ys(mod(1:IJ,IJ)+1).*(Ys(mod(2:IJ+1,IJ)+1)-Ys(mod(-1:IJ-2,IJ)+1))...
    -c*Ys+(h*c/b)*Xs;

for i=1:I
    state(i,2:end)=Ys((i-1)*J+1:i*J);
end;

dstate=[reshape(state,numel(state),1);(0*(1:4))'];
end