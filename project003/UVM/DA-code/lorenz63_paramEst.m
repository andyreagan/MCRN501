classdef lorenz63_paramEst<handle
	%lorenz63: class for a lorenz63 run
	%   Goal is to implement a class for which MATLAB can
	%   control and run the lorenz63 model
	%
	%   Additionally, this is a 6 dimensional system, including params
	%
	%   USAGE:
	%       -initialize the model with a climatological IC
	%        ens1 = lorenz63();
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
		tstep = .01;
		dim = 6;
		time = 0;
		window = 20;
		
		params = {};
		%for the TLM
		%this code only works for rk2prime...
		TLMmethod = 'rk2prime'; % 'kam','explicit'
		p_f
		DIR
	end % properties
	methods
		function self = lorenz63(varargin)
			%intialize the class
		end %constructor
		function init(self,varargin)
			self.x = 10*randn(self.dim,1);
			self.x(4:6) = [10 0 0;0 20 0; 0 0 40]*rand(3,1); %3*randn(3,1)+[8/3;10;28];
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
			
			[~,tmp_x_f] = rk2(@lorenz63_model,self.params,self.time+[0,self.window],self.x,self.tstep);
			self.x = tmp_x_f(end,:)';
			self.time = self.time+self.window;
			%fprintf('done\n');
		end %run
		function runTLM(self,p_a,varargin) % ALWAYS RUN THIS BEFORE self.run()!!
			%fprintf('running the TLM...');
			% right now, load this straight from the EKF
			self.p_f = lorenz63_TLM(self.TLMmethod,self.time,self.window,self.x,self.tstep,p_a,self.params);
			% don't update time...
			%self.time = self.time+self.window;
			%fprintf('done\n');
		end %runTLM
	end % methods
end % classdef

function [xprime] = lorenz63_model(~,x,~)
% the Lorenz '63 system, as a function
%
% INPUT
%   t  - time, scalar
%   y  - column vector solution

b = x(4); s = x(5); r = x(6);
xprime = [s*(x(2)-x(1));r*x(1)-x(2)-x(1)*x(3);x(1)*x(2)-b*x(3);0;0;0];

end


function [p_f] = lorenz63_TLM(method,t,window_len,x_a,tstep,p_a,params)

switch method
	case 'rk2prime'
		%%%%%%%%%%%%%%%%%
		%% rk2 prime method
		
		% integrate the foward model
		[~,~,L] = rk2prime(@lorenz63_model,@lorenzJ_paramEst,params,[t t+window_len],x_a,tstep);
		
		% error covariance from model
		p_f = L*p_a*L';
		
	case 'kam'
		%%%%%%%%%%%%%%%%%%%%%%
		%% method from Kam's paper
		
		% compute the Jacobian of Lorenz 63
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

% the Lorenz '63 system, as a function
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
