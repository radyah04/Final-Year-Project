%% Test state-update HP model
clear; close all; clc;

addpath('code/models');

set(groot,'defaultAxesFontName','Times New Roman');
set(groot,'defaultTextFontName','Times New Roman');
set(groot,'defaultAxesFontSize',12);
set(groot,'defaultLineLineWidth',1.5);

T = 0.1;
N = 10000;
t = linspace(0,T,N);

f = 100;
A = 0.7;
V = A*sin(2*pi*f*t);

params.Ron = 100;
params.Roff = 30000;
params.mu = 1e-14;
params.D = 10e-9;
params.x0 = 0.1;      % starts closer to OFF state
params.eta = 1;       % try +1 first, then -1 if loop orientation looks wrong

T = 0.2;
N = 20000;
t = linspace(0,T,N);

f = 50;
A = 1.0;
V = A*sin(2*pi*f*t);

params.Ron = 100;
params.Roff = 30000;
params.mu = 1e-12;
params.D = 10e-9;

R0 = params.Roff/10;
params.x0 = (params.Roff - R0)/(params.Roff - params.Ron);

params.eta = -1;

out = HPmodel_state_v2(t,V,params);

I = out.I;
M = out.M;
G = out.G;
x = out.x;
q = out.q;
phi = out.phi;

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
save('results/data/HP2_state_test.mat', ...
    't','V','I','G','M','x','q','phi','params','A','f');

%% I-V
figure;
period = 1/f;
idx = t >= (t(end) - period);

plot(V(idx),I(idx));
xlabel('Voltage, V(t) [V]');
ylabel('Current, I(t) [A]');
title('State-update HP model: I-V hysteresis');
grid on;
exportgraphics(gcf,'results/figures/HP2_state_IV.png','Resolution',600);
exportgraphics(gcf,'results/figures/HP2_state_IV.pdf','ContentType','vector');

%% q-phi
figure;
plot(q, phi, 'LineWidth', 0.4);
xlabel('Charge, q(t) [C]');
ylabel('Flux, \phi(t) [Wb]');
title('State-update HP model: q-\phi relationship');
grid on;
exportgraphics(gcf,'results/figures/HP2_state_q_phi.png','Resolution',600);
exportgraphics(gcf,'results/figures/HP2_state_q_phi.pdf','ContentType','vector');

%% q-phi plot: downsampled points
figure;

skip = 10;
plot(q(1:skip:end), phi(1:skip:end), '.', 'MarkerSize', 4);

xlabel('Charge, q(t) [C]');
ylabel('Flux, \phi(t) [Wb]');
title('State-update HP model: q-\phi relationship');
grid on;
box on;
exportgraphics(gcf,'results/figures/HP2_state_q_phi_points.png','Resolution',600);
exportgraphics(gcf,'results/figures/HP2_state_q_phi_points.pdf','ContentType','vector');

%% M(t)
figure;
plot(t,M);
xlabel('Time [s]');
ylabel('Memristance, M(t) [\Omega]');
title('State-update HP model: memristance response');
grid on;
exportgraphics(gcf,'results/figures/HP2_state_M_time.png','Resolution',600);
exportgraphics(gcf,'results/figures/HP2_state_M_time.pdf','ContentType','vector');

%% x(t)
figure;
plot(t,x);
xlabel('Time [s]');
ylabel('State variable, x=w/D');
title('State-update HP model: state evolution');
grid on;
exportgraphics(gcf,'results/figures/HP2_state_x_time.png','Resolution',600);
exportgraphics(gcf,'results/figures/HP2_state_x_time.pdf','ContentType','vector');
