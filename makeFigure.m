function [  ] = makeFigure( shaft )
figure('name',shaft.name);
hold on

subplot (4,1,1);
plot(shaft.shear(:,1),abs(shaft.shear(:,2)),'-',shaft.shear(:,1),real(shaft.shear(:,2)),'--',shaft.shear(:,1),imag(shaft.shear(:,2)),'--');
title('Shear Diagram')
ylabel('Shear Force [N]');
axis('tight');

subplot (4,1,2);
plot(shaft.moments(:,1),abs(shaft.moments(:,2)),'-',shaft.moments(:,1),real(shaft.moments(:,2)),'--',shaft.moments(:,1),imag(shaft.moments(:,2)),'--');
title('Moment Diagram')
ylabel('Moment [Nm]');
axis('tight');

subplot (4,1,3);
plot(shaft.slope(:,1),abs(shaft.slope(:,2)),'-',shaft.slope(:,1),real(shaft.slope(:,2)),'--',shaft.slope(:,1),imag(shaft.slope(:,2)),'--');
title('Slope Diagram')
ylabel('Angle [Deg]');
axis('tight');

subplot (4,1,4);
plot(shaft.deflection(:,1),abs(shaft.deflection(:,2)),'-',shaft.deflection(:,1),real(shaft.deflection(:,2)),'--',shaft.deflection(:,1),imag(shaft.deflection(:,2)),'--');
title('Deflection Diagram')
ylabel('Deflection [mm]');
axis('tight');

xlabel('X Position [mm]');
legend('Location','southeast', 'Magnitude', 'X-Y Plane', 'X-Z Plane');
end

