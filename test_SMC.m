clearvars
close all

% Load incidence
cases = readtable("data/cases.csv");
ColumnNames = string(cases.Properties.VariableNames);
assert(ColumnNames(1) == "data");
GEO = ColumnNames(2:end);
Time = cases.data';
clear ColumnNames

% extract new cases
count = table2array(cases(:, 2:end));
count(isnan(count)) = 0;
count = diff([zeros(1, 7); count], 1);
new_cases = count';
clear count cases;

lim = 600;
new_cases = new_cases(:, 1:lim);
Time = Time(1:lim);
new_cases_smooth = smoothdata(new_cases, 2, 'movmean', [13, 0]);
new_cases_smooth(new_cases_smooth < 0) = 0;
new_cases(new_cases < 0) = 0;

% Load Population
pop = readtable("data/respop.csv");
assert(all(string(pop.NUTS_3') == GEO), ...
    "GEO codes for respop and cases do not coincide")
ResPop = pop.Resident_Population;
clear pop GEO

% Load Mobility
% hdf5 files should be interpreted as row major (C) order, but matlab
% insists in reading them in column major (FORTRAN) order,
% hence the transpose
C = h5read('data/mobility.hdf5', '/P_V')';
x = (1 - diag(C)); % percentage of moving pop
Q = (C - diag(diag(C))) * diag(1./x); % extradiagonal fluxes

% Load Google Mobility Data
load data/google-data.mat
a = find(Time_GMD == Time(1));
b = find(Time_GMD == Time(end));
GMD = GMD(:, a:b);

gmd_fill = fillmissing(GMD, 'linear', 2);
gmd_fill_smooth = smoothdata(gmd_fill, 2, 'movmean', 14);
csi = x .* gmd_fill_smooth;

%% PARAMETERS
par.mean_GD = 5.20;
par.std_GD = 1.72;
par.k = 21;
par.delay = 0;
par.init = 6;
par.Np = 50000;

par.cv_r_0 = 0.5;
par.low_cv_r = 0.25;

par.alpha_min = 0;
par.delta = 0.95;

par.lik = 'V1';

%% save all input data

% output file name
filename = fullfile('results', [mfilename(), '.mat']);
fprintf("Saving input parameters in '%s'\n", filename)

% create fresh matlab v7.3 (hdf5) output file
warning('off', 'MATLAB:DELETE:FileNotFound')
delete(filename);
warning('on', 'MATLAB:DELETE:FileNotFound')
matout = matfile(filename);

matout.new_cases_smooth = new_cases_smooth;
matout.par = par;
matout.Q = Q;
matout.ResPop = ResPop;
matout.csi = csi;

%% roundtrip
clearvars
filename = fullfile('results', [mfilename(), '.mat']);
fprintf("Loading input parameters from '%s'\n", filename)
load(filename)

fprintf("Saving results in '%s'\n", filename)
matout = matfile(filename, Writable = true);

%% RUN

% seed random number generator state and record start time
rng(0, 'twister');
tstart = tic;

% run spatial Rt V1
disp('Spatial Rt V1')
[Rt1, diagnostic, model_out] = pf(new_cases_smooth, par, Q, ResPop, csi);
% save results
matout.Rt1 = Rt1;
matout.diagnostic = diagnostic;
matout.model_out = model_out;

% run local Rt
disp('Local Rt')
[R0] = pf(new_cases_smooth, par, Q, ResPop, zeros(size(csi)));
% save result
matout.R0 = R0;

% run spatial explicit Rt V2
disp('Spatial Rt V2')
par.lik = 'V2';
[Rt2] = pf(new_cases_smooth, par, Q, ResPop, csi);
% save result
matout.Rt2 = Rt2;

% report times
telapsed = toc(tstart);
fprintf("Elapsed time %.3f s\n", telapsed)
