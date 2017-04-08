function [omega] = CriticalSpeed(diameter, forces, deflection)
% This function calculates the critical speeds of the loaded shafts
% Note: shaft struct has (position [micrometer], diameter [millimeter]), forces
% has (position [micrometer], force [N]), and deflection ()

%% Set Variables and change input units
density = 7850;                     % density of 1050 steel in kg/m^3
diameter(:,1) = diameter(:,1)/1e6;  % convert from micrometer to m
diameter(:,2) = diameter(:,2)/1000; % convert from mm to m
forces(:,1) = forces(:,1)/1e6;      % convert from micrometer to m
num = 0;
den = 0;

%% Equations

% Find shaft's intrinsic critical speed in [rad/s]
for i=1,length(diameter)
num = num + (diameter(i)/2)^2*pi*density*1e-6*deflection(i);     % numerator summation
den = den + (diameter(i)/2)^2*pi*density*1e-6*deflection(i)^2;   % denominator summation
end

w_shaft = sqrt(9.81*num/den);   % the critical speed of the shaft

end