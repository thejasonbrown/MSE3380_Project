function [C_10] = CatalogueLoadRating(F_D, L_D)
% This function calculates some stuff we will need for bearings
% Note: The units of F_D are equivalent to the output units, L_D is desired
% life in revolutions

%% Set Variables
appFactor = 1.3;     % Typical load factor for 'Commercial Gearing' applications (Table 11-5 Shigley's)
L_R = 1000000;       % SKF bearings are rated to a life of 1000000 revolutions
a = 3;               % Ball bearings can support high enough loads, this determines the value for a
x_0 = 0.02;          % Weibull parameter from SKF
theta = 4.459;       % Weibull parameter from SKF
b = 1.483;           % Weibull parameter from SKF
R_D = 0.99;          % Desired reliability is 99%

%% Calculations

x_D = L_D/L_R;       % Multiple of rating life equals the desired life over the rated life

C_10 = appFactor*F_D*(x_D/(x_0+(theta-x_0)*(1-0.99)^(1/b)))^(1/a);
end