%% Required Input Power
% Required input power take the required output power and then factors in
% the inefficiencies of the gearbox to determine the required input power

function [reqInputPower] = requiredInputPower(reqOutputPower)
%Design Assumptions
Efficiency = 0.90;

%Output
reqInputPower = reqOutputPower/Efficiency; %[W] 
end

