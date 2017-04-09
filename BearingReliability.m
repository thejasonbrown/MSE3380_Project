function [R] = BearingReliability(F_D, L_D, C_10)
% This function calculates the reliability of the bearing

%% Set Variables
appFactor = 1.3;     % Typical load factor for 'Commercial Gearing' applications (Table 11-5 Shigley's)
L_R = 1000000;       % SKF bearings are rated to a life of 1000000 revolutions
a = 3;               % Ball bearings can support high enough loads, this determines the value for a
x_0 = 0.02;          % Weibull parameter from SKF
theta = 4.459;       % Weibull parameter from SKF
b = 1.483;           % Weibull parameter from SKF
R_D = 0.99;          % Desired reliability is 99%

%% Equations

x_D = L_D/L_R;

R = exp(-((x_D*(appFactor*F_D/C_10)^a-x_0)/(theta-x_0))^b);

end