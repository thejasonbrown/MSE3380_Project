function [ slope, deflection ] = getDeflection( shaft, E )

dslope(:,1) = shaft.moments(:,1);
dslope(:,2) = shaft.moments(:,2)./(E * (pi*(shaft.diameter(:,2)/1000).^4/64));

slope (:,1) = dslope(:,1);
slope (:,2) = cumtrapz(dslope(:,1).*1e-6,dslope(:,2));

deflection(:,1) = slope(:,1);
deflection(:,2) = cumtrapz(slope(:,1).*1e-6,slope(:,2));

%Correction for center
c = deflection(end,2)/(deflection(end,1)*1e-6);
slope(:,2) = slope(:,2)-c;
deflection(:,2) = cumtrapz(slope(:,1).*1e-6,slope(:,2))*1000;
slope(:,2) = slope(:,2)*180/pi;
end

