%% Compare three HP model implementations
% 1) Athina-style voltage-history HP model
% 2) Pierre-style charge-controlled HP model
% 3) Explicit state-update HP model

clear; close all; clc;

addpath('code/models');

%% Plot settings
set(groot,'defaultAxesFontName','Times New Roman');
set(groot,'defaultTextFontName','Times New Roman');
set(groot,'defaultAxesFontSize',12);
set(groot,'defaultLineLineWidth',0.8);

%% Common simulation settings
T = 0.2;
N = 20000;
t = linspace(0,T,N);
dt = t(2)-t(1);

f = 50;
A = 1.0;
V = A*sin(2*pi*f*t);

%% Common HP parameters
Ron = 100;
Roff = 30000;
mu = 1e-14;
D = 10e-9;

%% ============================================================
% 1. Athina-style HP model
% =============================================================

timestep = dt;

[I_Athina, G_Athina, M_Athina, q_Athina, phi_Athina] = ...
    HPmodel_Athina(Ron, Roff, mu, D, V, t, timestep);

%% ============================================================
% 2. Pierre-style HP model
% =============================================================

z0 = 0.3;
mem = HPmemristor_Pierre(Ron, Roff, z0);

q_Pierre = zeros(1,N);
phi_Pierre = zeros(1,N);
M_Pierre = zeros(1,N);
I_Pierre = zeros(1,N);

q_Pierre(1) = mem.q0;
phi_Pierre(1) = mem.phi0;

for n = 1:N-1

    q_rel = q_Pierre(n) - mem.q0;

    % Choose + sign for same q-phi curvature direction as Athina
    M_Pierre(n) = mem.R0 + mem.k*q_rel;

    % Physical bounds
    M_Pierre(n) = min(max(M_Pierre(n), Ron), Roff);

    I_Pierre(n) = V(n)/M_Pierre(n);

    q_Pierre(n+1) = q_Pierre(n) + I_Pierre(n)*dt;
    phi_Pierre(n+1) = phi_Pierre(n) + V(n)*dt;
end

q_rel = q_Pierre(N) - mem.q0;
M_Pierre(N) = mem.R0 + mem.k*q_rel;
M_Pierre(N) = min(max(M_Pierre(N), Ron), Roff);
I_Pierre(N) = V(N)/M_Pierre(N);

G_Pierre = 1./M_Pierre;

% Shift q and phi to start at zero
q_Pierre_plot = q_Pierre - q_Pierre(1);
phi_Pierre_plot = phi_Pierre - phi_Pierre(1);

%% ============================================================
% 3. State-update HP model
% =============================================================

params.Ron = Ron;
params.Roff = Roff;
params.mu = 1.5e-12;      % tuned for visible hysteresis without saturation
params.D = D;

R0 = Roff/10;
params.x0 = (Roff - R0)/(Roff - Ron);
params.eta = -1;

out_state = HPmodel_state_v2(t,V,params);

I_State = out_state.I;
M_State = out_state.M;
G_State = out_state.G;
q_State = out_state.q;
phi_State = out_state.phi;
x_State = out_state.x;

%% ============================================================
% Normalise currents for fair shape comparison
% =============================================================

I_Athina_norm = I_Athina / max(abs(I_Athina),[],'omitnan');
I_Pierre_norm = I_Pierre / max(abs(I_Pierre),[],'omitnan');
I_State_norm = I_State / max(abs(I_State),[],'omitnan');

%% ============================================================
% Figure 1: Normalised I-V comparison
% =============================================================

figure;
plot(V, I_Athina_norm, 'LineWidth', 0.8);
hold on;
plot(V, I_Pierre_norm, '--', 'LineWidth', 0.8);
plot(V, I_State_norm, ':', 'LineWidth', 1.0);
hold off;

xlabel('Voltage, V(t) [V]');
ylabel('Normalised current');
title('Comparison of HP model implementations: I-V hysteresis');
legend('Athina-style analytical HP', ...
       'Pierre-style charge-controlled HP', ...
       'State-update HP', ...
       'Location','best');
grid on;
box on;

%% Figure 1: Normalised I-V comparison, final cycle only

period = 1/f;
idx = t >= (t(end) - period);

figure;
plot(V(idx), I_Athina_norm(idx), 'LineWidth', 0.8);
hold on;
plot(V(idx), I_Pierre_norm(idx), '--', 'LineWidth', 0.8);
plot(V(idx), I_State_norm(idx), ':', 'LineWidth', 1.0);
hold off;

xlabel('Voltage, V(t) [V]');
ylabel('Normalised current');
title('Comparison of HP model implementations: I-V hysteresis');
legend('Athina-style analytical HP', ...
       'Pierre-style charge-controlled HP', ...
       'State-update HP', ...
       'Location','best');
grid on;
box on;
%% ============================================================
% Figure 2: q-phi comparison
% =============================================================

figure;
plot(q_Athina, phi_Athina, 'LineWidth', 0.8);
hold on;
plot(q_Pierre_plot, phi_Pierre_plot, '--', 'LineWidth', 0.8);
plot(q_State, phi_State, ':', 'LineWidth', 1.0);
hold off;

xlabel('Charge, q(t) [C]');
ylabel('Flux, \phi(t) [Wb]');
title('Comparison of HP model implementations: q-\phi relationship');
legend('Athina-style analytical HP', ...
       'Pierre-style charge-controlled HP', ...
       'State-update HP', ...
       'Location','best');
grid on;
box on;

%% Figure 2: Normalised q-phi comparison

%% Figure 2: Normalised q-phi comparison, final cycle only

