function [MomentG, MomentI, MomentJ, MomentK] = ComputeMomentDiagram(ShaftLength,FyGear,FzGear,GearMidX, FyPinion,FzPinion,PinionMidX,PinionWidth)
% This function calculates the gear and pinion torques and positions of a shaft
% Note: all calculations in this function are done in US Customary Units
%Necessary inputs
%ShaftLength,GearFy,GearFz,GearMidX, PinionFy,PinionFz,PinionMidX,PinionWidth
PshoulderX=PinionMidX-PinionWidth/2;
[zForceBearing1, zForceBearing2,yForceBearing1, yForceBearing2]=BearingReactionForces(ShaftLength,GearMidX,PinionMidX,FyGear,FzGear,FyPinion, FzPinion);
[Shear1y, Shear2y, Shear3y] = ShearDiagram(FyGear,FyPinion,yForceBearing1,yForceBearing2);
[Shear1z, Shear2z, Shear3z] = ShearDiagram(FzGear,FzPinion,zForceBearing1,zForceBearing2);
[yMomentG, yMomentI, yMomentJ, yMomentK] = MomentDiagram(Shear1y,Shear2y,Shear3y,GearMidX,PshoulderX,PinionMidX,ShaftLength);
[zMomentG, zMomentI, zMomentJ, zMomentK] = MomentDiagram(Shear1z,Shear2z,Shear3z,GearMidX,PshoulderX,PinionMidX,ShaftLength);
[MomentG, MomentI, MomentJ, MomentK] = TotalMomentDiagram(yMomentG,yMomentI,yMomentJ,yMomentK,zMomentG,zMomentI,zMomentJ,zMomentK);
end

function [zForceBearing1, zForceBearing2,yForceBearing1, yForceBearing2] = BearingReactionForces(ShaftLength,GearMidX, PinionMidX,FyGear,FzGear,FyPinion, FzPinion)
% This function calculates the gear and pinion torques and positions of a shaft
% Note: all calculations in this function are done in US Customary Units
yForceBearing2 = (-FyGear*GearMidX-FyPinion*PinionMidX)/ShaftLength;
zForceBearing2 = (-FzGear*GearMidX-FzPinion*PinionMidX)/ShaftLength;
yForceBearing1 = -yForceBearing2-FyGear - FyPinion;
zForceBearing1 = -zForceBearing2-FzGear - FzPinion;
end

function [Shear1, Shear2, Shear3] = ShearDiagram(FGear,FPinion,FBearing1,FBearing2)
% This function calculates the gear and pinion torques and positions of a shaft
% Note: all calculations in this function are done in US Customary Units
%Shear1 - between bearing 1 - Gear
%Shear2 - between Gear  - Pinion
%Shear3 - between Pinion - Bearing2

Shear1 = FBearing1;
Shear2 = Shear1+FGear;
Shear3 = Shear2+FPinion;
if ((Shear3+FBearing2)~=0)
    disp('<strong>Something is wrong, shear forces in the shaft are not balanced</strong>');
end
end

function [MomentG, MomentI, MomentJ, MomentK] = MomentDiagram(Shear1,Shear2,Shear3,GearMidX, PshoulderX, PinionMidX, ShaftLength)
% This function calculates the gear and pinion torques and positions of a shaft
% Note: all calculations in this function are done in US Customary Units
%MomentG - Moment at GearMiddle
%MomentI - Moment at Pinion Shoulder
%MomentJ - Moment at PinionMiddle
%MomentK - Moment at far pinion edge (Highest x value)
PinionWidth = (PinionMidX -PshoulderX)*2;
MomentG = Shear1*GearMidX;
MomentI = MomentG +(PshoulderX-GearMidX)*(Shear2);
MomentJ = MomentG +(PinionMidX-GearMidX)*Shear2;
MomentK = MomentJ + (PinionWidth/2)*Shear3;
Bearing2Moment = MomentJ + (ShaftLength-PinionMidX)*Shear3;
if (Bearing2Moment>0.0000001*MomentG)%Making sure that the moment at bearing 2 is a very small amount
    disp('<strong>Something is wrong, moments in the shaft are not balanced</strong>');
end
end

function [MomentG, MomentI, MomentJ, MomentK] = TotalMomentDiagram(yMomentG,yMomentI,yMomentJ,yMomentK,zMomentG,zMomentI,zMomentJ,zMomentK)
% This function calculates the gear and pinion torques and positions of a shaft
% Note: all calculations in this function are done in US Customary Units
%MomentG - Moment at GearMiddle
%MomentI - Moment at Pinion Shoulder
%MomentJ - Moment at PinionMiddle
%MomentK - Moment at far pinion edge (Highest x value)
MomentG = sqrt(yMomentG^2+zMomentG^2);
MomentI = sqrt(yMomentI^2+zMomentI^2);
MomentJ = sqrt(yMomentJ^2+zMomentJ^2);
MomentK = sqrt(yMomentK^2+zMomentK^2);

end