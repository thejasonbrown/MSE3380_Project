%% FOS Calculator
% Function takes a gear-set and the loading scenario to calculate FOS

%% Inputs
%Gear Info
function [FOS] =  FOS (operatingConditions, power, nPinion, life, reliability, gearSet)
%% Processing

%Determine Auxilary Values
dPinion = gearSet.PinionTeeth/gearSet.DiametralPitch; %diameter of pinion [mm]
V = pi * (dPinion / 1000) * (nPinion / 60); % pitch line velocity [m/s]
gearRatio = gearSet.GearTeeth/gearSet.PinionTeeth;

%Calculate Tooth Stress Coefficients
wt = power/V; %[N]
K0 = 1; %Overload Factor
Kv = DynamicFactor(gearSet.Quality, V);
Ks = SizeFactor(gearSet);
Kh = LoadDistributionFactor(gearSet.FaceWidth, gearSet.DiametralPitch*gearSet.PinionTeeth);
Kb = 1; %Rim-Thickness Factor
Yj = [0.33 0.38]; %****************Hard coded for now * Geometric Bending Strength
Zr = 1; %Suface Finish Factor
Zi = PitResistanceExtSpur(gearSet.PitchAngle, gearRatio); %Geometric Pitting Resistance
Ze = ElasticCoefficient(gearSet.Material); %Material-Material Gear Modulus

%Calculate Tooth Stresses [MPa]
pinionBendingStress = wt * K0 * Kv * Ks(1) * (gearSet.DiametralPitch/gearSet.FaceWidth) * (Kh * Kb)/Yj(1);
gearBendingStress = wt * K0 * Kv * Ks(2) * (gearSet.DiametralPitch/gearSet.FaceWidth) * (Kh * Kb)/Yj(2);
pinionContactStress = Ze *  sqrt(wt * K0 * Kv * Ks(1) * (Kh/((gearSet.PinionTeeth / gearSet.DiametralPitch) * gearSet.FaceWidth)) * (Zr/Zi));
gearContactStress = (Ks(2)/Ks(1))^0.5 * pinionContactStress;

%Calculate FOS Coefficients
St = GetMaxAllowableBendingStress(gearSet.Material); %[MPa]
Sc = GetMaxAllowableContactStress(gearSet.Material); %[MPa]
Ch = 1; %Hardness Ratio Factor
Ytheta = 1; %Temperature Factor
Yn = StressLifeBendingFactor(life, gearRatio);
Yz = ReliabilityFactor(reliability);
Zn = StressLifePittingFactor(life, gearRatio); %Stress life factor

%Calculate FOS
FOSPinionBending = (St/pinionBendingStress) * (Yn(1)/(Ytheta*Yz));
FOSGearBending = (St/gearBendingStress) * (Yn(2)/(Ytheta*Yz));
FOSPinionPitting = (Sc/pinionContactStress) * ((Zn(1)*Ch)/(Ytheta*Yz));
FOSGearPitting = (Sc/gearContactStress) * ((Zn(2)*Ch)/(Ytheta*Yz));

FOS = [FOSPinionBending FOSPinionPitting; FOSGearBending FOSGearPitting];

end

%% Auxilary Functions
% Lookup Functions

%% Max Bending Stress Calculator
function [St] = GetMaxAllowableBendingStress (material)
h  = material.H;
g = material.Grade;
if(g == 1) %Figure 14-2
    St = 0.553 * h + 88.3; %MPa
elseif (g == 2)
    St = 0.703 * h + 113; %MPa
end
end

%% Max Contact Stress Calculator
function [Sc] = GetMaxAllowableContactStress (material)
h  = material.H;
g = material.Grade;
if(g == 1) %Figure 14-2
    Sc = 2.22 * h + 200; %MPa
elseif (g == 2)
    Sc = 2.41 * h + 237; %MPa
end
end

%% Dynamic Factor Calculator
function [ Kv ] = DynamicFactor( Qv, vel )
%Calculate Dynamic Factor
b = 0.25 * (12 - Qv)^(2/3); %Eqn 14-28
a = 50 + 56 *(1 - b); %Eqn 14-28

Kv = ((a + sqrt(200*vel))/a)^b; %Eqn 14-27
end

%% Form Factor Lookup
function [ Y ] = FormFactor(teeth)
if(teeth>400)
    Y = 0.485;
else
    load FormFactorTable.mat; %Table 14-2
    Y = interp1(FormFactorTable(:,1)', FormFactorTable(:,2)', teeth);
end
clear FormFactorTable
end

%% Load Distribution Factor Calculator **********
function [Kh] = LoadDistributionFactor(F, d)
Fd = F/(10*d);
if (Fd < 0.05)
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
Cma = 0.127 + 0.0158 * F - 0.930 * 10^-4 * F^2; %commercial enclosed unit
Ce = 1; % gearing is not adjusted at assembly, nor compatibility is improved by lapping
%**************Needs ABC lookup table for Cma
Kh = 1 + Cmc*(Cpf*Cpm+Cma*Ce);
end

%% Pit Resistance Calculator
function [Zi] = PitResistanceExtSpur(pitchAngle, gearRatio)
Zi = ((cosd(pitchAngle)*sind(pitchAngle)) / 2) * (gearRatio/(gearRatio + 1)); %External Spur (mN = 1)
end

%% Elastic Coefficient
function [Ze] = ElasticCoefficient(material)
E = material.E;
v = material.v;
%Assume same material for pinion and gear
Ze = sqrt(E / (2 * pi * (1 - v^2)));
end

%% Size Factor Calculator
function [Ks] = SizeFactor(gearSet)
%Form Factors
Yp = FormFactor(gearSet.PinionTeeth);
Yg = FormFactor(gearSet.GearTeeth);

KsP = 0.8433 * (gearSet.FaceWidth * sqrt(Yp) / gearSet.DiametralPitch)^0.0535;
KsG = 0.8433 * (gearSet.FaceWidth * sqrt(Yg) / gearSet.DiametralPitch)^0.0535;

Ks = [KsP KsG];
end

%% Stress Life Bending Factor Calculator
function [ Yn ] = StressLifeBendingFactor(life, gearRatio)
if (life > 3e6)
    Yn(1) = 1.3558*(life)^-0.0178;
    Yn(2) = 1.3558*(life/gearRatio)^-0.0178;
else
    Yn = -1;
end
end

%% Stress Life Pitting Factor Calculator
function [ Zn ] = StressLifePittingFactor(life, gearRatio)
if (life > 1e7)
    Zn(1) = 1.4488*(life)^-0.023;
    Zn(2) = 1.4488*(life/gearRatio)^-0.023;
else
    Zn = -1;
end
end

%% Reliability Factor Calculator
function [Yz] = ReliabilityFactor(R)
if(0.5 < R && R < 0.99)
    Yz = 0.658 - 0.0759*log(1-R);
elseif (0.99 <= R && R < 0.9999)
    Yz = 0.5 - 0.109*log(1-R);
else
    Yz = -1;
end
end