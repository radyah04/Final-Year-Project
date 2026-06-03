%% Single Memristor Model Screening
% This script simulates candidate memristor models under the same input
% voltage and records I-V, q-phi and M(t)/G(t) responses.

clear; close all; clc;

%% Add folders to MATLAB path
addpath('code/models');
addpath('code/utilities');

%% Figure settings
set(groot,'defaultAxesFontName','Times New Roman');
set(groot,'defaultTextFontName','Times New Roman');
set(groot,'defaultAxesFontSize',12);
set(groot,'defaultLineLineWidth',1.5);

%% Simulation settings
T = 1;                    % longer simulation duration [s]
N = 50000;                % more samples
t = linspace(0,T,N);

f = 10;                   % lower frequency [Hz]
V0 = 1.0;                 % larger voltage amplitude [V]
v = V0*sin(2*pi*f*t);

%% HP model parameters
params_HP.Ron = 100;
params_HP.Roff = 16000;
params_HP.uv = 1e-10;     % increase mobility for visible switching
params_HP.D = 10e-9;
params_HP.x0 = 0.3;



T = 0.5;
N = 30000;
t = linspace(0,T,N);

f = 20;
V0 = 0.7;
v = V0*sin(2*pi*f*t);

params_HP.Ron = 100;
params_HP.Roff = 16000;
params_HP.uv = 1e-13;
params_HP.D = 10e-9;
params_HP.x0 = 0.5;

%% Run HP model
out_HP = hp_model(t,v,params_HP);

%% Save data
save('results/data/HP_single_device.mat','t','v','out_HP','params_HP');

%% Plot and save figures
plot_single_model_results(t,v,out_HP,'HP');
