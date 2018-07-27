function isochrones = csvqgis2isochrones_cardona(datafile)

% This function reads wildfire isochrones previously exported from QGIS
% into a CSV file. This file is assumed to have the following columns: WKT,
% Fire_Type, Month, Day, Hour, Elapsed_Mi, with a heading row.
% Isochrones coordinates are stored in the first column (accompanied by the
% word "POLIGON") and corresponding times are stored in the last one

%% ORIOL MODIFICATION 
% % Select only the coordinates of the isochrones corresponding to the 'Expanding Fire' and omit
% % 'Enclave Fires'
% rows = strcmp(data.Fire_Type, 'Expanding Fire');
% expanding_fire = data(rows, {'WKT', 'Elapsed_Mi'});
% % coordinates_column = data{rows, 'WKT'};

% isochrones.xy = cell(size(expanding_fire, 1), 1);

% després de carregar CÖRRER: 
% [isochrons_OK]=CompleteIsochronsFromFarsite=(isochronsFromFarsite);

% MMiguel, 2016

%% INSTRUCTIONS TO IMPORT FARSITE results TO QGIS (and QFIRE)
% Instructions to import FARSITE results to QGIS -> QUESTA NO VA!! FER OPCIO BA (SOTA)
% 1.	In FARSITE, select OUTPUTS -> ARCVIEW Shapefile
% 2.	In QGIS, import Shapefile as vector layer
% 3.	Split Vector layer into several using Vector -> Data Management Tools -> Split Vector Layer and selecting “Elapsed_Mi” as Unique ID field.
% Import FARSITE results into Matlab (QFire)
% Option BA
% 1.	Save FARSITE outputs as ARCVIEW Shapefile
% 2.	Import Shapefile to QGIS
% 3.	Export vector layer from QGIS in CSV format. For that, go to: Layer -> Save as and be sure to select “AS_WKT” for the menu Layer Options -> Geometry.
% 4.	Import CSV file into Matlab using function ‘csvqgis2isochrones’ and script ‘Import_isochrones_QGIS.m’
% Import data from QFire into QGIS
% 1.	Create an ASCII points file with the following columns: X, Y, Time
% 2.	Import ASCII points file into QGIS using GRASS function ‘v.in.ascii.points’. Use the ‘Time’ column (3) as category. By default, values are separated by commas and there is one heading row.
% 
% Export data from QGIS into QFire format
% 1.	Export vector layer from QGIS in CSV format. For that, go to: Layer -> Save as and be sure to select “AS_WKT” for the menu Layer Options -> Geometry.
% 2.	Import CSV file into Matlab using function ‘csvqgis2isochrones’ and script ‘Import_isochrones_QGIS.m’

% Load complete data table
data = readtable(datafile, 'Delimiter', ',', 'HeaderLines', 0);
isochrones.xy = cell(size(data, 1), 1);
isochrones.timesec = cell(size(data, 1), 1);

% for i = 1 : size(coordinates_column, 1) % Isochrones loop
for i = 1 : size(data, 1) % Isochrones loop
%     dumm_string = coordinates_column{i}; % Get the string in the first column
    dumm_string = data{i, 'WKT'}; % Get the string in the first column
    dumm_string_coordinates = dumm_string{1}(11: end-2); % Get the coordinates in that string
    dumm_coordinates = textscan(dumm_string_coordinates, '%s', 'Delimiter', ','); % Separate coordinates of each point
    num_points = size(dumm_coordinates{1}, 1);
    isochrones.xy{i} = zeros(num_points, 2);
    for p = 1 : num_points % Points loop - Convert each point's coordinates to numbers
        points_coordinates = textscan(dumm_coordinates{1}{p}, '%f', 'Delimiter', ' ');
        isochrones.xy{i}(p, :) = cell2mat(points_coordinates)';
    end
    
%     isochrones.timesec{i} = expanding_fire{i, 'Elapsed_Mi'};
    isochrones.timesec{i} = data{i, 'id'};
    
end
