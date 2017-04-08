%% PROJECT      Stamping Press Conveyer System Drive System Design
%
% Group No.     9
% Members       Michael Gerard Allan, Jason Michael Brown, Kaspar Shah Shahzada, Joshua Graham Underwood
% Course        Mechanical Components Design for Mechatronic Systems (MSE 3380)
% Instructor    Prof. Dr. Aaron Price
% Department    Mechanical & Materials Engineering
% Faculty       Engineering
% Institution   Western University
% Date          March 24, 2017

% *For further insight into the intermediate calculations, please see the
%  called functions used in the main script

%% Clear workspace
close all
evalin('caller','clear all');
feature('accel','on')
clc

%% Output Requirements
% To see Output Requirement calculations please see function
% "requiredOutput.m"

%Calculate Required Outputs
[reqOutputTorque,reqOutputVelocity,reqOutputPower] = requiredOutput();

% Required output power, Torque and Speed
disp('<strong>Output Requirements</strong>')
disp(['Required output torque: ' num2str(reqOutputTorque, 5) ' [Nm] ']);        % Display the required output torque
disp(['Required speed:   ' num2str(reqOutputVelocity, 2) ' [RPM] ']);            % Display the required speed
disp(['Required output power:  ' num2str(reqOutputPower, 4) ' [W]  ']);          % Display the required output power
disp(' ');

%% Motor/Power Requirements
% The required input power must account for the gearbox's 90% efficiency
% Please see function "reqInputPower.m" for calculations

% Calculate Motor Power Requirement
reqInputPower = requiredInputPower(reqOutputPower);

% Motor Selection
motor  = struct('name',     'SIZE 34H5 (126 mm) � 5 phase 0.72� ', ...
    'partNumber', '34H5126-280-5A',...
    'powerOutput',      56.5,  ...        % [W]
    'speed',      75,  ...        % [rpm]
    'torque',     7.2,  ...        % [Nm]
    'stepSize',    0.72,...      % [deg]
    'website',  'http://www.kocomotion.de/fileadmin/pages/10_PRODUKTE/Dings/Dings_hybrid-steppermotors.pdf');

% Check Power Buffer
powerBuffer = motor.powerOutput - reqInputPower;

%Motor selection and design decisions
disp('<strong>Motor Selection</strong>');
disp(['Due to the motor`s inefficiencies the required input power to the gearbox (supplied by the motor) is ' num2str(reqInputPower, 3) ' [W]']);
disp(['Using this specification, the ' motor.name ' motor was selected']);
disp(['A ' motor.name ' motor will operate at ' num2str(motor.speed, '%i') ' [RPM] and provide up to ' num2str(motor.torque,2) ' [Nm], ' num2str(powerBuffer,3) ' [W] more than required']);
disp(' ');

%% Gear Design - Gear Ratio & Tooth # Selection
% Using the gearing interference equations, gear tooth # selection to
% provide the appropriate gearing ratio with zero tooth interference
% *Please read "GearTeethCalculator.m" to gain a better understanding of
% the tooth selection process

% Design Decisions
DesiredGearingRatio = 79; %Picked to achieve scaled down RPM and scaled up torque required

% Calculate Gear & Pinion Teeth Numbers
[PinionNumberOfTeeth, GearNumberOfTeeth] = GearTeethCalculator(DesiredGearingRatio);
ActualGearingRatio = (GearNumberOfTeeth/PinionNumberOfTeeth)^2;

disp('<strong>Gear Tooth Number Selection</strong>');
disp(['Given our desired total gearing ratio of ' num2str(DesiredGearingRatio, '%i') ' the closest achievable gearing ratio with standard gear sizes is ' num2str(ActualGearingRatio, 4)]);
disp('This will be implemented using a two-stage speed reducer, with two sets of gearing pairs.');
disp(['The pinions will have ' num2str(PinionNumberOfTeeth, '%i') ' teeth, and the gears will have ' num2str(GearNumberOfTeeth, '%i') ' teeth ']);

