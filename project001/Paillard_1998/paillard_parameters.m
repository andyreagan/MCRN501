%Parameters for Models from Paillard's 1998 Letter to Nature:
%Paillard,D. "The Timing of Pleistocene Glaciations from a Simple Multiple
%State Climate Model." Nature. 391. 1/22/1998.
%
%   i_0: initiates i-g transition
%   i_1: initiates G-i transition
%   i_2: initiates g-G transition
%   i_3: constrains g-G transition (only if insolation remains < i_3)
%   t_g: time required for ice volume to grow to v_max and initiate g-G
%   tau_capg: time scale for state G
%   tau_g: time scale for state g
%   tau_i: time scale for state i   
%   tau_F: time scale for smoothed insolation forcing
%   v_max: sufficient ice volume to trigger g-G (implied)
%   v_capg: ice volume in state G
%   v_g: ice volume in state g
%   v_i: ice volume in state i
%   a: parameter for insolation truncation
%
%-------------------------------------------------------------------------

%Insolations are in terms of variances
i_0 = -0.75;
i_1 = 0.;
i_2 = 0.;
i_3 = 1.;

%Ice volumes (normalized)
v_capg = 1;
v_g = 1;
v_i = 0;
v_max = 1;

%Time Constants
t_g = 33; %kyr
tau_capg = 50;
tau_g = 50;
tau_i = 10;
tau_F = 25;

%Insolation truncation parameter
a=1;
