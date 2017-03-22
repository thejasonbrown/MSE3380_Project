%% FOS Calculator
% Function takes in two gear and the loading scenario to calculate FOS

%% Inputs 
power = 120; %watts
Qv = 6; %Quality Factor assumed of 6


hardness = 200; %brinell
grade = 1;

diametralPitch = 25.4/2.5; %teeth/Inch
diametralPitchMetric = diametralPitch/25.4; %teeth/mm

fwPinion = 18/25.4;
tPinion = 20; %number of teeth
nPinion = 100; %RPM
bPinion = fwPinion*25.4; %face width in mm
hardnessPinion = 0;

tGear = 36; %numberOfTeeth

life = 10^8;
reliability = 0.99;


%% Processing
St = GetMaxAllowableBendingStress(grade, hardness); %MPa
Sc = GetMaxAllowableContactStress(grade, hardness); %MPa


pitchDiameterPinion = tPinion/diametralPitchMetric;
V = pi * (pitchDiameterPinion / 1000) * (nPinion / 60); %m/s

wt = power/V; %Newtons

%Assume Kb=Ko=Yo=Zr=1
K0 = 1;


%Dynamic Factor
Kv = DynamicFactor(Qv, V);

%Form Factors
Yp = FormFactor(tPinion);
Yg = FormFactor(tGear);

Ks = 0.8433 * (bPinion * sqrt(Yp) / diametralPitchMetric)^0.0535;


Kh = 1.27%LoadDistributionFactor(fwPinion, diametralPitch*tPinion);

Kb = 1; %Rim-Thickness Factor

YjP = 0.33; %****************Hard coded for now

Y0 = 1;
Zr = 1;
%% Outputs
bendingStressPinion = wt * K0 * Kv * Ks * (diametralPitchMetric/bPinion) * (Kh * Kb)/YjP

%% Auxilary Functions
% Lookup Functions

%% Max Bending Stress Calculator
function [St] = GetMaxAllowableBendingStress (g, h)
    if(g == 1) %Figure 14-2
        St = 0.553 * h + 88.3; %MPa
    elseif (g == 2)
        St = 0.703 * h + 113; %MPa
    end
end

%% Max Contact Stress Calculator
function [Sc] = GetMaxAllowableContactStress (g, h)
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
if (F <=1)
    Cpf=(F/(10*d)-0.025);
elseif (F <= 17)
    Cpf=(d/(10*d)-0.0375+0.0125*F);
elseif (F<=40)
    Cpf=(F/(10*d)-0.1109+0.0207*F-0.000228*F^2);
end 
Cmc = 1; %for uncrowned teeth
Cpm = 1; %straddle-mounted
Cma = 0.127 + 0.0158 * F - 0.930 * 10^-4 * F^2; %commercial enclosed unit
Ce = 1; % gearing is not adjusted at assembly, nor compatibility is improved by lapping

Kh = 1 + Cmc*(Cpf*Cpm+Cma*Ce);
end