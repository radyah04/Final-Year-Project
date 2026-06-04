%% Test Pierre-style HP model
clear; close all; clc;

addpath('code/models');

set(groot,'defaultAxesFontName','Times New Roman');
set(groot,'defaultTextFontName','Times New Roman');
set(groot,'defaultAxesFontSize',12);
set(groot,'defaultLineLineWidth',0.8);

%% Simulation settings
T = 0.2;
N = 20000;
t = linspace(0,T,N);
dt = t(2)-t(1);

f = 50;
A = 1.0;
V = A*sin(2*pi*f*t);

%% Model parameters
Ron = 100;
Roff = 30000;
z0 = 0.3;

mem = HPmemristor_Pierre(Ron,Roff,z0);

%% Preallocate variables
q = zeros(1,N);
phi = zeros(1,N);
M = zeros(1,N);
G = zeros(1,N);
I = zeros(1,N);

q(1) = mem.q0;
phi(1) = mem.phi0;

%% Simulate voltage-driven response
for n = 1:N-1

    % Charge relative to initial charge
    q_rel = q(n) - mem.q0;

    % Pierre-style charge-controlled memristance with positive curvature
    M(n) = mem.R0 + mem.k*q_rel;

    % Keep memristance physically bounded
    M(n) = min(max(M(n), Ron), Roff);

    % Terminal current
    I(n) = V(n)/M(n);

    % Update charge and flux
    q(n+1) = q(n) + I(n)*dt;
    phi(n+1) = phi(n) + V(n)*dt;
end

%% Final sample
q_rel = q(N) - mem.q0;
M(N) = mem.R0 + mem.k*q_rel;
M(N) = min(max(M(N), Ron), Roff);
I(N) = V(N)/M(N);
G = 1./M;

%% Shift q and phi so plots start from zero
q_plot = q - q(1);
phi_plot = phi - phi(1);

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
save('results/data/Pierre_HP_test.mat', ...
    't','V','I','G','M','q','phi','q_plot','phi_plot','mem','Ron','Roff','z0','A','f');

%% I-V plot
figure;
plot(V,I,'LineWidth',0.8);
xlabel('Voltage, V(t) [V]');
ylabel('Current, I(t) [A]');
title('Pierre-style HP model: I-V hysteresis');
grid on;
box on;
exportgraphics(gcf,'results/figures/Pierre_HP_IV.png','Resolution',600);
exportgraphics(gcf,'results/figures/Pierre_HP_IV.pdf','ContentType','vector');

%% q-phi plot
figure;
plot(q_plot,phi_plot,'LineWidth',0.5);
xlabel('Charge, q(t) [C]');
ylabel('Flux, \phi(t) [Wb]');
title('Pierre-style HP model: q-\phi relationship');
grid on;
box on;
exportgraphics(gcf,'results/figures/Pierre_HP_q_phi.png','Resolution',600);
exportgraphics(gcf,'results/figures/Pierre_HP_q_phi.pdf','ContentType','vector');

%% M(t)
figure;
plot(t,M,'LineWidth',0.8);
xlabel('Time [s]');
ylabel('Memristance, M(t) [\Omega]');
title('Pierre-style HP model: memristance response');
grid on;
box on;
exportgraphics(gcf,'results/figures/Pierre_HP_M_time.png','Resolution',600);
exportgraphics(gcf,'results/figures/Pierre_HP_M_time.pdf','ContentType','vector');

%% G(t)
figure;
plot(t,G,'LineWidth',0.8);
xlabel('Time [s]');
ylabel('Conductance, G(t) [S]');
title('Pierre-style HP model: conductance response');
grid on;
box on;
exportgraphics(gcf,'results/figures/Pierre_HP_G_time.png','Resolution',600);
exportgraphics(gcf,'results/figures/Pierre_HP_G_time.pdf','ContentType','vector');
