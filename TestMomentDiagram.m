%%Testing moment diagram function
%Units force are in lbf
%Units distance are in inches
Gy=-197;
Gz=540;
Py=-885;
Pz=-2431;
ShaftLength=10.75-0.75;
GearDiameter = 12;
PinionDiameter = 2.67;
GWidth = 3.5-2;
PWidth=9.5-7.5;
Gshoulder=3.5-0.75;
Pshoulder=7.5-0.75;
[TorqueGear, TorquePinion, GearMidX, PinionMidX] = torqueDiagram(Gshoulder,Pshoulder,Gz,Pz,GearDiameter,PinionDiameter,GWidth, PWidth);
MidrangeTorqueG = TorqueGear;
MidrangeTorqueI = TorqueGear;
MidrangeTorqueJ = TorquePinion;
MidrangeTorqueK = 0;
%ComputeMomentDiagram(ShaftLength,FyGear,FzGear,GearMidX, FyPinion,FzPinion,PinionMidX,PinionWidth)
[MomentG,MomentI,MomentJ,MomentK]=ComputeMomentDiagram(ShaftLength,Gy,Gz,GearMidX, Py,Pz,PinionMidX,PWidth);


[reqOutputTorque,reqOutputVelocity,reqOutputPower] = requiredOutput();

% Required output power, Torque and Speed
disp('<strong>Moments</strong>')
disp(['Moment@G: ' num2str(MomentG, 4) ' [UnitsForce*UnitsLength] ']);        % Display the moment there
disp(['Moment@I: ' num2str(MomentI, 4) ' [UnitsForce*UnitsLength] ']);        % Display the moment there
disp(['Moment@J: ' num2str(MomentJ, 4) ' [UnitsForce*UnitsLength] ']);        % Display the moment there
disp(['Moment@K: ' num2str(MomentK, 4) ' [UnitsForce*UnitsLength] ']);        % Display the moment there