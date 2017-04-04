%% Gear Teeth Calculator
% Using an iterative function, GearTeethCalculator solves for the smallest
% pinion size that has a zero interference fit with a gear large enough to
% achieve, at minimum, the desired gearing ratio (using equal gearing in a
% two stage speed reducer)

function [PinionNumberOfTeeth,GearNumberOfTeeth] = GearTeethCalculator(DesiredGearingRatio)
% Design Assumptions
PressureAngle = 20;         % [deg]
k = 1;                      % Full tooth depth

% Calculate stage gearing ratio
m = sqrt(DesiredGearingRatio); % Equal gearing ratio for a two stage speed reducer

% Output
PinionNumberOfTeeth=Iterate(DesiredGearingRatio, PressureAngle, m, k);
GearNumberOfTeeth = round(PinionNumberOfTeeth*m);
end

% Loop until a gearing pairing with zero interference is found, with an
% appropriate gear ratio
function [PinionNumberOfTeeth] = Iterate(DesiredGearingRatio, PressureAngle, m, k) %#ok<INUSD>
PotentialGearingRatio=1;
while(PotentialGearingRatio<=(DesiredGearingRatio))
    PinionNumberOfTeeth = PinionNumCalc (1,PressureAngle,m);
    if(PinionNumberOfTeeth==17) %skip 17 pinion teeth as it is not a standard size
        PinionNumberOfTeeth=PinionNumberOfTeeth + 1;
    end
    MaxGearNumberOfTeeth = GearNumCalc(1,PinionNumberOfTeeth,PressureAngle);
    if(MaxGearNumberOfTeeth < 0)
        MaxGearNumberOfTeeth = 'Infinite'; %#ok<NASGU> 
        break
    end
    PotentialGearingRatio = (MaxGearNumberOfTeeth/PinionNumberOfTeeth)^2;
end
end

function [pinionTeeth] = PinionNumCalc(k,PressureAngle,m)
%Formula 13-11
pinionTeeth = ceil(2*k/((1+2*m)*(sind(PressureAngle))^2)*(m+sqrt(m^2+(1+2*m)*(sind(PressureAngle))^2)));
end

function [MaxGearTeeth] = GearNumCalc(k,pinionTeeth,PressureAngle)
%Formula 13-12
MaxGearTeeth= floor((pinionTeeth^2*(sind(PressureAngle))^2-4*k^2)/(4*k-2*pinionTeeth*(sind(PressureAngle))^2));
end