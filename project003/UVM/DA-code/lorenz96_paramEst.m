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
		I = 10; % slow oscillators
		J = 4; % fast guys per slow
		dim % = self.I*(self.J+1)+4; % add the parameters h,b,c,F
		time = 0;
		window = 1;
		params = {};
		% for the TLM
		TLMmethod = 'rk4prime';
		p_f
		DIR
	end % properties
	methods
	    function test = lorenz96_paramEst(varargin)
		%intialize the class
	    end %constructor
	    function init(self,varargin)
                self.dim = self.I*(self.J+1)+4;
		self.params = {self.I,self.J};
		self.x = rand(self.dim,1);
		self.x(end-3:end) = 100*rand(4,1);
                self.x(end-3:end) = [1;10;10;14];
	        % ignore the first argument, if there is one
		if nargin > 2
		    % setting given IC
		    self.x = varargin{2};
		else
		    % generating climatological IC
				tmpwindow = self.window; self.window = randi(10,1);
				tmptime = self.time; self.time = 0;
				self.run();
				self.window = tmpwindow;
				self.time = tmptime;
            end % if
		end %init
		function run(self,varargin)
			% run the case
			%fprintf('running...');
			
			[~,tmp_x_f] = rk4(@lorenz96_model,self.params,self.time+[0,self.window],self.x,self.tstep);
			self.x = tmp_x_f(end,:)';
			self.time = self.time+self.window;
			%fprintf('done\n');
		end %run
		function runTLM(self,p_a,varargin) % ALWAYS RUN THIS BEFORE self.run()!!!
			self.p_f = lorenz96_TLM(self.TLMmethod,self.time,self.window,self.x,self.tstep,p_a,self.params);
		end %runTLM
	end % methods
end % classdef

function dstate=lorenz96_model(~,state,params)
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
% Ys=zeros(1,IJ);
% Xs=zeros(1,IJ);
% % Ys is the outer ring of fast oscillators
% for i=1:I
%     Ys((i-1)*J+1:i*J)=state(i,2:end);
%     Xs((i-1)*J+1:i*J)=X(i,1)*ones(1,J);
% end;

Ys=reshape(state(:,2:end)',1,IJ);
Xs=reshape(ones(I,J)'*diag(X),1,IJ);

Ys=-c*b*Ys(mod(1:IJ,IJ)+1).*(Ys(mod(2:IJ+1,IJ)+1)-Ys(mod(-1:IJ-2,IJ)+1))...
    -c*Ys+(h*c/b)*Xs;

state(:,2:end)=reshape(Ys,J,I)';
% for i=1:I
%     state(i,2:end)=Ys((i-1)*J+1:i*J);
% end;

dstate=[reshape(state,numel(state),1);(0*(1:4))'];
end


function [p_f] = lorenz96_TLM(method,t,window_len,x_a,tstep,p_a,params)

switch method
    case 'rk4prime'
		%%%%%%%%%%%%%%%%%
		%% rk4 prime method
		
		% integrate the foward model
		[~,~,L] = rk4prime(@lorenz96_model,@lorenz96J,params,[t t+window_len],x_a,tstep);
		
		% error covariance from model
		p_f = L*p_a*L';
    
	case 'rk2prime'
		%%%%%%%%%%%%%%%%%
		%% rk2 prime method
		
		% integrate the foward model
		[~,~,L] = rk2prime(@lorenz96_model,@lorenz96J,params,[t t+window_len],x_a,tstep);
		
		% error covariance from model
		p_f = L*p_a*L';
end
end


function [J] = lorenz96J(~,state,params)
% the Lorenz '96 system Jacobian
%
% INPUT
%   t  - time, scalar
%   x_vec  - column vector solution
%   params  - cell array of parameters {b,s,r}

% initialize
J = zeros(length(state));

% for L96
I = params{1};
J = params{2};
h=state(end-3);c=state(end-2);b=state(end-1);F=state(end);
state=reshape(state(1:end-4),I,J+1);

X=state(:,1);n
dim=I;
J=-1*eye(dim);
for i=1:dim
    J(i,myMod(i-2,dim))=-X(myMod(i-1,dim));
    J(i,myMod(i-1,dim))=X(myMod(i+1,dim))-X(myMod(i-2,dim));
    J(i,myMod(i+1,dim))=X(myMod(i-1,dim));
end;
end




