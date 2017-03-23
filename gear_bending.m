function [BendingStress, BendingEnduranceStrength] = gear_bending(Np, Pd, n, H, Qv, F)
% This function calculates the factor of safety for gears in bending
% Note: all calculations in this function are done in US Customary Units

% J is geometry factor for 20 degree pressure angle and full depth teeth

d = Pd * Np

dp = Np/Pd; % where dp is in [in], Np is number of teeth, and Pd is diametral pitch [teeth/in]

V = pi()*dp*n/12; % where V is in [ft/min], and n is angular speed [rpm]

Wt = 33000 * H/V; % where Wt is in [lbf], and H is transmitted power [hp]

% Ko is the Overload Factor

B = 0.25*((12-Qv)^(2/3)) % Where Qv is the Quality Number as defined by AGMA
A = 50 + 56*(1 - B);

Kv = ((A + sqrt(V))^B)/A; % Kv is the Dynamic Factor, V is in [ft/min]

Ks = 1 % Ks is Size Factor

%Check to see if we need to use a simplification
if (F/(10*d) < 0.05)
    Fd = 0.05;
end

%Find Cpf
if (F <=1)
    Cpf=(Fd-0.025);
elseif (F <= 17)
    Cpf=(Fd-0.0375+0.0125*F);
elseif (F<=40)
    Cpf=(Fd-0.1109+0.0207*F-0.000228*F^2);
end 
Cmc = 1; %for uncrowned teeth
Cpm = 1; %straddle-mounted
Cma = 0.15; %commercial enclosed unit
Ce = 1; % gearing is not adjusted at assembly, nor compatibility is improved by lapping

Km = 1 + Cmc*(Cpf*Cpm+Cma*Ce); %Km is Load Distribution Factor

Kb = 1 %Kb is Rim Thickness Factor (ESTIMATE, NEED TO REVISIT)

J = 0.4 %J is Geometry factor (ESTIMATE, NEED TO REVISIT)

BendingStress = Wt * Ko * Kv * Ks * (Pd/F) * (Km * Kb)/J; % Pd is diametral pitch [teeth/in], F is face width [in]

end

