%Read in Oxygen Isotope Data

A = dlmread('bassinot.txt');

isotope_time = A(:,1);
isotope = A(:,2);