period = 1/f;
idx = t >= (t(end) - period);

% shift final-cycle q and phi so each curve starts from zero
qA = q_Athina(idx) - q_Athina(find(idx,1,'first'));
phiA = phi_Athina(idx) - phi_Athina(find(idx,1,'first'));

qP = q_Pierre_plot(idx) - q_Pierre_plot(find(idx,1,'first'));
phiP = phi_Pierre_plot(idx) - phi_Pierre_plot(find(idx,1,'first'));

qS = q_State(idx) - q_State(find(idx,1,'first'));
phiS = phi_State(idx) - phi_State(find(idx,1,'first'));

% normalise each final-cycle trajectory
qA_norm = qA / max(abs(qA),[],'omitnan');
phiA_norm = phiA / max(abs(phiA),[],'omitnan');

qP_norm = qP / max(abs(qP),[],'omitnan');
phiP_norm = phiP / max(abs(phiP),[],'omitnan');

qS_norm = qS / max(abs(qS),[],'omitnan');
phiS_norm = phiS / max(abs(phiS),[],'omitnan');

figure;
plot(qA_norm, phiA_norm, '-', 'LineWidth', 0.8);
hold on;
plot(qP_norm, phiP_norm, '--', 'LineWidth', 0.8);
plot(qS_norm, phiS_norm, ':', 'LineWidth', 1.0);
hold off;

xlabel('Normalised charge');
ylabel('Normalised flux');
title('Comparison of HP model implementations: normalised q-\phi relationship');
legend('Athina-style analytical HP', ...
       'Pierre-style charge-controlled HP', ...
       'State-update HP', ...
       'Location','best');
grid on;
box on;


%% ============================================================
% Figure 3: Memristance comparison
% =============================================================

figure;
plot(t, M_Athina, 'LineWidth', 0.8);
hold on;
plot(t, M_Pierre, '--', 'LineWidth', 0.8);
plot(t, M_State, ':', 'LineWidth', 1.0);
hold off;

xlabel('Time [s]');
ylabel('Memristance, M(t) [\Omega]');
title('Comparison of HP model implementations: memristance response');
legend('Athina-style analytical HP', ...
       'Pierre-style charge-controlled HP', ...
       'State-update HP', ...
       'Location','best');
grid on;
box on;

%% Normalised memristance comparison

M_A_norm = M_Athina / max(M_Athina,[],'omitnan');
M_P_norm = M_Pierre / max(M_Pierre,[],'omitnan');
M_S_norm = M_State / max(M_State,[],'omitnan');

figure;
plot(t, M_A_norm, 'LineWidth', 0.8);
hold on;
plot(t, M_P_norm, '--', 'LineWidth', 0.8);
plot(t, M_S_norm, ':', 'LineWidth', 1.0);
hold off;

xlabel('Time [s]');
ylabel('Normalised memristance');
title('Comparison of HP model implementations: normalised memristance');
legend('Athina-style analytical HP', ...
       'Pierre-style charge-controlled HP', ...
       'State-update HP', ...
       'Location','best');
grid on;
box on;

%% ============================================================
% Figure 4: Conductance comparison
% =============================================================

figure;
plot(t, G_Athina, 'LineWidth', 0.8);
hold on;
plot(t, G_Pierre, '--', 'LineWidth', 0.8);
plot(t, G_State, ':', 'LineWidth', 1.0);
hold off;

xlabel('Time [s]');
ylabel('Conductance, G(t) [S]');
title('Comparison of HP model implementations: conductance response');
legend('Athina-style analytical HP', ...
       'Pierre-style charge-controlled HP', ...
       'State-update HP', ...
       'Location','best');
grid on;
box on;

%% ============================================================
% Figure 5: Current difference relative to state-update model
% =============================================================

error_Athina_State = I_Athina_norm - I_State_norm;
error_Pierre_State = I_Pierre_norm - I_State_norm;

figure;
plot(t, error_Athina_State, 'LineWidth', 0.8);
hold on;
plot(t, error_Pierre_State, '--', 'LineWidth', 0.8);
hold off;

xlabel('Time [s]');
ylabel('Normalised current difference');
title('Normalised current difference relative to state-update HP model');
legend('Athina - State-update', 'Pierre - State-update', 'Location','best');
grid on;
box on;

%% ============================================================
% Numerical comparison metrics
% =============================================================

E_Athina_State = norm(error_Athina_State,2) / norm(I_Athina_norm,2);
E_Pierre_State = norm(error_Pierre_State,2) / norm(I_Pierre_norm,2);

deltaG_Athina = G_Athina(end) - G_Athina(1);
deltaG_Pierre = G_Pierre(end) - G_Pierre(1);
deltaG_State = G_State(end) - G_State(1);

loop_Athina = trapz(V, I_Athina_norm);
loop_Pierre = trapz(V, I_Pierre_norm);
loop_State = trapz(V, I_State_norm);

Model = ["Athina-style"; "Pierre-style"; "State-update"];
DeltaG = [deltaG_Athina; deltaG_Pierre; deltaG_State];
LoopArea = [loop_Athina; loop_Pierre; loop_State];

T_metrics = table(Model, DeltaG, LoopArea);

disp('Model comparison metrics:');
disp(T_metrics);

disp(['Normalised current difference Athina vs State = ', num2str(E_Athina_State)]);
disp(['Normalised current difference Pierre vs State = ', num2str(E_Pierre_State)]);

%% Save metrics
if ~exist('results/tables','dir')
    mkdir('results/tables');
end

writetable(T_metrics,'results/tables/HP_model_comparison_metrics.csv');
