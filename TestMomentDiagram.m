%%Testing moment diagram function

%Gy=197lbf
%gz=540
%Py=885lbf
%Pz=2431
%shaft length between bearings = 
Gy=-197;
Gz=540;
Py=-885;
Pz=-2431;
ShaftLength=10.75-0.75;
ShaftLength=ShaftLength/12
GWidth = 3.5-2;
GWidth=GWidth/12;
PWidth=9.5-7.5;
PWidth=PWidth/12;
Gshoulder=3.5-0.75;
Gshoulder=Gshoulder/12;
Pshoulder=7.5-0.75;
Pshoulder=Pshoulder/12;
Gdiameter = 12/12;
PDiameter = 2.67/12;
GearMidX = Gshoulder-GWidth/2;
PinionMidX = Pshoulder+PWidth/2;
%ComputeMomentDiagram(ShaftLength,FyGear,FzGear,GearMidX, FyPinion,FzPinion,PinionMidX,PinionWidth)
[MomentG,MomentI,MomentJ,MomentK]=ComputeMomentDiagram(ShaftLength,Gy,Gz,GearMidX, Py,Pz,PinionMidX,PWidth);


[reqOutputTorque,reqOutputVelocity,reqOutputPower] = requiredOutput();

% Required output power, Torque and Speed
disp('<strong>Moments</strong>')
disp(['Moment@G: ' num2str(MomentG, 4) ' [UnitsForce*UnitsLength] ']);        % Display the moment there
disp(['Moment@I: ' num2str(MomentI, 4) ' [UnitsForce*UnitsLength] ']);        % Display the moment there
disp(['Moment@J: ' num2str(MomentJ, 4) ' [UnitsForce*UnitsLength] ']);        % Display the moment there
disp(['Moment@K: ' num2str(MomentK, 4) ' [UnitsForce*UnitsLength] ']);        % Display the moment there