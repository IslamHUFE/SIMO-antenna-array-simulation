function nber = helperMIMOBER(chan,x,snr_param,wt,wr)
% This function is only in support of ArrayProcessingForMIMOExample. It may
% be removed in a future release.

%   Copyright 2016 The MathWorks, Inc.

Nsamp = size(x,1);
Nrx = size(chan,2);
Ntx = size(chan,1);

if nargin < 4
    wt = ones(1,Ntx);
end

if nargin < 5
    wr = ones(Nrx,1);
end

xt = 1/sqrt(Ntx)*(2*x-1)*wt; % map to bpsk
nber = zeros(size(snr_param),'like',1); % real

for m = 1:numel(snr_param)
    n = sqrt(db2pow(-snr_param(m))/2)*(randn(Nsamp,Nrx)+1i*randn(Nsamp,Nrx));
    y = xt*chan*wr+n*wr;
    xe = real(y)>0;
    nber(m) = sum(x~=xe);
end


