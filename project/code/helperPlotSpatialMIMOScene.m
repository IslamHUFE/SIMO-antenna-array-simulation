function helperPlotSpatialMIMOScene(txarraypos,rxarraypos,txcenter,rxcenter,scatpos,wt,wr)
% This function is only in support of ArrayProcessingForMIMOExample. It may
% be removed in a future release.

%   Copyright 2016 The MathWorks, Inc.

narginchk(5,7);

rmax = norm(txcenter-rxcenter);
spacing_scale = rmax/20/mean(diff(txarraypos(2,:)));

txarraypos_plot = txarraypos*spacing_scale+txcenter;
rxarraypos_plot = rxarraypos*spacing_scale+rxcenter;

clf;
hold on;

plot(txarraypos_plot(1,:),txarraypos_plot(2,:),'kv','MarkerSize',10,...
    'MarkerFaceColor','k');
text(txcenter(1)-85,txcenter(2)-15,'TX');
plot(rxarraypos_plot(1,:),rxarraypos_plot(2,:),'kv','MarkerSize',10,...
    'MarkerFaceColor','k');
text(rxcenter(1)+35,rxcenter(2)-15,'RX');
hscat = plot(scatpos(1,:),scatpos(2,:),'ro');
for m = 1:size(scatpos,2)
    plot([txcenter(1) scatpos(1,m)],[txcenter(2) scatpos(2,m)],'b');
    plot([rxcenter(1) scatpos(1,m)],[rxcenter(2) scatpos(2,m)],'b');
end

if nargin > 5
    rbeam = rmax/5;
    txbeam_ang = -90:90;
    txbeam = abs(wt*steervec(txarraypos,txbeam_ang));  % wt row
    txbeam = txbeam/max(txbeam)*rbeam;
    [txbeampos_x,txbeampos_y] = pol2cart(deg2rad(txbeam_ang),txbeam);
    plot(txbeampos_x+txcenter(1),txbeampos_y+txcenter(2),'k');
    rxbeam_ang = [90:180 -179:-90];
    rxbeam = abs(wr.'*steervec(rxarraypos,rxbeam_ang));  % wr column
    rxbeam = rxbeam/max(rxbeam)*rbeam;
    [rxbeampos_x,rxbeampos_y] = pol2cart(deg2rad(rxbeam_ang),rxbeam);
    plot(rxbeampos_x+rxcenter(1),rxbeampos_y+rxcenter(2),'k');
end

axis off;
legend(hscat,{'Scatterers'},'Location','SouthEast');

hold off;