% Resolution Check
outputStepSize = (motor.stepSize/360)*(2*pi*1)/ActualGearingRatio;
disp(['Using this gearing ratio, the linear resolution capable of the system is ' num2str(outputStepSize) ' [m/step], well below the 0.1 [mm/step] constraint. ']);
disp(' ');

%% Gear Selection
% Using the AGMA Stress equations, the FOS for both contact and shear
% stress are calculated for both gearing sets. For more insight into the
% AGMA intermediate calculations please read "GearFOS.m"

load Materials.mat; %Load Boston Gear Material Characteristics
gearSet = struct('PinionMaterial', Materials.CarbonSteel,...    %Define gear-set to be used
    'GearMaterial', Materials.CastIron,...
    'PinionPartNumber', 'YK18-10018',...
    'GearPartNumber', 'YK160B-10770',...
    'DiametralPitch', 5/25.4,... %mm
    'PitchAngle', 20,... %Degrees
    'FaceWidth', 2.5 * 25.4,... %mm
    'PinionTeeth', 18,...
    'GearTeeth', 160,...
    'Quality', 6);

% Analyze Output Gear Set (Gear and Pinion Closest to Output Shaft)
SpeedOfOutputPinion = reqOutputVelocity * (GearNumberOfTeeth/PinionNumberOfTeeth); % [RPM]
outputPinionlife = SpeedOfOutputPinion * 60 * 42 * 52 * 10; % [cycles]
[OutputGearSetAnalysis] = GearFOS (reqOutputPower/0.9, SpeedOfOutputPinion, outputPinionlife, gearSet);

% Analyze Output Gear Set (Gear and Pinion Closest to Input Shaft)
SpeedOfInputPinion = SpeedOfOutputPinion * (GearNumberOfTeeth/PinionNumberOfTeeth); % [RPM]
inputPinionlife = SpeedOfInputPinion * 60 * 42 * 52 * 10; % [cycles]
[InputGearSetAnalysis] = GearFOS (reqOutputPower/0.95, SpeedOfInputPinion, inputPinionlife, gearSet);

disp('<strong>Output Gear-Set FOS Results</strong>');
disp(['The gear and pinion selected are the ' gearSet.GearPartNumber ' and ' gearSet.PinionPartNumber ', respectively.']);
disp(['Bending stress for the output pinion is:  ' num2str(OutputGearSetAnalysis(1,1),3) ' [MPa]  ' 'with a FOS of: ' num2str(OutputGearSetAnalysis(1,2),3)]);   %Display bending stres & FOS for Output Pinion
disp(['Contact stress for the output pinion is:  ' num2str(OutputGearSetAnalysis(1,3),3) ' [MPa]  ' 'with a FOS of: ' num2str(OutputGearSetAnalysis(1,4),3)]);   %Display bending stres & FOS for Output Pinion
disp(['Bending stress for the output gear is:  ' num2str(OutputGearSetAnalysis(2,1),3) ' [MPa]  ' 'with a FOS of: ' num2str(OutputGearSetAnalysis(2,2),3)]);   %Display bending stres & FOS for Output Pinion
disp(['Contact stress for the output gear is:  ' num2str(OutputGearSetAnalysis(2,3),3) ' [MPa]  ' 'with a FOS of: ' num2str(OutputGearSetAnalysis(2,4),3)]);   %Display bending stres & FOS for Output Pinion
disp(' ');

disp('<strong>Input Gear-Set FOS Results</strong>');
disp(['The gear and pinion selected are the ' gearSet.GearPartNumber ' and ' gearSet.PinionPartNumber ', respectively.']);
disp(['Bending stress for the input pinion is:  ' num2str(InputGearSetAnalysis(1,1),3) ' [MPa]  ' 'with a FOS of: ' num2str(InputGearSetAnalysis(1,2),3)]);   %Display bending stres & FOS for Output Pinion
disp(['Contact stress for the input pinion is:  ' num2str(InputGearSetAnalysis(1,3),3) ' [MPa]  ' 'with a FOS of: ' num2str(InputGearSetAnalysis(1,4),3)]);   %Display bending stres & FOS for Output Pinion
disp(['Bending stress for the input gear is:  ' num2str(InputGearSetAnalysis(2,1),3) ' [MPa]  ' 'with a FOS of: ' num2str(InputGearSetAnalysis(2,2),3)]);   %Display bending stres & FOS for Output Pinion
disp(['Contact stress for the input gear is:  ' num2str(InputGearSetAnalysis(2,3),3) ' [MPa]  ' 'with a FOS of: ' num2str(InputGearSetAnalysis(2,4),3)]);   %Display bending stres & FOS for Output Pinion
disp(' ');

