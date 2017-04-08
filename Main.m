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
motor  = struct('name',     'SIZE 34H5 (126 mm) · 5 phase 0.72° ', ...
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

% Critical Point 2
x = 8.65;  %critical location in mm
Mom = inputShaft.moments(x*1000,2);
Ma = abs(real(Mom)-imag(Mom))/2;
Mm = (real(Mom)+imag(Mom))/2;
d = inputShaft.diameter(x*1000,2);
Tm = inputShaft.torque; % Nm Change this based on current torque at position given
Ta = 0;
%Kt and Kts from Figure A-15-8 & A-15-9
Kt = 2.3;
Kts = 2.05;
[nf2,ny2] = shaftStress( Sut, Sy, d, Ma, Mm, Ta, Tm, Kt, Kts);
% nf2 = round(nf2,2)
% ny2 = round(ny2,2)

% Critical Point 3
x = 108.65;  %critical location in mm
Mom = inputShaft.moments(x*1000,2);
Ma = abs(real(Mom)-imag(Mom))/2;
Mm = (real(Mom)+imag(Mom))/2;
d = inputShaft.diameter(x*1000,2);
Tm = inputShaft.torque; % Nm Change this based on current torque at position given
Ta = 0;
%Kt and Kts from Figure A-15-8 & A-15-9
Kt = 1.65;
Kts = 1.45;
[nf3,ny3] = shaftStress( Sut, Sy, d, Ma, Mm, Ta, Tm, Kt, Kts);
% nf3 = round(nf3,2)
% ny3 = round(ny3,2)

% Critical Point 4
x = 113.65;  %critical location in mm
Mom = inputShaft.moments(x*1000,2);
Ma = abs(real(Mom)-imag(Mom))/2;
Mm = (real(Mom)+imag(Mom))/2;
d = inputShaft.diameter(x*1000,2);
Tm = inputShaft.torque;
Ta = 0;
%Kt and Kts from Figure A-15-8 & A-15-9
Kt = 2.65;
Kts = 2.1;
[nf4,ny4] = shaftStress( Sut, Sy, d, Ma, Mm, Ta, Tm, Kt, Kts);
% nf4 = round(nf4,2)
% ny4 = round(ny4,2)

% Critical Point 5
x = 140;  %critical location in mm
Mom = inputShaft.moments(x*1000,2);
Ma = abs(real(Mom)-imag(Mom))/2;
Mm = (real(Mom)+imag(Mom))/2;
d = inputShaft.diameter(x*1000,2);
Tm = inputShaft.torque;
Ta = 0;
%Kt and Kts from Figure A-15-8 & A-15-9
Kt = 1.75;
Kts = 1.5;
[nf5,ny5] = shaftStress( Sut, Sy, d, Ma, Mm, Ta, Tm, Kt, Kts);
% nf5 = round(nf5,2)
% ny5 = round(ny5,2)

% Critical Point 6
x = 144.65;  %critical location in mm
Mom = inputShaft.moments(x*1000,2);
Ma = abs(real(Mom)-imag(Mom))/2;
Mm = (real(Mom)+imag(Mom))/2;
d = inputShaft.diameter(x*1000,2);
Tm = inputShaft.torque; % Nm Change this based on current torque at position given
Ta = 0;
%Kt and Kts from Figure A-15-8 & A-15-9
Kt = 2.3;
Kts = 2.05;
[nf6,ny6] = shaftStress( Sut, Sy, d, Ma, Mm, Ta, Tm, Kt, Kts);
% nf6 = round(nf6,2)
% ny6 = round(ny6,2)

disp('<strong>Input Shaft Results</strong>');
disp(['The FOS for critical locations 1-6 are: ' num2str(nf1) ', ' num2str(nf2) ', ' num2str(nf3) ', ' num2str(nf4) ', ' num2str(nf5) ', ' num2str(nf6) ', respectively, using Goodman criteria.']);
disp(['The yielding factors for critical locations 1-6 are: ' num2str(ny1) ', ' num2str(ny2) ', ' num2str(ny3) ', ' num2str(ny4) ', ' num2str(ny5) ', ' num2str(ny6) ', respectively.']);
disp(' ');

%% Output Shaft

% Critical Point 13
x = 4.65;  %critical location in mm
Mom = outputShaft.moments(x*1000,2);
Ma = abs(real(Mom)-imag(Mom))/2;
Mm = (real(Mom)+imag(Mom))/2;
Tm = outputShaft.torque;
Ta = 0;
d = outputShaft.diameter(x*1000,2);     
%Kt and Kts from Figure A-15-8 & A-15-9
Kt = 2.3;
Kts = 2.05;
[nf13,ny13] = shaftStress( Sut, Sy, d, Ma, Mm, Ta, Tm, Kt, Kts);

% Critical Point 14
x = 54.65;  %critical location in mm
Mom = outputShaft.moments(x*1000,2);
Ma = abs(real(Mom)-imag(Mom))/2;
Mm = (real(Mom)+imag(Mom))/2;
Tm = outputShaft.torque;
Ta = 0;
d = outputShaft.diameter(x*1000,2);     
%Kt and Kts from Figure A-15-8 & A-15-9
Kt = 1.7;
Kts = 1.45;
[nf14,ny14] = shaftStress( Sut, Sy, d, Ma, Mm, Ta, Tm, Kt, Kts);

% Critical Point 15
x = 59.65;  %critical location in mm
Mom = outputShaft.moments(x*1000,2);
Ma = abs(real(Mom)-imag(Mom))/2;
Mm = (real(Mom)+imag(Mom))/2;
Tm = outputShaft.torque;
Ta = 0;
d = outputShaft.diameter(x*1000,2);     
%Kt and Kts from Figure A-15-8 & A-15-9
Kt = 2.65;
Kts = 2.1;
[nf15,ny15] = shaftStress( Sut, Sy, d, Ma, Mm, Ta, Tm, Kt, Kts);

% Critical Point 16
x = 179.65;  %critical location in mm
Mom = outputShaft.moments(x*1000,2);
Ma = abs(real(Mom)-imag(Mom))/2;
Mm = (real(Mom)+imag(Mom))/2;
Tm = outputShaft.torque;
Ta = 0;
d = outputShaft.diameter(x*1000,2);     
%Kt and Kts from Figure A-15-8 & A-15-9
Kt = 1.6;
Kts = 1.45;
[nf16,ny16] = shaftStress( Sut, Sy, d, Ma, Mm, Ta, Tm, Kt, Kts);

% Critical Point 17
x = 184.65;  %critical location in mm
Mom = outputShaft.moments(x*1000,2);
Ma = abs(real(Mom)-imag(Mom))/2;
Mm = (real(Mom)+imag(Mom))/2;
Tm = outputShaft.torque;
Ta = 0;
d = outputShaft.diameter(x*1000,2);     
%Kt and Kts from Figure A-15-8 & A-15-9
Kt = 2.3;
Kts = 2.05;
[nf17,ny17] = shaftStress( Sut, Sy, d, Ma, Mm, Ta, Tm, Kt, Kts);

disp('<strong>Output Shaft Results</strong>');
disp(['The FOS for critical locations 1-6 are: ' num2str(nf13) ', ' num2str(nf14) ', ' num2str(nf15) ', ' num2str(nf16) ', and ' num2str(nf17) ', respectively, using Goodman criteria.']);
disp(['The yielding factors for critical locations 1-6 are: ' num2str(ny13) ', ' num2str(ny14) ', ' num2str(ny15) ', ' num2str(ny16) ', and ' num2str(ny17) ', respectively.']);
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
