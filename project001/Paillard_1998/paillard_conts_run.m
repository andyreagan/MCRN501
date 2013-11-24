% Implementation of Continous State Model in 
% Paillard's 1998 Letter to Nature:
% Paillard,D. "The Timing of Pleistocene Glaciations from a Simple Multiple
% State Climate Model." Nature. 391. 1/22/1998.
%
% The model allows an ice volume to vary continuously between regimes:
% i = interglacial
% g = moderate glaciation
% G = full glaciation
%
% according to the ordinary differential equation
%
% dv/dt = (v_R-v)/tau_R - F/tau_F
%
% where R is i, g, or G, and F is the "truncated" insolation taken from
% Bergers data at 65 deg N in July (NCDC, 1992) and truncated by 
% f(x)=x+sqrt(a+x^2).
%
% The ice regime is determined by three thresholds which give the following
% transitions:
% i-g: insolation drops below i_0
% g-G: ice volume reaches v_max
% G-i: insolation exceeds i_1
%
% The states are 
% i = 0
% g = 0.5
% G = 1
%
% The results are compared against an isotope record detailed in Bassinot
% et al (NCDC, 1994) (Bassinot.txt).
%------------------------------------------------------------------------

clear

%Initialize Arrays
v=zeros(900,1);
state = zeros(900,1);

%Load Parameter File

paillard_parameters

%Read in insolation data and normalize it to zero mean, unit variance

A = dlmread('ins_65N_July.txt');

%Use only last 1 million years

time = A(1:901,1);
insolation = A(1:901,2);

%Truncate Using Truncation Function

insolation = truncation_f(insolation,a);

%Subtract Mean and normalize Var to 1

insolation = (insolation-mean(insolation))/sqrt(var(insolation));

%Initial Condition for Ice Regimes
state(1)=1;
v(1)=0.75;
for i=2:901
    switch state(i-1)
        case(0)
             if (insolation(i)<i_0)
                state(i)=1;
                v_current = v_g;
                tau_current = tau_g;
            else
                state(i)=0;
                v_current = v_i;
                tau_current = tau_i;
             end
        case(1)
            if (v(i-1)>=v_max)
                state(i)=2;
                v_current = v_capg;
                tau_current = tau_capg;
            else
                state(i)=1;
                v_current = v_g;
                tau_current = tau_g;
            end
        case(2)
            if (insolation(i)>i_1)
                state(i)=0;
                v_current = v_i;
                tau_current = tau_i;
            else
                state(i)=2;
                v_current = v_capg;
                tau_current = tau_capg;
            end
    end
    v(i)=v(i-1)+(v_current-v(i-1))/tau_current-insolation(i)/tau_F;    
end

y=zeros(901,1);
vol=zeros(901,1);
for i=1:901
    y(i)=state(901-i+1)/2;
    vol(i)=v(901-i+1);
end

%Read in Oxygen Isotope Data from Bassinot, et al 1994

A = dlmread('bassinot.txt');

isotope_time = A(:,1);
isotope = A(:,2);

hold on
%Panel Plot of Insolation, Model Prediction, and Oxygen Isotope Stacks
subplot(3,1,1); 
plot(-time,insolation)
title('Insolation (Normalized)')
axis([0 900 -3 3])
subplot(3,1,2); 
plot(-time,y,'-');plot(-time,vol)
get(gca);
set(gca,'Xdir','default','Ydir','reverse')
title('Ice Volume')
axis([0 900 -0.3 1.3])
subplot(3,1,3); plot(isotope_time,isotope)
get(gca);
set(gca,'Xdir','default', 'YDir', 'reverse')
axis([0 900 -3 3])
title('Oxygen Isotope Stack')
hold off            