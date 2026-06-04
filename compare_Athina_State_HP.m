%% Compare Athina-style HP model and state-update HP model
clear; close all; clc;

addpath('code/models');

set(groot,'defaultAxesFontName','Times New Roman');
set(groot,'defaultTextFontName','Times New Roman');
set(groot,'defaultAxesFontSize',12);
set(groot,'defaultLineLineWidth',0.8);

%% Common simulation settings
T = 0.2;
N = 20000;
t = linspace(0,T,N);

f = 50;
A = 1.0;
V = A*sin(2*pi*f*t);

%% Common HP parameters
Ron = 100;
Roff = 30000;
mu = 1e-12;
D = 10e-9;

f = 100;
A = 0.5;

Ron = 100;
Roff = 30000;
mu = 1e-14;
D = 10e-9;

%% Run Athina-style HP model
timestep = t(2)-t(1);

[I_Athina, G_Athina, M_Athina, q_Athina, phi_Athina] = ...
    HPmodel_Athina(Ron, Roff, mu, D, V, t, timestep);

%% Run state-update HP model
params.Ron = Ron;
params.Roff = Roff;
params.mu = mu;
params.D = D;

R0 = Roff/10;
params.x0 = (Roff - R0)/(Roff - Ron);
params.eta = -1;


out_state = HPmodel_state_v2(t,V,params);

I_state = out_state.I;
M_state = out_state.M;
G_state = out_state.G;
q_state = out_state.q;
phi_state = out_state.phi;



%% Plot I-V comparison over final cycle
period = 1/f;
idx = t >= (t(end) - period);

figure;
plot(V(idx), I_Athina(idx), 'LineWidth', 0.8);
hold on;
plot(V(idx), I_state(idx), '--', 'LineWidth', 0.8);
hold off;

xlabel('Voltage, V(t) [V]');
ylabel('Current, I(t) [A]');
title('HP model comparison: I-V hysteresis');
legend('Athina-style analytical HP', 'State-update HP', 'Location', 'best');
grid on;
box on;

%% Plot I-V comparison over full simulation
figure;
plot(V, I_Athina, 'LineWidth', 0.8);
hold on;
plot(V, I_state, '--', 'LineWidth', 0.8);
hold off;

xlabel('Voltage, V(t) [V]');
ylabel('Current, I(t) [A]');
title('HP model comparison: I-V hysteresis');
legend('Athina-style analytical HP', 'State-update HP', 'Location', 'best');
grid on;
box on;

%% Plot q-phi comparison
figure;
plot(q_Athina, phi_Athina, 'LineWidth', 0.8);
hold on;
plot(q_state, phi_state, '--', 'LineWidth', 0.8);
hold off;

xlabel('Charge, q(t) [C]');
ylabel('Flux, \phi(t) [Wb]');
title('HP model comparison: q-\phi relationship');
legend('Athina-style analytical HP', 'State-update HP', 'Location', 'best');
grid on;
box on;

%% Plot M(t) comparison
figure;
plot(t, M_Athina, 'LineWidth', 0.8);
hold on;
plot(t, M_state, '--', 'LineWidth', 0.8);
hold off;

xlabel('Time [s]');
ylabel('Memristance, M(t) [\Omega]');
title('HP model comparison: memristance response');
legend('Athina-style analytical HP', 'State-update HP', 'Location', 'best');
grid on;
box on;

%% Plot G(t) comparison
figure;
plot(t, G_Athina, 'LineWidth', 0.8);
hold on;
plot(t, G_state, '--', 'LineWidth', 0.8);
hold off;

xlabel('Time [s]');
ylabel('Conductance, G(t) [S]');
title('HP model comparison: conductance response');
legend('Athina-style analytical HP', 'State-update HP', 'Location', 'best');
grid on;
box on;

%% Normalised I-V comparison
I_Athina_norm = I_Athina / max(abs(I_Athina));
I_state_norm = I_state / max(abs(I_state));

figure;
plot(V, I_Athina_norm, 'LineWidth', 0.8);
hold on;
plot(V, I_state_norm, '--', 'LineWidth', 0.8);
hold off;

xlabel('Voltage, V(t) [V]');
ylabel('Normalised current');
title('HP model comparison: normalised I-V hysteresis');
legend('Athina-style analytical HP', 'State-update HP', 'Location', 'best');
grid on;
box on;

%% Error between normalised current responses
error_I = I_Athina_norm - I_state_norm;

figure;
plot(t, error_I, 'LineWidth', 0.8);
xlabel('Time [s]');
ylabel('Normalised current error');
title('Difference between Athina-style and state-update HP models');
grid on;
box on;

E_model = norm(error_I) / norm(I_Athina_norm);
disp(['Normalised model difference = ', num2str(E_model)]);