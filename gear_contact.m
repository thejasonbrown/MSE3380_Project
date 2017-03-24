function [ sigma_c ] = gear_contact( angle, mG, mN, Wt, V, Qv, F, d, dp)

%Calculating I, using formula 14-23 for an external gear
I = cosd(angle)*sind(angle)/(2*mN)*(mG)/(mG+1);

%Finding Kv
B = 0.25*(12-Qv)^(2/3);
A = 50 + 56*(1-B);
Kv = ((A+sqrt(200*V))/A)^B; %in m/s

%Use www.globalspec.com to get F ** should be in Main

%F and d must be in inches
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

Km = 1 + Cmc*(Cpf*Cpm+Cma*Ce);

%Cp = from table 14-8, p. 757
Ko = 1;
Ks = 1;
Cf = 1;

sigma_c = Cp*sqrt(Wt*Ko*Kv*Ks*Km*Cf/(dp*F*I));
end

