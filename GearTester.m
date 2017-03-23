steel = struct('Name', '.20 Carbon Steel',...
    'H', 111,...
    'Grade', 1,...
    'E', 210e3,...
    'v', 0.29);
bronze = struct('Name', 'Brass',...
    'H', 75,...
    'Grade', 1,...
    'E', 120e3,...
    'v', 0.34);
castIron = struct('Name', 'Cast Iron ASTM 30',...
    'H', 210,...
    'Grade', 1,...
    'E', 100e3,...
    'v', 0.275);

gearSet = struct('Material', castIron,...
    'DiametralPitch', 96/25.4,... %mm
    'PitchAngle', 20,... %Degrees
    'FaceWidth', 0.25*25.4,... %mm
    'PinionTeeth', 18,...
    'GearTeeth', 160,...
    'Quality', 6);

%load condition
operatingConditions = 'CE';
power = 40; %watts
nPinion = 0.95/8.888; %RPM

%Service Requirements
life = 10^8;
reliability = 0.99;

FOS (operatingConditions, power, nPinion, life, reliability, gearSet)


