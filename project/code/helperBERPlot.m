function helperBERPlot(ebn0,ber)
% This function is only in support of ArrayProcessingForMIMOExample. It may
% be removed in a future release.

%   Copyright 2016 The MathWorks, Inc.

h = semilogy(ebn0,ber);
set(gca,'YMinorGrid','on','XMinorGrid','on');
markerparam = {'x','+','^','v'};
for m = 1:numel(h)
    h(m).Marker = markerparam{m};
end
xlabel('E_b/N_0 (dB)');
ylabel('BER');
ylim([9e-6 1]);
