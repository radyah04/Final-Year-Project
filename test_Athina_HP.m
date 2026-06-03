%% Test Athina-style HP model
clear; close all; clc;

%% Figure settings
set(groot,'defaultAxesFontName','Times New Roman');
set(groot,'defaultTextFontName','Times New Roman');
set(groot,'defaultAxesFontSize',12);
set(groot,'defaultLineLineWidth',1.5);

%% Simulation settings
T = 0.1;                    % duration [s]
N = 10000;                  % number of samples
time_vect = linspace(0,T,N);
timestep = time_vect(2)-time_vect(1);

f = 100;                    % frequency [Hz]
A = 0.5;                    % voltage amplitude [V]
V = A*sin(2*pi*f*time_vect);

%% HP parameters
Ron = 100;                  % ohm
Roff = 30000;               % ohm
mu = 1e-14;                 % m^2/(V s)
D = 10e-9;                  % m

%% Run model
[I, G, M, q, phi] = HPmodel_Athina(Ron, Roff, mu, D, V, time_vect, timestep);

%% Create results folders
if ~exist('results','dir')
    mkdir('results');
end
if ~exist('results/figures','dir')
    mkdir('results/figures');
end
if ~exist('results/data','dir')
    mkdir('results/data');
end

%% Save data
save('results/data/Athina_HP_test.mat', ...
    'time_vect','V','I','G','M','q','phi','Ron','Roff','mu','D','A','f');

%% Plot voltage and current
figure;
yyaxis left
plot(time_vect,V);
ylabel('Voltage, V(t) [V]');

yyaxis right
plot(time_vect,I);
ylabel('Current, I(t) [A]');

xlabel('Time [s]');
title('Athina-style HP model: voltage and current');
grid on;
exportgraphics(gcf,'results/figures/Athina_HP_time_response.png','Resolution',600);
exportgraphics(gcf,'results/figures/Athina_HP_time_response.pdf','ContentType','vector');

%% Plot I-V hysteresis
figure;
plot(V,I);
xlabel('Voltage, V(t) [V]');
ylabel('Current, I(t) [A]');
title('Athina-style HP model: I-V hysteresis');
grid on;
exportgraphics(gcf,'results/figures/Athina_HP_IV.png','Resolution',600);
exportgraphics(gcf,'results/figures/Athina_HP_IV.pdf','ContentType','vector');

%% Plot q-phi
figure;
plot(q,phi);
xlabel('Charge, q(t) [C]');
ylabel('Flux, \phi(t) [Wb]');
title('Athina-style HP model: q-\phi relationship');
grid on;
exportgraphics(gcf,'results/figures/Athina_HP_q_phi.png','Resolution',600);
exportgraphics(gcf,'results/figures/Athina_HP_q_phi.pdf','ContentType','vector');

%% Plot conductance
figure;
plot(time_vect,G);
xlabel('Time [s]');
ylabel('Conductance, G(t) [S]');
title('Athina-style HP model: conductance response');
grid on;
exportgraphics(gcf,'results/figures/Athina_HP_G_time.png','Resolution',600);
exportgraphics(gcf,'results/figures/Athina_HP_G_time.pdf','ContentType','vector');

%% Plot memristance
figure;
plot(time_vect,M);
xlabel('Time [s]');
ylabel('Memristance, M(t) [\Omega]');
title('Athina-style HP model: memristance response');
grid on;
exportgraphics(gcf,'results/figures/Athina_HP_M_time.png','Resolution',600);
exportgraphics(gcf,'results/figures/Athina_HP_M_time.pdf','ContentType','vector');
