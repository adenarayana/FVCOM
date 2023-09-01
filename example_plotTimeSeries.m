% Sample script to plot FVCOM output as time series
%
% The 'read_sms_mesh.m' can be found on the gitHub: 
%   https://github.com/pwcazenave/fvcom-toolbox/blob/master/fvcom_prepro/read_sms_mesh.m
% 
% Author(s):
%   Made Narayana Adibhusana | Chonnam National University 
%
% Revision history:
%   2023.07.14: First version
%
%==========================================================================

clear
close all;
clc

%--------------------------------------------------------------------------
% Get the FVCOM output
%--------------------------------------------------------------------------

pathFVCOMOut = 'model_out/00_NoRiver.nc';

% get the variables (located at node)
zeta = ncread(pathFVCOMOut, 'zeta'); % water_surface_elevation (meters)
%var = ncread(pathFVCOMOut, 'temp'); % sea_water_temperature (degrees_C)
%var = ncread(pathFVCOMOut, 'salinity'); % sea_water_salinity (part per thousand ppt)

%--------------------------------------------------------------------------
% Plot the time series 
%--------------------------------------------------------------------------

node = 4921; % which point/node to plot 

varNode = zeta(node,:);

timeStep = (1:length(varNode(1,:)));

figure(20)

plot(timeStep, varNode)

xlabel('Time step (hours)', 'fontweight', 'bold', 'fontsize', 8);
ylabel('Elevation (m)', 'fontweight', 'bold', 'fontsize', 8);
ax = gca;
ax.FontSize = 8; 
ytickangle(90)

xlim([514, 566]);
ylim([-2.5, 2.5]);

exportgraphics(figure(1), 'Water Surface Elevation - 3474.png', 'Resolution', 300)

%--------------------------------------------------------------------------
% Get model nodes coordinate
%--------------------------------------------------------------------------

path_2dm = 'model_set/model_mesh.2dm';
Mobj = read_sms_mesh('2dm', path_2dm, ...
                     'project', 'true');





