function [ nf, ny] = shaftStress( Sut, Sy, d, Ma, Mm, Ta, Tm, Kt, Kts)
% Function to calculate the stresses for the shaft

% This function takes the shaft's diameter, ultimate tensile strength,
% and midrange and alternating moments and torques as inputs. It returns
% the shaft stress


% Find SePrime
if (Sut <= 1400)
    SePrime = Sut/2;
else
    SePrime = 700;
end 

%From table in MPa
a = 1.58; 
b = -0.085;

ka = a*Sut^b; %surface finish factor of ground part
kb = (d/07.62)^-0.107; % size factor (all under 51mm)
kc = 1; %combined or pure bending loading factor (pg 299)
kd = 1; %Temperature factor (normal bounds)
ke = 0.814; %reliability factor at 0.99

Se = ka*kb*kc*kd*ke*SePrime;

% Change d to imperial
d = d/25.4;
SutImp = Sut/6.89475728;
rootAt = 0.246-3.08e-3*SutImp+1.51e-5*SutImp^2-2.67*10^-8*SutImp^3;
q = 1/(1+rootAt/sqrt(d/2));
Kf = 1 + q*(Kt-1);
rootAs = 0.190-2.51e-3*SutImp+1.35e-5*SutImp^2-2.67*10^-8*SutImp^3;
qs = 1/(1+rootAs/sqrt(d/2));
Kfs = 1 + qs*(Kts-1);

% Assuming solid shaft with round cross section:
% Change d to meters
d = d*25.4/1000;

% Divide by 1e3 to get in MPa
alternatingBending = Kf*32*Ma/(pi*d^3)/1e6;
midrangeBending = Kf*32*Mm/(pi*d^3)/1e6;
alternatingTorque = Kfs*16*Ta/(pi*d^3)/1e6;
midrangeTorque = Kfs*16*Tm/(pi*d^3)/1e6;
% Von mises stresses
alternatingVonMises = (alternatingBending^2 + 3*alternatingTorque^2)^0.5;
midrangeVonMises = (midrangeBending^2 + 3*midrangeTorque^2)^0.5;
maxVonMises = ((midrangeBending + alternatingBending)^2 + 3*(midrangeTorque+alternatingTorque)^2)^0.5;

% Goodman Criteria
nf = (alternatingVonMises/Se + midrangeVonMises/Sut)^-1;

% Check yielding
ny = Sy/maxVonMises;

end