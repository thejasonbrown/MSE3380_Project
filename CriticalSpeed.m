function [RPMCrit] = CriticalSpeed(shaft, density)
% This function calculates the critical speeds of the loaded shafts in rpm
% Note: shaft struct has (position [micrometer], diameter [millimeter]), forces
% has (position [micrometer], force [N]), and deflection ()


%% Rayleigh's Method
weight = density * 9.81 * ((1e-6*pi*(shaft.diameter(:,2)./2e3).^2)); % [N]

wCrit = sqrt(9.81*sum(weight.*abs(shaft.deflection(:,2))/1000)/sum(weight.*(abs(shaft.deflection(:,2))/1000).^2)); % [rad/s]

RPMCrit = wCrit/(2*pi)*60; % [RPM]
end