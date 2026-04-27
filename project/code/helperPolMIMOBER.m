function nber = helperPolMIMOBER(chan,x,snr_param)
% This function is only in support of ArrayProcessingForMIMOExample. It may
% be removed in a future release.

%   Copyright 2024 The MathWorks, Inc.

Nsamp = size(x,1);
Nrx = 2;

xt = (2*x-1).*[1 -1]; % map to bpsk, column reverse because of polarization
nber = zeros(2,numel(snr_param),'like',1); % real

for m = 1:numel(snr_param)
    n = sqrt(db2pow(-snr_param(m))/2)*(randn(Nsamp,Nrx)+1i*randn(Nsamp,Nrx));
    y = 2*(chan(xt)>0)-1;
    xe = real(y+n)>0;
    nber(:,m) = sum(x~=xe,1);
end