%% Shaft Design
[ inputShaft, intermediateShaft, outputShaft ] = ShaftLoadings(  );


% Conversion Factor
inchesToM = 25.4/1000;

% From catalogue
PinionBore = 1.125;
GearBore = 1.625;

% Design decision
ShaftFOS = 1.5;

% Will eventually need to add bearing bore
SmallerBore = min(GearBore, PinionBore);
BiggerBore = max(GearBore, PinionBore);

% Shaft Material Constants
% Current Material : 1050 CD, reasoning contained in report
Sut = 690; %MPa
Sy = 580; %MPa

%% Input Shaft
% Critical Point 1
% HAND CALC - currently bullshit values
nf1 = 10;
ny1 = 10;

% Remaining Critical Points
%Array of variables - x, Kt, Kts
inputShaftArray = [8.65, 108.65, 113.65, 140, 144.65; ...
    2.3 1.65 2.65 1.75 2.3; 2.05 1.45 2.1 1.5 2.05];

inputShaftGoodman = zeros(length(inputShaftArray),1);
inputShaftYield = zeros(length(inputShaftArray),1);

Tm = inputShaft.torque;
Ta = 0;

for i=1:length(inputShaftArray)
    x = inputShaftArray(1,i);
    Mom = inputShaft.moments(x*1000,2);
    Ma = abs(real(Mom)-imag(Mom))/2;
    Mm = (real(Mom)+imag(Mom))/2;
    d = inputShaft.diameter(x*1000,2);
    Kt = inputShaftArray(2,i);
    Kts = inputShaftArray(3,i);
    [inputShaftGoodman(i), inputShaftYield(i)] = shaftStress(Sut, Sy, d, Ma, Mm, Ta, Tm, Kt, Kts);
    % UNCOMMENT WHEN USING A MATLAB VERSION THAT IS NOT ANCIENT AND HAS
    % THIS CAPABILITY
    % inputShaftGoodman(i) = round(inputShaftGoodman(i),2);
    % inputShaftYield(i) = round(inputShaftYield(i),2);
end

% MUST ACCOUNT FOR HAND CALC TOO
inputShaftGoodman = [inputShaftGoodman; nf1];
inputShaftYield = [inputShaftYield; ny1];

disp('<strong>Input Shaft Results</strong>');
disp(['The Goodman FOS and yielding FOS for critical locations 1-' num2str(length(inputShaftArray)) ' are:']);
for i=1:length(inputShaftGoodman)
    disp(['  ' num2str(inputShaftGoodman(i)) '  ' num2str(inputShaftYield(i))]);
end 

disp(' ');

%% Intermediate Shaft
% Last Critical Point on output shaft
% HAND CALC - currently bullshit values
nf18 = 10;
ny18 = 10;

% Remaining Critical Points
%Array of variables - x, Kt, Kts
intermediateShaftArray = [9.65 129.65 134.65 159.65 209.65 214.65 219.3; ...
    1.65 2.9 1.6 2.6 1.6 2.6 2.5; 1.4 2.4 1.35 2.2 1.35 2.3 2.2];

intermediateShaftGoodman = zeros(length(intermediateShaftArray),1);
intermediateShaftYield = zeros(length(intermediateShaftArray),1);

Tm = intermediateShaft.torque;
Ta = 0;

