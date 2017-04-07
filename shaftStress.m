function [ nf, ny] = shaftStress( Sut, Sy, d, Ma, Mm, Ta, Tm )
% Function to calculate the stresses for the shaft

% This function takes the shaft's diameter, ultimate tensile strength,
% and midrange and alternating moments and torques as inputs. It returns
% the shaft stress

% Convert to psi
Sut = Sut/6.89475728*1000;
Sy = Sy/6.89475728*1000;

% Find SePrime
if (Sut <= 200000)
    SePrime = Sut/2;
elseif (Sut > 200000)
    SePrime = 100000;
end 

% Shoulder fillet - well rounded
Kt = 1.7;
Kts = 1.5;

%For a quick conserative first pass, assume Kf=Kt and Kfs=Kts
Kf = Kt;
Kfs = Kts;

%From table
a = 2.7;
b = 0.265;

ka = a*Sut^-b;
kb = 0.9; % guess
kc = 1;
kd = 1;
ke = 1;

Se = ka*kb*kc*kd*ke*SePrime;

% A typical D/d ratio is 1.2, therefore:
D = 1.2*d;
% Assume a fillet radius r=d/10
r = d/10;

Kt = 1.6;               % From A-15-9
q = 0.82;               % From figure 6-20
Kf = 1 + q*(Kt-1);      % Eqn 6-32
Kts = 1.35;             % From figure A-15-8
qs = 0.85;              % From figure 6-21
Kfs = 1 + qs*(Kts-1); 

if (0.11 <= d <= 2)     % Eqn 6-20
    kb = 0.879*d^-0.107;
elseif (2 < d <= 10)
    kb = 0.91*d^-0.157;
end 

% More accurate Se
Se = ka*kb*kc*kd*ke*SePrime;

% Assuming solid shaft with round cross section:
alternatingBending = Kf*32*Ma/(pi*d^3);
midrangeBending = Kf*32*Mm/(pi*d^3);
alternatingTorque = Kfs*16*Ta/(pi*d^3);
midrangeTorque = Kfs*16*Tm/(pi*d^3);

% Von mises stresses
alternatingVonMises = (alternatingBending^2 + 3*alternatingTorque^2)^0.5;
midrangeVonMises = (midrangeBending^2 + 3*midrangeTorque^2)^0.5;
maxVonMises = ((midrangeBending + alternatingBending)^2 + 3*(midrangeTorque+alternatingTorque)^2)^0.5;

% Goodman Criteria
nf = (alternatingVonMises/Se + midrangeVonMises/Sut)^-1;

% Check yielding
ny = Sy/maxVonMises;

end