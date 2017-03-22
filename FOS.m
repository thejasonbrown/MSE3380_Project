%% FOS Calculator
% Function takes in two gear and the loading scenario to calculate FOS

%% Inputs
%Gear Info
material = struct('Name', 'Steel',...
    'H', 200,...
    'Grade', 1,...
    'E', 210e3,...
    'v', 0.3);
gearSet = struct('Material', material,...
    'DiametralPitch', 0.4,... %mm
    'PitchAngle', 20,... %Degrees
    'FaceWidth', 18,... %mm
    'PinionTeeth', 20,...
    'GearTeeth', 36,...
    'Quality', 6);

clear material;

%load condition
operatingConditions = 0; %**************
power = 120; %watts
nPinion = 100; %RPM

%Service Requirements
life = 10^8;
reliability = 0.99;

%% Processing

%Determine Auxilary Values
dPinion = gearSet.PinionTeeth/gearSet.DiametralPitch; %diameter of pinion [mm]
V = pi * (dPinion / 1000) * (nPinion / 60); % pitch line velocity [m/s]
gearRatio = gearSet.GearTeeth/gearSet.PinionTeeth;

%Calculate Tooth Stress Coefficients
wt = power/V; %Newtons
Kv = DynamicFactor(gearSet.Quality, V); %Dynamic Factor
Ks = SizeFactor(gearSet); %Size Factor
Kh = 1.27;%***********LoadDistributionFactor(fwPinion, diametralPitch*tPinion);
Kb = 1; %Rim-Thickness Factor
Yj = [0.33 0.038]; %****************Hard coded for now * Geometric Bending Strength
Zi = PitResistanceExtSpur(gearSet.PitchAngle, gearRatio); %Geometric Pitting Resistance
Ze = ElasticCoefficient(gearSet.Material); %Material-Material Gear Modulus

%Calculate Tooth Stresses [MPa]
bendingStressPinion = wt * K0 * Kv * Ks(1) * (gearSet.DiametralPitch/gearSet.FaceWidth) * (Kh * Kb)/Yj(1)
bendingStressGear = wt * K0 * Kv * Ks(2) * (gearSet.DiametralPitch/gearSet.FaceWidth) * (Kh * Kb)/Yj(2)
contactStressPinion = Ze *  sqrt(wt * K0 * Kv * Ks(1) * (Kh/((gearSet.PinionTeeth / gearSet.DiametralPitch) * gearSet.FaceWidth)) * (Zr/Zi))
contactStressGear = (Ks(2)/Ks(1))^0.5 * contactStressPinion

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

%% Load Distribution Factor Calculator
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

%% Elastic Coefficient (assume repeated material)
function [Ze] = ElasticCoefficient(material)
E = material.E;
v = material.v;

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
