close all
clear 

% time interval
% 1 = daily
% 1/24 = hourly
time_interval = 1;

% start time
yyyy1  = 2021;
mm1    = 1;
dd1    = 1;
HH1    = 0;
MM1    = 0;
SS1    = 0;
TT1    = greg2mjulian(yyyy1,mm1,dd1,HH1,MM1,SS1);
% end time
yyyy2  = 2021;
mm2    = 2;
dd2    = 28;
HH2    = 23;
MM2    = 59;
SS2    = 0;
TT2    = greg2mjulian(yyyy2,mm2,dd2,HH2,MM2,SS2);
time   = TT1:time_interval:TT2;
nTimes = length(time);

% setup an event using Gaussian function
tmid = mean(time);
% constant flux
flux = 123*ones(nTimes,1); %debit (m3/s)
% time series flux (from Excel file)
% flux = xlsread('./model_set/river_discharge.xlsx','flux_may');
sedload = .030*(flux.^1.40)/1000.; %sed conc in g/l
temp = 19.82*ones(nTimes,1);
salt = 0*ones(nTimes,1);
RiverFile = './model_in/model_river_upstream.nc';  % ganti nama file
RiverInfo1 = 'idealized estuary river';
RiverInfo2 = 'event profile';
RiverName = {'river_upstream'}; % nama sungai

write_FVCOM_river(RiverFile,RiverName,time,flux,temp,salt,RiverInfo1,RiverInfo2)
