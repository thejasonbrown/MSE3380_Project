function [pinionTeeth] = PinionNumCalc(k,PressureAngle,m)
pinionTeeth = ceil(2*k/((1+2*m)*(sind(PressureAngle))^2)*(m+sqrt(m^2+(1+2*m)*(sind(PressureAngle))^2))); %15
end