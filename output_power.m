function [RequiredOutputPower,RequiredOuputTorque,RequiredOuputVelocity] = output_power(BlankLoad,BeltMass,Jroller,nRollers,RollerRadius,Speed,Friction)
%This function calculates the required output power, torque, and speed

Tension = (BlankLoad+BeltMass)*9.81*Friction; % N Tension in a horizontal belt is determined by mass of belt, load, and friction
%including efficiency
Efficiency = 0.9;
RunningTorque = RollerRadius * Tension; % N.m (Torque required to run the system)
StartingTorque = RunningTorque*1.2/Efficiency; %N.m 20% FOS & 90% efficiency

%Not used anywhere
RequiredOuputVelocity = Speed*60/(2*pi()*RollerRadius); %Gives the angular velocity in RPM required for linear speed of 0.1m/s
RequiredOuputTorque = StartingTorque;
RequiredOutputPower = (RequiredOuputTorque*RequiredOuputVelocity*pi()*2/60)/1000; %Torque multiplied by W [rad/s] gives power in kW


%Equations sourced from:
%http://www.brighthubengineering.com/manufacturing-technology/83551-onsite-calculations-for-conveyor-belt-systems/
%http://chain-guide.com/basics/2-3-1-coefficient-of-friction.html

end

