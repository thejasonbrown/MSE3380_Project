function [ PinionNumberOfTeeth, GearNumberOfTeeth ] = GearTeethCalculator( DesiredGearingRatio, PressureAngle, k, RequiredOutputVelocity)
%Making a 2 stage gearbox with minimal package size, therefore must sqrt
m = sqrt(DesiredGearingRatio);

%Using formula 13-11 on Page 678
PotentialGearingRatio=1;

[PinionNumberOfTeeth, MaxGearNumberOfTeeth]=Iterate(PotentialGearingRatio, DesiredGearingRatio, PressureAngle, m);

% To display values, delete semi-colons
MaxGearNumberOfTeeth;
PinionNumberOfTeeth;
GearNumberOfTeeth = round(PinionNumberOfTeeth*m);
ActualGearingRatio = (GearNumberOfTeeth/PinionNumberOfTeeth)^2;
ActualInputSpeed = ActualGearingRatio*RequiredOutputVelocity;

end

function [PinionNumberOfTeeth, MaxGearNumberOfTeeth] = Iterate(PotentialGearingRatio, DesiredGearingRatio, PressureAngle, m)

while(PotentialGearingRatio<=(DesiredGearingRatio))
    PinionNumberOfTeeth = PinionNumCalc (1,PressureAngle,m);
    if(PinionNumberOfTeeth==17)
        PinionNumberOfTeeth=PinionNumberOfTeeth + 1;
    end
    MaxGearNumberOfTeeth = GearNumCalc(1,PinionNumberOfTeeth,PressureAngle);
    if(MaxGearNumberOfTeeth < 0)
        MaxGearNumberOfTeeth = 'Infinite';
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