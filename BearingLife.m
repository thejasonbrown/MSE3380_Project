function [L] = BearingLife(F_D, C_10)
% This function calculates the expected life of the bearing

%% Set Variables
a = 3;               % Ball bearings can support high enough loads, this determines the value for a
L_R = 1000000;       % SKF bearings are rated to a life of 1000000 revolutions

%% Calculations
L = ((C_10/F_D)^a)*L_R;

end