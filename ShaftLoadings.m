function [ inputShaft, intermediateShaft, outputShaft ] = ShaftLoadings(  )
%Weight of Gears
wGear = 125 * -9.81; % check to see if it should be imaginary
wPinion = 4 * -9.81; % check to see if it should be imaginary

E = 200e9; % [Pa] AISI 1050 CD Steel

%Create shaft objects
inputShaft  = struct('name',  'Input Shaft', ...
    'forces', 0,... % [N]
    'shear', 0,... % [N]
    'moments', 0,  ...   % [N.m]
    'slope', 0,  ...   % [rad]
    'deflection', 0,  ...   % [mm]
    'diameter', 0,...   % [mm]
    'torque', 0,... % [N*m]
    'length', 144.65); % [mm]

intermediateShaft  = struct('name',  'Intermediate Shaft', ...
    'forces', 0,...
    'shear', 0,...
    'moments', 0,  ...        
    'slope', 0,  ... 
    'deflection', 0,  ...   
    'diameter', 0,...  
    'torque', 0,...
    'length', 219.3);

outputShaft  = struct('name',  'Output Shaft', ...
    'forces', 0,...
    'shear', 0,...
    'moments', 0,  ... 
    'slope', 0,  ...   
    'deflection', 0,  ...  
    'diameter', 0,...   
    'torque', 0,...
    'length', 189.3);

outputBearingDiameter = 28;
outputBearingShoulder = 35;     % Hard coded, found in Excel
inputBearingDiameter = 17;
inputBearingShoulder = 22;      % Hard coded, found in Excel
intermediateBearingDiameter = 17;
intermediateBearingShoulder = 22;      % Hard coded, found in Excel
outputShaft.diameter = buildDiameter ([4.65,54.65,59.65,179.65,184.65,189.30],[outputBearingDiameter,outputBearingShoulder,61.92,41.28,outputBearingShoulder,outputBearingDiameter]);%Build the output shaft profile.
inputShaft.diameter = buildDiameter ([4.65,8.65,108.65,113.65,140,144.65],[inputBearingDiameter,inputBearingShoulder,28.58,42.87,inputBearingShoulder,inputBearingDiameter]);%Build the input shaft profile.
intermediateShaft.diameter = buildDiameter([4.65 9.65 129.65 134.65 159.65 209.65 214.65 219.3], [intermediateBearingDiameter intermediateBearingShoulder 41.28 49.53 34.29 28.58 intermediateBearingShoulder intermediateBearingDiameter]);

%Gear Loadings
[inPinionForce,inPinionTorque]=shaftLoading(37.71/0.9, 75.4, 18/5, 20);
[inGearForce,inGearTorque]=shaftLoading(37.71/0.9, -8.5, 32, 20);
[outPinionForce,outPinionTorque]=shaftLoading(37.71/0.9, -8.5, 18/5, 20);
[outGearForce,outGearTorque]=shaftLoading(37.71/0.9, 0.95, 32, 20);

%Assign Gear Loadings
inputShaft.torque = inPinionTorque;
outputShaft.torque = outGearTorque;
intermediateShaft.torque = inGearTorque;

inputShaftGearLoadings = [69.1 inPinionForce+wPinion];
intermediateShaftGearLoadings = [97.9 inGearForce+wGear; 191.4 outPinionForce+wPinion];
outputShaftGearLoadings = [91.4 outGearForce+wGear];

%Calculate Bearing Reactions
inputShaftReactions = reactionForces(inputShaftGearLoadings, inputShaft.length);
intermediateShaftReactions = reactionForces(intermediateShaftGearLoadings, intermediateShaft.length);
outputShaftReactions = reactionForces(outputShaftGearLoadings, outputShaft.length);

%Assign Forces
inputShaft.forces = buildForces(inputShaftReactions, inputShaftGearLoadings, inputShaft.length);
outputShaft.forces = buildForces(outputShaftReactions, outputShaftGearLoadings, outputShaft.length);
intermediateShaft.forces = buildForces(intermediateShaftReactions, intermediateShaftGearLoadings, intermediateShaft.length);


%Create Shear Diagrams
inputShaft.shear = shearDiagram(inputShaft.forces);
outputShaft.shear = shearDiagram(outputShaft.forces);
intermediateShaft.shear = shearDiagram(intermediateShaft.forces);

%Create Moment Diagram
inputShaft.moments = momentDiagram(inputShaft.shear);
outputShaft.moments = momentDiagram(outputShaft.shear);
intermediateShaft.moments = momentDiagram(intermediateShaft.shear);

%Add deflection
[inputShaft.slope, inputShaft.deflection]=getDeflection(inputShaft, E);
[outputShaft.slope, outputShaft.deflection]=getDeflection(outputShaft, E);
[intermediateShaft.slope, intermediateShaft.deflection]=getDeflection(intermediateShaft, E);


end

function [ moment ] = momentDiagram (shear)
moment = zeros(size(shear,1),2);
moment(:,1) = shear(:,1);
moment(1,2) = 0;
for i=2:size(moment,1)
    moment(i,2) = moment(i-1,2)+shear(i,2)*0.001/1000;
end
end

function [ shear ] = shearDiagram (forces)
shear = zeros(size(forces,1),2);
shear(:,1) = forces(:,1);
shear(1,2) = -forces(1,2);
for i=2:size(shear,1)
    shear(i,2) = shear(i-1,2)-forces(i,2);
end
end

function [ shear, torque ] = shaftLoading( power, RPM, pitchDiameter, pitchAngle)
V = (pitchDiameter*25.4/1000) * (RPM*pi/60);
wt = power/V;

shear = wt + 1i* wt * sind(pitchAngle);
torque = power/((RPM*2*pi)/(60));
end

function [r] = reactionForces(shearLoadings, length)
totShear = sum(shearLoadings(:,2));
totMoment = (shearLoadings(:,1)/1000)'*shearLoadings(:,2);
r2 = -totMoment/(length/1000);
r1=-r2-totShear;
r = [r1, r2];
end

function [diameter] = buildDiameter(x, d)
diameter(1,:) = 0:0.001:x(length(x));
start = 1;
for i=1:length(d)
    diameter(2,start:x(i)*1000+1) = d(i);
    start = x(i)*1000;
end
diameter = diameter';
end

function [forces] = buildForces(reactions, gears, length)
forces(1,:) = 0:0.001:length;
forces(2,1) = reactions(1);
for i=1:size(gears,1)
    forces(2,gears(i,1)*1000) = gears(i,2);
end
forces(2,size(forces,2))=reactions(2);
forces = forces';
end