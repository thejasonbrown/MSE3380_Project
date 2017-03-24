%% PROJECT      Stepper Motor Gearbox Design
%
% Group No.     9    
% Members       Michael Gerard Allan, Jason Michael Brown, Kaspar Shah Shahzada, Joshua Graham Underwood
% Course        Mechanical Components Design for Mechatronic Systems (MSE 3380)
% Instructor    Prof. Dr. Aaron Price
% Department    Mechanical & Materials Engineering
% Faculty       Engineering
% Institution   Western University
% Date          March 24, 2017

%% Clear workspace
close all
evalin('caller','clear all');
feature('accel','on')
clc

%% Design constraints
% To insert design contrain values

%Conveyor Parameters
BeltMass = 75;                % kg (Weight of the conveyor belt)
ConveyorLength = 6;           % m (Length of top edge of conveyor)
Friction = 0.12;              % (Coefficeint of friction)

%Roller Parameters (Using Conveyor Roller Model 2013 found here:
%http://www.rolmasterconveyors.ca/products/conveyor-rollers/)
RollerLength = 0.815;             % m (given)
RollerDensity = 7850;             % kg/m^3 (assume same density as blanks)
nRollers = 2;                     % Number of rollers in the conveyor
RollerRadius = 1;             % m (radius of roller = 1 inch)

%Blank Parameters
BlankThickness = 0.006;       % m (Thickness of blank)
BlankLength = 2.5;            % m (Length of blank)
BlankWidth = 0.815;           % m (Width of blank)
SteelDensity = 7850;          % kg/m^3 (Density of 1050 carbon steel) (http://www.azom.com/article.aspx?ArticleID=6526)
BlankMass = BlankThickness*BlankLength*BlankWidth*SteelDensity;  %kg (Mass of one blank)

%Miscellaneous Parameters
nBlanks = 2;                  % Number of blanks on conveyor at a time (1 blank is equivalent to all the blades cut from it)
BlankLoad = BlankMass*nBlanks; %kg (Total mass of all blanks on conveyor)

%% First design assumptions
% To insert the value for any assumed value other than design constrains ones

Speed = 0.1;                      % m/s (Conveyer Speed )
Efficiency = 0.9;                 % 90 percent efficiency
Reliability = 0.99;               % 99 percent reliability
PressureAngle = 20;               % Given
k = 1;                            % Picked because we are using full depth teeth

%% Required power
% To use a defined function titled "output_power" to calculate and display
% required power and torque for the motor as well as respective speed

[FOSOutputPower,FOSOutputTorque,RequiredOutputVelocity] = output_power(BlankLoad,BeltMass,RollerRadius,Speed,Friction);                        % Required output power, Torque and Speed
disp(['Required output power:  ' num2str(FOSOutputPower) ' kW  ']);              % Display the required output power
disp(['Required output torque: ' num2str(FOSOutputTorque) ' N.m ']);              % Display the required output torque
disp(['Required speed:   ' num2str(RequiredOutputVelocity) ' rpm ']);                     % Display the required speed

%% Motor choice
% To show the selected motor spec. from the catalogue 

% Required motor torque must include efficiency
% This was used to spec the motor
RequiredMotorPower = FOSOutputPower/Efficiency;
RequiredMotorTorque = FOSOutputTorque/Efficiency;

% Based on calculations and with a assumed gearing of x10, this motor was
% the best fit

motor  = struct('name',     'SIZE 34H2 (86 mm) · 2 phase 1.8° ', ...
                'output',      10,  ...        % [kW]
                'speed',      400,  ...        % [rpm]
                'torque',     4.4,  ...        % [Nm]
                'price',     1000,  ...        % [USD]
                'website',  'http://www.kocomotion.de/fileadmin/pages/10_PRODUKTE/Dings/Dings_hybrid-steppermotors.pdf');
            
%% Gear design
% To use and display bending stress, contact stress and safety factor for
% all gears by using a functions named "gear_bending" and "gear_contact"

%Finding the ratio of output to input
DesiredGearingRatio = 79; %Picked to achieve scaled down RPM and scaled up torque required

[PinionNumberOfTeeth, GearNumberOfTeeth] = GearTeethCalculator(DesiredGearingRatio,PressureAngle,k,RequiredOutputVelocity);
PinionNumberOfTeeth;
GearNumberOfTeeth;

%[B_S1,S_F1] = gear_bending(A,B,C);                                       % Bending stress for gear 1
%[C_S1,S_F1] = gear_contact(A,BeltWeight,C);                              % Contact stress for gear 1
%disp(['Bending stress for gear no. 1 is :  ' num2str(B_S1) ' Mpa  ']);   % Display bending stres for gear 1
%disp(['Contact stress for gear no. 1 is :  ' num2str(C_S1) ' Mpa  ']);   % Display contact stres for gear 1
%disp(['Safety factor for gear no. 1 is :  ' num2str(S_F1) ' Mpa  ']);    % Display safety factor for gear 1

%% Shaft Design
%From selected gears, 
PinionBore = 1.125;
GearBore = 1.625;
%Shaft Material Constants
%Current Material : 1050 HR 
shaftTensileStrength = 620; %MPa
inchesToM = 25.4/1000;
ExpectedTorqueOnPinion2=FOSOutputTorque/(GearNumberOfTeeth/PinionNumberOfTeeth);
%Preliminary shaft shear check from smallest bore diameter
jShaft=pi*(PinionBore*inchesToM)^4/32;
shearStress = ExpectedTorqueOnPinion2*(GearBore*inchesToM)/jShaft;
FOSShearStrength = 0.75*620e6/shearStress;

