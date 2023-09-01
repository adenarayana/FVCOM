% create an input file for FVCOM
close all
clear

% print information on the screen
global ftbverbose
ftbverbose = true; 

%================== user define parameters ===============================%
%  CORIOLIS
%   lat_cor = latitude for coriolis (degree)
%  
%  ESTIMATE EXTERNAL TIME STEP
%   anticipatedMaxU = anticipated maximum current speed (m/s)  
%   anticipatedMaxZ = anticipated maximum surface elevation (m)
%  
%  RIVER
%   nodeRiver = node of river locetion
%
%  OPEN BOUNDARY
%   numberOpenBoundary = total number of open boundary
%=========================================================================%

lat_cor = 35; % latitude in degree

anticipatedMaxU = 3; % velicity in m/s
anticipatedMaxZ = 3; % elevation in meter

% nodeRiver = [2685,1,2,3,4,5,6,7,8];
% riverName = 'SeomjinRiver';

numberOpenBoundary = 1:25;
obcName = 'OpenOcean';

spg_rad  = 1000;
spg_coef = 0.1;

%==========================================================================

% read Mesh from SMS file
path_2dm = 'model_set/model_mesh.2dm';
path_dep = 'model_set/model_bathymetry.dep';
Mobj = read_sms_mesh('2dm',path_2dm,'bath',path_dep,'project','addCoriolis');

% calculate the Corolis
Mobj = add_coriolis(Mobj,'constant',lat_cor);

% sigma layer
path_sigma = 'model_in/model_sigma.dat';
Mobj = read_sigma(Mobj, path_sigma);

% add a river to the domain 
% Mobj = add_river_nodes_list(Mobj,nodeRiver,riverName);

% add sponge
Mobj = add_sponge_nodes_list(Mobj,numberOpenBoundary,'ModelSponge',spg_rad,spg_coef,1);

% add an open boundary to the Mesh
Mobj = add_obc_nodes_list(Mobj,numberOpenBoundary,obcName,1);
Mobj = find_boundary_elements(Mobj);
Mobj.read_obc_elems = Mobj.read_obc_elements;

% tide forcing at open boundary
Mobj.Components = {'S2','M2','K1','O1','N2','K2','P1'};
Mobj.period_obc = [43200, 44715.6, 86162.4, 92948.4, 45568.8, 43081.2, 86637.6];
Mobj.beta_love = [0.693, 0.693, 0.736, 0.695, 0.693, 0.693, 0.706];
Mobj.equilibrium_amp = [0.112841, 0.242334, 0.141565, 0.100514, 0.046398, 0.030704, 0.046843];
Mobj.amp_obc   = {xlsread('model_set/tide_component.xlsx','amplitude').'}; % amplitude in meter
Mobj.phase_obc = {xlsread('model_set/tide_component.xlsx','phase').'}; % phase in degree
set_spectide_ranu(Mobj, 7, 'model_in/model_spectide.nc', 'Spectral tidal forcing');

%=============== Create the FVCOM input files =============================

% dump mesh and connectivity
path_grid   = 'model_in/model_grd.dat';
write_FVCOM_grid(Mobj, path_grid);

% dump bathymetry
path_bath   = 'model_in/model_dep.dat';
write_FVCOM_bath(Mobj,path_bath);

% dump open boundary node list
path_obc    = 'model_in/model_obc.dat';
write_FVCOM_obc(Mobj, path_obc);

% dump sponge layer file
path_spg    = 'model_in/model_spg.dat';
write_FVCOM_sponge(Mobj, path_spg);

% dump Coriolis file
path_cor    = 'model_in/model_cor.dat';
write_FVCOM_cor(Mobj,path_cor);

% check the time step and plot
Mobj = estimate_ts(Mobj,anticipatedMaxU,anticipatedMaxZ);
%plot_field(Mobj,Mobj.ts,'title','timestep (s)')
fprintf('estimated max external mode time step in seconds %f\n',min(Mobj.ts));

