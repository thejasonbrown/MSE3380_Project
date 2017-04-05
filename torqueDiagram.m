function [TorqueGear, TorquePinion, GearMidX, PinionMidX] = torqueDiagram(GshoulderX,PshoulderX,FyGear,FzGear,FyPinion, FzPinion,GearDiameter,PinionDiameter,GearWidth, PinionWidth)
% This function calculates the gear and pinion torques and positions of a shaft
% Note: all calculations in this function are done in US Customary Units
GearMidX = GshoulderX-GearWidth/2; %gear is on left, so subtract from where the shoulder is
PinionMidX = PshoulderX+PinionWidth/2;%pinion is on the right, so add half the face width
TorqueGear = FzGear*GearDiameter/2;
TorquePinion = FzPinion*PinionDiameter/2;
if (TorqueGear~=-TorquePinion)
    disp('<strong>Something is wrong, torques in the intermediate shaft are not balanced</strong>');
end
end