% Author(s):
%    I Putu Ranu Fajar Maharta (Bandung Institute of Technology)
%    I Made Dharma Raharja (Bandung Institute of Technology)
%    Made Narayana Adibhusana (Chonnam National University, Republic of
%    Korea)
% Revision history
%  20210729: create casename_tsobc.nc using our own data (temperature,
%  salinity, etc)
%
%===========================================================================================================================================
clear; close all;

global ftbverbose
ftbverbose = true; %print information to screen [true/false]

%%%====================INPUT===============================================
% number of open boundary (ocean open boundary)
nob      = 25;
Nodelist = 1:nob; 

% data interval
% start
external_timeStep = 1; % model external time step in second
yyyy1 = 2021;
mm1 = 1;
dd1 = 1;
HH1 = 0;
MM1 = 0;
SS1 = 0;
TT1 = greg2mjulian(yyyy1,mm1,dd1,HH1,MM1,SS1);
T1  = [yyyy1, mm1, dd1, HH1, MM1, SS1];
% end
yyyy2 = 2021;
mm2 = 2;
dd2 = 20;
HH2 = 23;
MM2 = 59;
SS2 = 0;
TT2 = greg2mjulian(yyyy2,mm2,dd2,HH2,MM2,SS2);
T2  = [yyyy2, mm2, dd2, HH2, MM2, SS2];
modelTime = [TT1, TT2];
recovery_time = 1/60; % data interval in hour
time = TT1:recovery_time/24:TT2; % total data

% files directory
mesh_path  = './model_set/model_mesh.2dm';
dep_path   = './model_set/model_bathymetry.dep';
sigma_path = './model_set/model_sigma.dat';
name_out   = './model_in/model';

% temperature and salinity data at open boundary
constant_temperature = 15.92;
constant_salinity = 33;
%%%====================END_INPUT===========================================

% read the Mesh from an SMS file
Mobj = read_sms_mesh('2dm',mesh_path,'bath',dep_path,'project','addCoriolis');
% reverse the topography so that it is positive down (e.g. bathymetry)
if(mean(Mobj.h) < 0.0)
	Mobj.h = -Mobj.h;
end

% menambahkan informasi sigma layer pada Mobj
Mobj = read_sigma(Mobj, sigma_path);
% add an open boundary to the Mesh
Mobj = add_obc_nodes_list(Mobj,Nodelist,'OpenOcean',1);
% menambahkan read_obc_elems pada Mobj
Mobj = find_boundary_elements(Mobj);
Mobj.read_obc_elems = Mobj.read_obc_elements;

% number of layer
nlayer = Mobj.nlev - 1;

% Temperature data
temperature = zeros(nob,nlayer);
for i=1:length(time)
    temperature(:,:,i) = constant_temperature; 
end
Mobj.temperature = temperature;

% Salinity data
salinity = zeros(nob,nlayer);
for i=1:length(time)
    salinity(:,:,i) = constant_salinity; 
end
Mobj.salt = salinity;

% write TS_obc
write_FVCOM_tsobc(name_out, time, nlayer ,Mobj.temperature, Mobj.salt, Mobj);

% nudging time scale (in Second)
nudging_timeScale = 1/(recovery_time*3600/external_timeStep);
fprintf('Nudging Time Scale in seconds %f\n',nudging_timeScale);

