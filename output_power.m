function [Po,To,W] = output_power(BlankLoad,BeltMass,Jroller,nRollers,RollerRadius)
%This function calculates the required output power, torque, and speed

Jtotal = (Jroller * nRollers) + (BlankLoad * RollerRadius^2) + (BeltMass * RollerRadius^2); %Total inertia of the loads and conveyor

W = Speed*60/(2*pi()*RollerRadius) %Gives the angular velocity in RPM required for linear speed of 0.1m/s
To = 0;
Po = To*W*pi()/30 %Torque multiplied by W [rad/s] gives power

end

