%Implementation of Steady Model in 
%Paillard's 1998 Letter to Nature:
%Paillard,D. "The Timing of Pleistocene Glaciations from a Simple Multiple
%State Climate Model." Nature. 391. 1/22/1998.
%
%The model allows three discrete states:
%i = interglacial
%g = moderate glaciation
%G = full glaciation
%
%with transitions being triggered by:
%i-g: insolation drops below threshold i_0
%g-G: ice volume exceeds threshold v_max
%G-i: insolation exceeds threshold i_1
%
%Note that no other transitions are allowed, and that the g-G transition
%only occurs if insolation remains below some maximum i_3 for some
%specified time t_g, and the transition occurs when insolation drops below
%i_2.
%
%Thus the model has parameter set i_0, i_1, i_2, i_3, t_g, and v_max.
%
%The results are compared to the isotope record pulled from ice cores,
%seeking agreement with major ice cover shifts from the record.
%
%Array "state" has entries that consist of
%  2 if state = i
%  1 if state = g
%  0 if state = G
%------------------------------------------------------------------------

clear

%Read in insolation data and normalize it to zero mean, unit variance

A = dlmread('ins_65N_July.txt');

%Use only last 1 million years

time = A(1:901,1);
insolation = A(1:901,2);

%Subtract Mean and normalize Var to 1

insolation = (insolation-mean(insolation))/sqrt(var(insolation));


%Initialize arrays
state=zeros(size(time));
state=state-9999;   %just to debug code

%Load Parameter File
paillard_parameters

%Initialize Model
state(1)=0;

for i=2:901
    switch state(i-1)
        case(0)
            if (insolation(i)>i_1)
                state(i)=2;
            else
                state(i)=0;
            end
        case(1)
            check=0;
            if (i>34)
                for j=i-34:i-1
                    if ((state(j)==1) && (insolation(j)<=i_3))
                        check = check;
                    else
                        check = check+1;
                    end
                end
                if ((check==0) && (insolation(i)<i_2))
                    state(i)=0;
                else
                    state(i)=1;
                end
            else
                state(i)=1;
            end
        case(2)
            if (insolation(i)<i_0)
                state(i)=1;
            else
                state(i)=2;
            end
        otherwise
            state(i) = 10;
    end
end
y=zeros(901,1);
for i=1:901
    y(i)=state(901-i+1);
end

%Read in Oxygen Isotope Data from Bassinot, et al 1994

A = dlmread('bassinot.txt');

isotope_time = A(:,1);
isotope = A(:,2);

%Panel Plot of Insolation, Model Prediction, and Oxygen Isotope Stacks
subplot(3,1,1); 
plot(-time,insolation)
title('Insolation (Normalized)')
axis([0 900 -3 3])
subplot(3,1,2); 
plot(-time,y)
title('Glacial State')
axis([0 900 -0.5 2.5])
subplot(3,1,3); plot(isotope_time,isotope)
get(gca);
set(gca,'Xdir','default', 'YDir', 'reverse')
axis([0 900 -3 3])
title('Oxygen Isotope Stack')
            