for i=1:length(intermediateShaftArray)
    x = intermediateShaftArray(1,i);
    Mom = intermediateShaft.moments(x*1000,2);
    Ma = abs(real(Mom)-imag(Mom))/2;
    Mm = (real(Mom)+imag(Mom))/2;
    d = intermediateShaft.diameter(x*1000,2);
    Kt = intermediateShaftArray(2,i);
    Kts = intermediateShaftArray(3,i);
    [intermediateShaftGoodman(i), intermediateShaftYield(i)] = shaftStress(Sut, Sy, d, Ma, Mm, Ta, Tm, Kt, Kts);
    % UNCOMMENT WHEN USING A MATLAB VERSION THAT IS NOT ANCIENT AND HAS
    % THIS CAPABILITY
    % intermediateShaftGoodman(i) = round(intermediateShaftGoodman(i),2);
    % intermediateShaftYield(i) = round(intermediateShaftYield(i),2);
end

% MUST ACCOUNT FOR HAND CALC TOO
intermediateShaftGoodman = [intermediateShaftGoodman; nf1];
intermediateShaftYield = [intermediateShaftYield; ny1];

disp('<strong>Input Shaft Results</strong>');
disp(['The Goodman FOS and yielding FOS for critical locations 1-' num2str(length(intermediateShaftArray)) ' are:']);
for i=1:length(intermediateShaftGoodman)
    disp(['  ' num2str(intermediateShaftGoodman(i)) '  ' num2str(intermediateShaftYield(i))]);
end 

disp(' ');

%% Output Shaft
% Last Critical Point on output shaft
% HAND CALC - currently bullshit values
nf18 = 10;
ny18 = 10;

% Remaining Critical Points
%Array of variables - x, Kt, Kts
outputShaftArray = [4.65 54.65 59.65 179, 184.65; ...
    2.3 1.7 2.65 1.6 2.3; 2.05 1.45 2.1 1.45 2.05];

outputShaftGoodman = zeros(length(outputShaftArray),1);
outputShaftYield = zeros(length(outputShaftArray),1);

Tm = outputShaft.torque;
Ta = 0;

for i=1:length(outputShaftArray)
    x = outputShaftArray(1,i);
    Mom = outputShaft.moments(x*1000,2);
    Ma = abs(real(Mom)-imag(Mom))/2;
    Mm = (real(Mom)+imag(Mom))/2;
    d = outputShaft.diameter(x*1000,2);
    Kt = outputShaftArray(2,i);
    Kts = outputShaftArray(3,i);
    [outputShaftGoodman(i), outputShaftYield(i)] = shaftStress(Sut, Sy, d, Ma, Mm, Ta, Tm, Kt, Kts);
    % UNCOMMENT WHEN USING A MATLAB VERSION THAT IS NOT ANCIENT AND HAS
    % THIS CAPABILITY
    % outputShaftGoodman(i) = round(outputShaftGoodman(i),2);
    % outputShaftYield(i) = round(outputShaftYield(i),2);
end

% MUST ACCOUNT FOR HAND CALC TOO
outputShaftGoodman = [outputShaftGoodman; nf1];
outputShaftYield = [outputShaftYield; ny1];

disp('<strong>Input Shaft Results</strong>');
disp(['The Goodman FOS and yielding FOS for critical locations 1-' num2str(length(outputShaftArray)) ' are:']);
for i=1:length(outputShaftGoodman)
    disp(['  ' num2str(outputShaftGoodman(i)) '  ' num2str(outputShaftYield(i))]);
end 

disp(' ');

%% Bearing Selection
% Find the catalog load ratings

% Btest_C_10 = CatalogueLoadRating(2.5,1.2e6);
B1_C_10 = CatalogueLoadRating(abs(inputShaft.shear(1,2)),9.9e7);
B2_C_10 = CatalogueLoadRating(abs(inputShaft.shear(inputShaft.length*1000,2)),9.9e7);
% B3_C_10 = CatalogueLoadRating(abs(intermediateShaft.shear(1,2)),1.1e7);
% B4_C_10 = CatalogueLoadRating(abs(intermediateShaft.shear(intermediateShaft.length*1000,2)),1.1e7);
% B5_C_10 = CatalogueLoadRating(abs(outputShaft.shear(1,2)),1.2e6);
% B6_C_10 = CatalogueLoadRating(abs(outputShaft.shear(outputShaft.length*1000,2)),1.2e6);
