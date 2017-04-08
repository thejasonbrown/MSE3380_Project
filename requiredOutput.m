%% Required Output
% Required Output calculates the power, torque, velocity and resolution
% requirements of the drive system, given the problem's parameters

function [OutputTorque,OutputVelocity,OutputPower] = requiredOutput()
%Design Assumptions/Constraints
Gravity = 9.81;
FOS = 0.2;
Speed = 0.1;

%Conveyor Parameters
BeltMass = 75;                % [kg] (Weight of the conveyor belt)
Friction = 0.12;              % (Coefficeint of friction)
RollerRadius = 1;  % [m] (radius of roller = 1 inch)
RollerCircumference = RollerRadius*2*pi; % [m]

%Blanks Parameters
BlankThickness = 0.006;       % [m] (Thickness of blank)
BlankLength = 2.5;            % [m] (Length of blank)
BlankWidth = 0.815;           % [m] (Width of blank)
SteelDensity = 7850;          % [kg/m^3] (Density of 1050 carbon steel) (http://www.azom.com/article.aspx?ArticleID=6526)
nBlanks = 2;                  % Number of blanks on conveyor at a time (1 blank is equivalent to all the blades cut from it)
BlankMass = BlankThickness*BlankLength*BlankWidth*SteelDensity;  %[kg] (Mass of one blank)
BlankLoad = BlankMass*nBlanks; % [kg] (Total mass of all blanks on conveyor)

%Loading Calculations
TotalMass = BlankLoad + BeltMass;
Force = TotalMass*Gravity*Friction; % [N] Tension in a horizontal belt is determined by mass of belt, load, and friction
TheoreticalOutputTorque = RollerRadius * Force; % [N.m], Torque required to run the system
AngularVelocity = Speed*2*pi/RollerCircumference; % [rad/s] Required for a linear speed of 0.1m/s

%Output Requirements
OutputTorque = TheoreticalOutputTorque * (1 + FOS); % [N.m], 20% FOS for unexpected loadings
OutputVelocity = Speed*60/(2*pi); % [RPM] Gives the angular velocity in RPM required for linear speed of 0.1m/s
OutputPower = OutputTorque*AngularVelocity; % [w] Torque multiplied by W [rad/s] gives power in kW

end