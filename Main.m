%% PROJECT      Stepper Motor Gearbox Design
%
% Group No.     9    
% Members       Michael Gerard Allan, Jason Michael Brown, Kaspar Shah Shahzada, Joshua Graham Underwood
% Course        Mechanical Components Design for Mechatronic Systems (MSE 3380)
% Instructor    Prof. Dr. Aaron Price
% Department    Mechanical & Materials Engineering
% Faculty       Engineering
% Institution   Western University
% Date          March 17, 2017

%% Clear workspace
close all
evalin('caller','clear all');
feature('accel','on')
clc

%% Design constraints
% To insert design contrain values

%Conveyor Parameters
BeltMass = 75;              % kg (Weight of the conveyor belt)
ConveyorLength = 6;           % m (Length of top edge of conveyor)
Friction = 0.12;              % (Coefficeint of friction)

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

%Roller Parameters (Using Conveyor Roller Model 2013 found here:
%http://www.rolmasterconveyors.ca/products/conveyor-rollers/)
RollerRadius = 0.0254;            % m (radius of roller = 1 inch)
RollerLength = 0.815;             % m (given)
RollerDensity = 7850;             % kg/m^3 (assume same density as blanks)
nRollers = 2;                     % Number of rollers in the conveyor
Jroller = pi()*RollerDensity*RollerLength*((RollerRadius*2)^2)/32;


%% Required power
% To use a defined function titled "output_power" to calculate and display
% required power and torque for the motor as well as respective speed

[RequiredOutputPower,RequiredOutputTorque,RequiredOutputVelocity] = output_power(BlankLoad,BeltMass,Jroller,nRollers,RollerRadius,Speed,Friction);                        % Required output power, Torque and Speed
disp(['Required output power:  ' num2str(RequiredOutputPower) ' kW  ']);              % Display the required output power
disp(['Required output torque: ' num2str(RequiredOutputTorque) ' N.m ']);              % Display the required output torque
disp(['Required speed:   ' num2str(RequiredOutputVelocity) ' rpm ']);                     % Display the required speed

%% Motor choice
% To show the selected motor spec. from the catalogue 


%Based on calculations and with a assumed gearing of x10, this motor was
%the best fit

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
DesiredGearingRatio = 1/18.5;%picked because of design choices
PossibleInputSpeed = RequiredOutputVelocity * DesiredGearingRatio;
%Making a 2 stage gearbox with minimal package size, therefore must sqrt
Ratio1 = sqrt(DesiredGearingRatio);
k = 1; %picked because of design choices
PressureAngle = 20; %picked because of design choices
m = 1/Ratio1;
%Using formula 13-11 on Page 678
PinionNumberOfTeeth = round(2*k/((1+2*m)*(sind(PressureAngle))^2)*(m+sqrt(m^2+(1+2*m)*(sind(PressureAngle))^2))) %15
GearNumberOfTeeth = round(PinionNumberOfTeeth * m) %47

%15 and 47 are both common numbers of teeth according to:
%http://opis.cz/cross-morse/pdf/StandardGears.pdf
ActualGearingRatio = (GearNumberOfTeeth/PinionNumberOfTeeth)^2
ActualInputSpeed = ActualGearingRatio*RequiredOutputVelocity


%[B_S1,S_F1] = gear_bending(A,B,C);                                   % Bending stress for gear 1
%[C_S1,S_F1] = gear_contact(A,BeltWeight,C);                                   % Contact stress for gear 1
%disp(['Bending stress for gear no. 1 is :  ' num2str(B_S1) ' Mpa  ']);   % Display bending stres for gear 1
%disp(['Contact stress for gear no. 1 is :  ' num2str(C_S1) ' Mpa  ']);   % Display contact stres for gear 1
%disp(['Safety factor for gear no. 1 is :  ' num2str(S_F1) ' Mpa  ']);    % Display safety factor for gear 1

