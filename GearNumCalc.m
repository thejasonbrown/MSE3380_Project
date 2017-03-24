function [MaxGearTeeth] = GearNumCalc(k,pinionTeeth,PressureAngle)
MaxGearTeeth= floor((pinionTeeth^2*(sind(PressureAngle))^2-4*k^2)/(4*k-2*pinionTeeth*(sind(PressureAngle))^2));
end