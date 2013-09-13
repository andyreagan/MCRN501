% insolation data calculation

% http://en.wikipedia.org/wiki/Milankovitch_cycles

load INSOLN.LA2004.BTL.ASC

plot_back = 800;

close all;
figure;
subplot(6,1,2);
plot(INSOLN_LA2004_BTL_ASC(1:plot_back,1),INSOLN_LA2004_BTL_ASC(1:plot_back,2));
title('eccentricity e')

subplot(6,1,1);
plot(INSOLN_LA2004_BTL_ASC(1:plot_back,1),INSOLN_LA2004_BTL_ASC(1:plot_back,3));
title('obliquity \epsilon')

subplot(6,1,3);
plot(INSOLN_LA2004_BTL_ASC(1:plot_back,1),sin(INSOLN_LA2004_BTL_ASC(1:plot_back,4)));
title('sin(\omega)')

subplot(6,1,4);
plot(INSOLN_LA2004_BTL_ASC(1:plot_back,1),INSOLN_LA2004_BTL_ASC(1:plot_back,2).*sin(INSOLN_LA2004_BTL_ASC(1:plot_back,4)));
title('e sin(\omega)')

s0 = 1367; % solar constant
phi = deg2rad(65); % latitude
theta = pi/2; % summer solstice

insolation = zeros(length(INSOLN_LA2004_BTL_ASC(:,1)),1);

for i=1:length(INSOLN_LA2004_BTL_ASC(:,1))

e = INSOLN_LA2004_BTL_ASC(i,2); % eccentricity
eps = INSOLN_LA2004_BTL_ASC(i,3); % obliquity
pibar = INSOLN_LA2004_BTL_ASC(i,4); % perihelion distance

dist_sun = (1+e*cos(theta - pibar)); %/(1-e^2);

delta = eps; % at the summer solstice

h0 = acos(-tan(phi)*tan(delta));
q = s0/pi*dist_sun^2*(h0*sin(phi)*sin(delta)+cos(phi)*cos(delta)*sin(h0));

insolation(i) = q;
end

subplot(6,1,5);
plot(INSOLN_LA2004_BTL_ASC(1:plot_back,1),insolation(1:plot_back));
title('insolation')

subplot(6,1,6);
plot(fliplr(-INSOLN_LA2004_BTL_ASC(1:plot_back,1)),fliplr(insolation(1:plot_back)));
title('insolation')

figure;
plot_back=1000;
plot(fliplr(-INSOLN_LA2004_BTL_ASC(1:plot_back,1)),fliplr(insolation(1:plot_back)));
