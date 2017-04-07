function [ inputShaft, intermediateShaft, outputShaft ] = ShaftLoadings(  )
%Weight of Gears
wGear = 125 * -9.81; % check to see if it should be imaginary
wPinion = 4 * -9.81; % check to see if it should be imaginary


%Create shaft objects
inputShaft  = struct('name',  'Input Shaft', ...
    'forces', 0,...
    'shear', 0,...
    'moments', 0,  ...        %
    'diameter', 0,...
    'length', 3);

intermediateShaft  = struct('name',  'Intermediate Shaft', ...
    'forces', 0,...
    'shear', 0,...
    'moments', 0,  ...        %
    'diameter', 0,...
    'length', 4);

outputShaft  = struct('name',  'Output Shaft', ...
    'forces', 0,...
    'shear', 0,...
    'moments', 0,  ...        %
    'diameter', 0,...
    'length', 4);

%Gear Loadings
[inPinionForce,inPinionTorque]=shaftLoading(37.71/0.9, 75.4, 18/5, 20);
[inGearForce,inGearTorque]=shaftLoading(37.71/0.9, -8.5, 32, 20);
[outPinionForce,outPinionTorque]=shaftLoading(37.71/0.9, -8.5, 18/5, 20);
[outGearForce,outGearTorque]=shaftLoading(37.71/0.9, 0.95, 32, 20);

%Assign Gear Loadings
inputShaftGearLoadings = [1 100; 2 200];%[2 inPinionForce+wPinion; 3 inPinionForce+wPinion; 3.5 inPinionForce+wPinion];
intermediateShaftGearLoadings = [3 inGearForce+wGear; 4 outPinionForce+wPinion];
outputShaftGearLoadings = [3 outGearForce+wGear];

%Calculate Bearing Reactions
inputShaftReactions = reactionForces(inputShaftGearLoadings, inputShaft.length);
intermediateShaftReactions = reactionForces(intermediateShaftGearLoadings, intermediateShaft.length);
outputShaftReactions = reactionForces(outputShaftGearLoadings, outputShaft.length);

%Assign Forces
inputShaft.forces = buildForces(inputShaftReactions, inputShaftGearLoadings, inputShaft.length);

%Create Shear Diagrams
inputShaft.shear = shearDiagram(inputShaft.forces);

%Create Moment Diagram
inputShaft.moments = momentDiagram(inputShaft.shear);

end

function [ moment ] = momentDiagram (shear)
moment = zeros(size(shear,1),2);
moment(:,1) = shear(:,1);
moment(1,2) = 0;
    for i=2:size(moment,1)
        moment(i,2) = moment(i-1,2)+shear(i,2)*0.001;
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
torque = power/(RPM*2*pi/60);
end

function [r] = reactionForces(shearLoadings, length)
totShear = sum(shearLoadings(:,2));
totMoment = (shearLoadings(:,1)*25.4/1000)'*shearLoadings(:,2);
r2 = -totMoment/(length*25.4/1000);
r1=-r2-totShear;
r = [r1, r2];
end

function [diameter] = buildDiameter(x, d)
diameter(1,:) = 0:0.001:x(length(x));
start = 1;
for i=1:length(d)
    diameter(2,start:x(i)*1000) = d(i);
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