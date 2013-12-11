classdef lorenz96_paramEst<handle
	%lorenz96: class for a lorenz96 run
	%   Goal is to implement a class for which MATLAB can
	%   control and run the lorenz96 model
	%
	%   USAGE:
	%       -initialize the model with a climatological IC
	%        ens1 = lorenz96();
	%        ens1.init();
	%        OR with a name
	%        ens1.init('name')
	%        OR initialize with given IC (and name)
	%        ens1.init('name',[10.4;11.7;18.5]);
	%       -set the IC for the run to something specific
	%        ens1.x = [10.4;11.7;18.5];
	%       -run this case
	%        ens1.run();
	%       -run more into the future
	%        ens1.run();
	
	properties
		%basics
		x
		tstep = .001;
		dim = 20;
		time = 0;
		window = 20;
		
		params = {};
		%for the TLM
		%this code only works for rk2prime...
		TLMmethod = 'rk4prime'; % 'kam','explicit'
		p_f
		DIR
	end % properties
	methods
		function self = lorenz96(varargin)
			%intialize the class
		end %constructor
		function init(self,varargin)
			self.x = 10*randn(self.dim,1);
			self.x(4:6) = 100*eye(3)*rand(3,1); %3*randn(3,1)+[8/3;10;28]; %[10 0 0;0 20 0; 0 0 40]
			%fprintf('initializing...');
			
			% ignore the first argument, if there is one
			if nargin > 2
				% setting given IC
				self.x = varargin{2};
			else
				% generating climatological IC
				tmpwindow = self.window; self.window = randi(100,1);
				tmptime = self.time; self.time = 0;
				self.x(1:3) = [-12.6480;-13.9758;30.9758]+.1*randn(3,1);
				self.run();
				self.window = tmpwindow;
				self.time = tmptime;
			end
			%fprintf('done\n');
		end %init
		function run(self,varargin)
			% run the case
			%fprintf('running...');
			
			[~,tmp_x_f] = rk4(@lorenz96_model,self.params,self.time+[0,self.window],self.x,self.tstep);
			self.x = tmp_x_f(end,:)';
			self.time = self.time+self.window;
			%fprintf('done\n');
		end %run
		function runTLM(self,p_a,varargin) % ALWAYS RUN THIS BEFORE self.run()!!
			%fprintf('running the TLM...');
			% right now, load this straight from the EKF
			self.p_f = lorenz96_TLM(self.TLMmethod,self.time,self.window,self.x,self.tstep,p_a,self.params);
			% don't update time...
			%self.time = self.time+self.window;
			%fprintf('done\n');
		end %runTLM
	end % methods
end % classdef

function dstate=lorenz96_model(~,state,~)
global I;global J;
h=state(end-3);c=state(end-2);b=state(end-1);F=state(end);
state=reshape(state(1:end-4),I,J+1);
IJ=I*J;

X=state(:,1);

state(:,1)=X(mod(-1:I-2,I)+1).*(X(mod(1:I,I)+1)-X(mod(-2:I-3,I)+1))-X+F*ones(I,1)-...
    (h*c/b)*sum(state(:,2:end),2);

IJ=I*J;
Ys=zeros(1,IJ);
Xs=zeros(1,IJ);
%Ys is the outer ring of fast oscillators
for i=1:I
    Ys((i-1)*J+1:i*J)=state(i,2:end);
    Xs((i-1)*J+1:i*J)=X(i,1)*ones(1,J);
end;

Ys=-c*b*Ys(mod(1:IJ,IJ)+1).*(Ys(mod(2:IJ+1,IJ)+1)-Ys(mod(-1:IJ-2,IJ)+1))...
    -c*Ys+(h*c/b)*Xs;

for i=1:I
    state(i,2:end)=Ys((i-1)*J+1:i*J);
end;

dstate=[reshape(state,numel(state)),1,0*(1:4)];
end


function [p_f] = lorenz96_TLM(method,t,window_len,x_a,tstep,p_a,params)

switch method
    case 'rk4prime'
		%%%%%%%%%%%%%%%%%
		%% rk4 prime method
		
		% integrate the foward model
		[~,~,L] = rk4prime(@lorenz96_model,@lorenzJ_paramEst,params,[t t+window_len],x_a,tstep);
		
		% error covariance from model
		p_f = L*p_a*L';
    
	case 'rk2prime'
		%%%%%%%%%%%%%%%%%
		%% rk2 prime method
		
		% integrate the foward model
		[~,~,L] = rk2prime(@lorenz96_model,@lorenzJ_paramEst,params,[t t+window_len],x_a,tstep);
		
		% error covariance from model
		p_f = L*p_a*L';
		
	case 'kam'
		%%%%%%%%%%%%%%%%%%%%%%
		%% method from Kam's paper
		
		% compute the Jacobian of Lorenz 96
		lorenzJac = @(y,params) [-params{2},params{2},0;-y(3)+params{3},-1,-y(1);y(2),y(1),-params{1}];
		J = lorenzJac(x_a,params);
		
		dim = length(x_a);
		p_f = ones(dim);
		for i=1:dim
			[~,tmp] = rk2(@(~,y,params) J*y,params,[t t+window_len],p_a(:,i),tstep);
			p_f(:,i) = tmp(end,:)';
		end
		
	case 'explicit'
		%%%%%%%%%%%%%%%%%%%%
		%% explicit RK2 derivative method
		
		% compute the LTM from the RK2 discretization of model directly
		[~,~,L] = lorenzRK2explicit([t t+window_len],x_a,tstep);
		
		% error covariance from model
		p_f = L*p_a*L';
end
end


function [J] = lorenzJ_paramEst(~,xvec,~)

% the Lorenz '96 system, as a function
%
% INPUT
%   t  - time, scalar
%   x_vec  - column vector solution
%   params  - cell array of parameters {b,s,r}

% make these human
%b = params(1); s = params(2); r = params(3);
b = xvec(4); s = xvec(5); r = xvec(6);
x = xvec(1); y = xvec(2); z = xvec(3);

% normal
J = [-s,s,0;-z+r,-1,-x;y,x,-b];
% with parameters
J = zeros(6);
J(1:3,:) = [-s s 0 0 y-x 0; r-z -1 -x 0 0 x; y x -b -z 0 0];

end
