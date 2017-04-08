function [FOSOutputPower,FOSOutputTorque,RequiredOutputVelocity] = output_power(BlankLoad,BeltMass,RollerRadius,Speed,Friction)
%This function calculates the required output power, torque, and speed
%(including factor of safety)
Gravity = 9.81;
TotalMass = BlankLoad + BeltMass;

Force = TotalMass*Gravity*Friction; % N Tension in a horizontal belt is determined by mass of belt, load, and friction
TheoreticalOutputTorque = RollerRadius * Force; % N.m, Torque required to run the system
FOSOutputTorque = TheoreticalOutputTorque*1.2; %N.m, 20% FOS

RequiredOutputVelocity = Speed*60/(2*pi*RollerRadius); %Gives the angular velocity in RPM required for linear speed of 0.1m/s

FOSOutputPower = FOSOutputTorque*RequiredOutputVelocity*(2*pi/60)/1000; %Torque multiplied by W [rad/s] gives power in kW

end