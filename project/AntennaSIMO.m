c = 3e8;                                                    %speed of light
fc = 60e9;                                               %carrier frequency
lambda = c / fc;                                       %carrier wave length

%% Transmitter and reciver coordinates

txcenter = [0;0;0];                                  %Tx center coordinates 
rxcenter = [1500;500;0];                             %Rx center coordinates
%{
┌─Note────────────────────────────────────────────────────────────────────┐
│ The distance between the centers of Tx and Rx is equal to 1581.14 meter │
└─────────────────────────────────────────────────────────────────────────┘
%}
%      ↙ the index that the rangeangle function will put the angel into
[~,txang] = rangeangle(rxcenter,txcenter);      %The angle the Tx sees Rx's
                                                %location

[~,rxang] = rangeangle(txcenter,rxcenter);      %The angle the Rx sees Tx's
% ↖the range (we don't need it so we put ~)     %location


%% Generation of the data
rng(6466);                                                %random generator
%     ↖seed number for the random numbers generator

Nsamp = 1e6;                                             %number of samples

x = randi([0 1],Nsamp,1);  %x is a vector represents a random sequence of a
                           %1,000,000 (Nsamp) binary values {0,1}
                         
%% SISO LOS channel

%{
┌─Note───────────────────────────────────────────────────────────────┐
│ before getting into SIMO we will first simulat SISO so we will use │
│ a single antenna for both the The Tx and the Rx                    │
└────────────────────────────────────────────────────────────────────┘
%}

txsipos = [0;0;0];                 % single antenna at the center of the Tx
rxsopos = [0;0;0];                 % single antenna at the center of the Rx

g = 1;                                          %the gain of the channel

sisochan = scatteringchanmtx(txsipos,rxsopos,txang,rxang,g); %generating
                                                                %the
                                                                %channel
                                                                %matrix
%{
┌─scatteringchanmtx───────────────────────────────────────────────────────┐
│ A function from Phased Array System Toolbox builds the wireless channel │ 
│ array based on the Scattering Model.                                    │
┌─scattering model────────────────────────────────────────────────────────┐
│ is a model that describes the scattering of radio waves in complex      │
│ environments.                                                           │
└─────────────────────────────────────────────────────────────────────────┘
%}

ebn0_param = -10:2:10;        %ebn0_param = [-10 -8 -6 -4 -2 0 2 4 6 8 10];
%             ▲  ▲ ▲       
%             │  │ └─── start ┌─Eb/N₀─────────────────────────────────────┐
%             │  └─────  step │ The power of a single bit (Eb) divided by │
%             └────────   end │ the spectral noise power density (N₀).    │
%                             └───────────────────────────────────────────┘


Nsnr = numel(ebn0_param);             %number of ebn0_param's elements (11)

ber_siso = helperMIMOBER(sisochan,x,ebn0_param)/Nsamp;%calculat the BER for
% we devide by the number of samples because the↗     %each Eb/N₀ for the
% helperMIMOBER function add all valeus for all       %SISO communication
%bits                                                 %system
%{           
┌─helperMIMOBER──────────────────────────────────────────────────────────┐
│ this is a function related to the project in the same directory of the │
│ main file.                                                             │
│ it calculates the Bit error rate (BER)                                 │
│ and it takes:                                                          │
│              1- scattering model array (sisochan)                      │
│              2- the origonal data the Tx are transmitting (x)          │
│              3- Eb/N₀ (ebn0_param)                                     │
│ in our case we are using more than Eb/N₀, so the                       │
│ function will return the calculation for each value                    │
│ in an array                                                            │
└────────────────────────────────────────────────────────────────────────┘
%}

helperBERPlot(ebn0_param,ber_siso);           %plot each BER for each Eb/N₀
legend('SISO');
%exportgraphics(gcf,'SISO_BER.pdf','ContentType','vector');     %export PDF

%% SIMO LOC channel

rxarray = phased.ULA('NumElements',4,'ElementSpacing',lambda/2);
%                  ↖Uniform liner array
%{
┌─Note──────────────────────────────────────────────────────────────┐
│ the function above makes a liner array of four antennas at the Rx │
│ instade of the single array we put for the SISO system Rx         │
└───────────────────────────────────────────────────────────────────┘
%}
 
rxmopos = getElementPosition(rxarray)/lambda;   %returns the coordinate for 
                                                %each antenna at the Rx


%                     ┌Note──────────────┐
%                     │ we use single Tx │
%                     │ antenna for SIMO │          
%                     └──────────────────┘
%                              ↓
simochan = scatteringchanmtx(txsipos,rxmopos,txang,rxang,g); %generating
%here we use the new antenna array for↗                         %the
%the Rx instade of the single antenna                           %channel
                                                                %matrix

rxarraystv = phased.SteeringVector('SensorArray',rxarray,... %%%%%%%%%%%%%%
    'PropagationSpeed',c);                                   %%%%%%%%%%%%%%
wr = conj(rxarraystv(fc,rxang));                             %%%%%%%%%%%%%%


ber_simo = helperMIMOBER(simochan,x,ebn0_param,1,wr)/Nsamp;  %calculat the
                                                             %BER for each
                                                             %Eb/N₀ for the
                                                             %SIMO
                                                             %communication
                                                             %system

helperBERPlot(ebn0_param,[ber_siso(:) ber_simo(:)]);%plot each BER for
legend('SISO','SIMO')                               %each Eb/N₀ for SISO
                                                    %and SIMO

%exportgraphics(gcf,'SISO_SIMO_BER.pdf','ContentType','vector');

%% MISO LOC channel

txarray = phased.ULA('NumElements',4,'ElementSpacing',lambda/2);
%{
┌─Note──────────────────────────────────────────────────────────────┐
│ the function above makes a liner array of four antennas at the Tx │
│ instade of the single array we put for the SISO system Tx         │
└───────────────────────────────────────────────────────────────────┘
%}
txmipos = getElementPosition(txarray)/lambda;   %returns the coordinate for 
                                                %each antenna at the Rx

misochan = scatteringchanmtx(txmipos,rxsopos,txang,rxang,g); %generating
%here we use the new antenna ↗          ↑                       %the
%array for the Tx instade of      ┌Note──────────────┐          %channel
%the single antenna               │ we use single Rx │          %matrix
%                                 │ antenna for MISO │          
%                                 └──────────────────┘

txarraystv = phased.SteeringVector('SensorArray',txarray,... %%%%%%%%%%%%%%
    'PropagationSpeed',c);                                   %%%%%%%%%%%%%%
wt = txarraystv(fc,txang)';                                  %%%%%%%%%%%%%%

ber_miso = helperMIMOBER(misochan,x,ebn0_param,wt,1)/Nsamp;  %calculat the
                                                             %BER for each
                                                             %Eb/N₀ for the
                                                             %MISO
                                                             %communication
                                                             %system



helperBERPlot(ebn0_param,[ber_siso(:) ber_simo(:) ber_miso(:)]);%plot each
legend('SISO','SIMO','MISO')                                    %BER for
                                                                %each Eb/N₀
                                                                %for SISO,
                                                                %SIMO and
                                                                %MISO
%exportgraphics(gcf,'SISO_SIMO_MISO_BER.pdf','ContentType','vector');

%% MIMO LOS Channel

mimochan = scatteringchanmtx(txmipos,rxmopos,txang,rxang,g);    %generating
%{
┌─Note─────────────────────────────────────────────────────────────────┐
│ we alredy made the antenna array for the SIMO and the MISO so we can │
│ use it for the scatteringchanmtx function                            │
└──────────────────────────────────────────────────────────────────────┘
%}

wt = txarraystv(fc,txang)';      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
wr = conj(rxarraystv(fc,rxang)); %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ber_mimo = helperMIMOBER(mimochan,x,ebn0_param,wt,wr)/Nsamp; %calculat the
                                                             %BER for each
                                                             %Eb/N₀ for the
                                                             %MIMO
                                                             %communication
                                                             %system

helperBERPlot(ebn0_param,[ber_siso(:) ber_simo(:) ber_mimo(:)]);%plot each
legend('SISO','SIMO','MIMO')                                    %BER for
                                                                %each Eb/N₀
                                                                %for SISO
                                                                %SIMO and
                                                                %MIMO
%exportgraphics(gcf,'SISO_SIMO_MIMO_BER.pdf','ContentType','vector');

%% SISO Multipath Channel

Nscat = 10;                    % 10 scattering points for Multipath channel

[~,~,~,scatpos] = ...
    helperComputeRandomScatterer(txcenter,rxcenter,Nscat);%random positions
                                                          %for the
                                                          %scattering
                                                          %points

helperPlotSpatialMIMOScene(txsipos,rxsopos,...   %plot the Multipath system
    txcenter,rxcenter,scatpos);

%exportgraphics(gcf,'SISO Multipath.pdf','ContentType','vector');

Nframe = 1e3;                                                   %1000 frame
Nbitperframe = 1e4;                                     %10000 bit by frame
Nsamp = Nframe*Nbitperframe;      %total bits = 1000 * 10000 = 10000000 bit

x = randi([0 1],Nbitperframe,1);                  %10000 random binary data
%{
┌─Note──────────────────────────────────┐
│ the same data is repeating each frame │
└───────────────────────────────────────┘
%}

nerr = zeros(1,Nsnr);%all-zeros row vector with Nsnr number of elements(11)

for m = 1:Nframe                                     %repeat for each frame
    sisompchan = scatteringchanmtx(txsipos,rxsopos,Nscat);%building the
                                                          %channel
    wr = sisompchan'/norm(sisompchan);
    nerr = nerr+helperMIMOBER(sisompchan,x,ebn0_param,1,wr);%Bit error rate
                                                            %for each frame
%{
┌─Note──────────────────────────────────────────────────────────────┐
│ nerr is a 2D Matrex now because ebn0_param has more than one value│
└───────────────────────────────────────────────────────────────────┘
%}
end
ber_sisomp = nerr/Nsamp;     %getting the average for each ebn0_param value
helperBERPlot(ebn0_param,[ber_siso(:) ber_sisomp(:)]);
legend('SISO LOS','SISO Multipath');

%exportgraphics(gcf,'SISO_LOS_Multipath.pdf','ContentType','vector');

%% SIMO Multipath Channel

nerr = zeros(1,Nsnr);%all-zeros row vector with Nsnr number of elements(11)
%{
┌─Note──────────────────────────────────────────────────────────┐
│ we are redefining the nerr because it's containts has changed │
└───────────────────────────────────────────────────────────────┘
%}
for m = 1:Nframe                                     %repeat for each frame
    simompchan = scatteringchanmtx(txsipos,rxmopos,Nscat);%building the
                                                          %channel
    wr = simompchan'/norm(simompchan);
    nerr = nerr+helperMIMOBER(simompchan,x,ebn0_param,1,wr);%Bit error rate
                                                            %for each frame
end
ber_simomp = nerr/Nsamp;     %getting the average for each ebn0_param value
helperBERPlot(ebn0_param,[ber_sisomp(:) ber_simomp(:)]);
legend('SISO Multipath','SIMO Multipath');

%exportgraphics(gcf,'SISO_SIMO Multipath.pdf','ContentType','vector');

%% MISO Multipath Channel

nerr = zeros(1,Nsnr);%all-zeros row vector with Nsnr number of elements(11)

for m = 1:Nframe                                     %repeat for each frame
    misompchan = scatteringchanmtx(txmipos,rxsopos,Nscat);%building the
                                                          %channel
    wt = misompchan'/norm(misompchan);
    nerr = nerr+helperMIMOBER(misompchan,x,ebn0_param,wt,1);%Bit error rate
                                                            %for each frame
end
ber_misomp = nerr/Nsamp;     %getting the average for each ebn0_param value

helperBERPlot(ebn0_param,[ber_sisomp(:) ber_simomp(:) ber_misomp(:)]);
legend('SISO Multipath','SIMO Multipath','MISO Multipath');

%exportgraphics(gcf,'SISO_SIMO_MISO Multipath.pdf','ContentType','vector');

%% MIMO Multipath Channel

[txang,rxang,scatg,scatpos] = ...
    helperComputeRandomScatterer(txcenter,rxcenter,Nscat);%random positions
                                                          %for the
                                                          %scattering
                                                          %points
%{
┌─Note─────────────────────────────────────────────────────────┐
│ we are defining txang rxang scatg because we need it in MIMO │
│ because the angle mutters in MIMO system (Beam forming)      │
└──────────────────────────────────────────────────────────────┘
%}
mimompchan = scatteringchanmtx(txmipos,rxmopos,txang,rxang,scatg);%building 
                                                                  %the
                                                                  %channel
%{
┌─Note────────────────────────────────────────────────────────────────────┐
│ the diffrence here is we're building the channel from the structure  of │
│ the two antennas in the Tx and Rx and the angels between them and the   │
│ scattering points                                                       │
└─────────────────────────────────────────────────────────────────────────┘
%}

helperPlotSpatialMIMOScene(txmipos,rxmopos,txcenter,rxcenter,scatpos);

%exportgraphics(gcf,'MIMO Multipath.pdf','ContentType','vector');

nerr = zeros(1,Nsnr);%all-zeros row vector with Nsnr number of elements(11)

for m = 1:Nframe
    mimompchan = scatteringchanmtx(txmipos,rxmopos,Nscat);    %building the
                                                              %channel
    [u,s,v] = svd(mimompchan);
    wt = u(:,1)';
    wr = v(:,1);
    nerr = nerr+helperMIMOBER(mimompchan,x,ebn0_param,wt,wr);    %Bit error 
                                                                 %rate for
                                                                 %each
                                                                 %frame
end
ber_mimomp = nerr/Nsamp;     %getting the average for each ebn0_param value

helperBERPlot(ebn0_param,[ber_sisomp(:) ber_simomp(:) ber_mimomp(:)]);
legend('SISO Multipath','SIMO Multipath','MIMO Multipath');

%exportgraphics(gcf,'SISO_SIMO_MIMO Multipath.pdf','ContentType','vector');