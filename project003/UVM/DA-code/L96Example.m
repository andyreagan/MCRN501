function L96Example(i,j,F)
if nargin<3
	% default to a chaotic choice.

	i=10;% number of slow osc.
	j=5;% number of fast osc. per slow osc.
	F=14;% Forcing parameter. 
end;
global I J;
I=i;
J=j;
parameters=[1,10,10,F]; % parameters=[h,c,b,F]; 
			% h tunes influence of fast osc. on slow osc.
			% c & b are coupling parameters indicating 
			%     the difference in time scale between
			%     fast and slow osc.
timeStep=.001;%  small time step required to avoid divergence.


traj=zeros(5*10^4,I+(I*J));
traj(1,:)=rand(1,size(traj,2));

%% Spin up to approach attractor.
for t=1:10^4
	traj(1,:)=rk4(@L96,t,traj(1,:),parameters,timeStep);
end;
disp('Spin Up Complete.');

%% capture trajectory near the attractor
for t=2:size(traj,1)
	traj(t,:)=rk4(@L96,t,traj(t-1,:),parameters,timeStep);
end;

figure;
plot3(traj(:,1),traj(:,2),traj(:,3));grid on;
xlabel('X_1');ylabel('X_2');zlabel('X_3');

if I>=3
	figure;
	for i=1:3
		subplot(3,1,i);
		plot(timeStep*[1:size(traj,1)],traj(:,i));
		ylabel(['X_',num2str(i)]);
	end;
	xlabel('Time');
end;
end
