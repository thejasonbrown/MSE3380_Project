function [RequiredOutputPower,RequiredOuputTorque,RequiredOuputVelocity] = output_power(BlankLoad,BeltMass,Jroller,nRollers,RollerRadius,Speed,Friction)
%This function calculates the required output power, torque, and speed

Tension = (BlankLoad+BeltMass)*9.81*Friction; % N Tension in a horizontal belt is determined by mass of belt, load, and friction

RunningTorque = RollerRadius * Tension; % N.m (Torque required to run the system)
StartingTorque = RunningTorque * 2; %N.m (mulitply RunningTorque by 200 percent: http://www.motorsanddrives.com/cowern/motorterms7.html)

Jtotal = (Jroller * nRollers) + (BlankLoad * RollerRadius^2) + (BeltMass * RollerRadius^2); % kg.m^2 Total inertia of the loads and conveyor

RequiredOuputVelocity = Speed*60/(2*pi()*RollerRadius); %Gives the angular velocity in RPM required for linear speed of 0.1m/s
RequiredOuputTorque = StartingTorque;
RequiredOutputPower = (RequiredOuputTorque*RequiredOuputVelocity*pi()*2/60)/1000; %Torque multiplied by W [rad/s] gives power in kW

%Including efficiency
Efficiency = 0.9;
RequiredOutputPower = RequiredOutputPower/Efficiency;

%Equations sourced from:
%http://www.brighthubengineering.com/manufacturing-technology/83551-onsite-calculations-for-conveyor-belt-systems/
%http://chain-guide.com/basics/2-3-1-coefficient-of-friction.html

end

