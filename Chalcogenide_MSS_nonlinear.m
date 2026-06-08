%% Chalcogenide/MSS nonlinear memristor: exaggerated q-phi curvature
clear; close all; clc;

%% ============================================================
% Output folder
outdir = 'results/figures/Chalcogenide_MSS_nonlinear';
if ~exist('results','dir'); mkdir('results'); end
if ~exist('results/figures','dir'); mkdir('results/figures'); end
if ~exist(outdir,'dir'); mkdir(outdir); end

%% ============================================================
% Plot theme
C = pastel_palette_report();

set(groot,'defaultFigureColor','w');
set(groot,'defaultAxesColor','w');
set(groot,'defaultAxesFontName','Times New Roman');
set(groot,'defaultTextFontName','Times New Roman');
set(groot,'defaultAxesFontSize',12);
set(groot,'defaultAxesLineWidth',1.0);
set(groot,'defaultAxesBox','off');
set(groot,'defaultAxesTickDir','out');
set(groot,'defaultLineLineWidth',1.8);

%% ============================================================
% Simulation parameters
T = 0.02;           % one period at 50 Hz
N = 20000;
t = linspace(0,T,N);
dt = t(2)-t(1);

% Clean input sinusoid
A_main = 0.5;      % voltage amplitude
f_main = 50;       % Hz
V = A_main*sin(2*pi*f_main*t);   % clean sinusoid input

%% ============================================================
% Chalcogenide/MSS parameters: nonlinear ODE
G_ON  = 1e-3;       % S
G_OFF = 1e-5;       % S
X0    = 0.1;        % initial normalized state
tau   = 2e-3;       % slower time constant to exaggerate nonlinear response
beta  = 25;         % reduced sigmoid steepness
V_on  = 0.27;       % positive threshold
V_off = 0.27;       % negative threshold

X = zeros(1,N);
I = zeros(1,N);
G = zeros(1,N);
X(1) = X0;

%% ============================================================
% Simulation loop: nonlinear ODE update
for k = 1:N-1
    % Conductance and current (I computed from current G and clean V)
    G(k) = X(k)*G_ON + (1-X(k))*G_OFF;
    I(k) = G(k)*V(k);

    % Nonlinear state update (sigmoid-based)
    p_on  = 1/(1 + exp(-beta*(V(k)-V_on)));
    p_off = 1/(1 + exp(-beta*(-V(k)-V_off)));
    dxdt  = ((1-X(k))*p_on - X(k)*p_off)/tau;

    % Euler update
    X(k+1) = min(max(X(k) + dxdt*dt,0),1);
end

G(N) = X(N)*G_ON + (1-X(N))*G_OFF;
I(N) = G(N)*V(N);

q   = cumtrapz(t,I);
phi = cumtrapz(t,V);

%% ============================================================
% Figure 1: I-V
figure;
plot(V,I,'Color',C.pink,'LineWidth',1.8);
xlabel('Voltage, v(t) [V]');
ylabel('Current, i(t) [A]');
title('Chalcogenide/MSS model: nonlinear I-V');
grid on; box off;

%% Figure 2: q-phi (downsampled, clean)
hfig = figure;
ax = axes; % dedicated axes

skip = 10; % downsample to reduce overplotting
plot(ax, q(1:skip:end), phi(1:skip:end), '.', ...
    'Color', C.lilac, ...
    'MarkerSize', 4);

xlabel(ax, 'Charge, q(t) [C]');
ylabel(ax, 'Flux, \phi(t) [Wb]');
title(ax, 'Chalcogenide/MSS model: q-\phi response at 50 Hz');

% Force a single axis and reset colors
ax.XColor = [0 0 0];
ax.YColor = [0 0 0];
ax.YAxisLocation = 'left';  % ensures no right y-axis
ax.Box = 'off';
grid(ax,'on');

format_and_save_figure(hfig, fullfile(outdir,'Chalcogenide_MSS_qphi_50Hz'));

%% Figure 3: Voltage vs Output Current
figure;
yyaxis left
plot(t,V,'Color',C.pink,'LineWidth',1.8);
ylabel('Voltage, v(t) [V]');
ax = gca; ax.YColor = C.pink;

yyaxis right
plot(t,I,'Color',C.blue,'LineWidth',1.8);
ylabel('Current, i(t) [A]');
ax.YColor = C.blue; ax.XColor = [0 0 0];

xlabel('Time [s]');
title('Chalcogenide/MSS model: voltage & current nonlinear');
grid on; box off;

%% Figure 4: Conductance G(t)
figure;
plot(t,G,'Color',C.green,'LineWidth',1.8);
xlabel('Time [s]'); ylabel('Conductance G(t) [S]');
title('Chalcogenide/MSS model: nonlinear conductance');
grid on; box off;

%% Figure 5: State variable X(t)
figure;
plot(t,X,'Color',C.peach,'LineWidth',1.8);
xlabel('Time [s]'); ylabel('State variable X(t)');
title('Chalcogenide/MSS model: nonlinear state evolution');
grid on; box off;

%% ============================================================
% Local pastel palette function
function C = pastel_palette_report()
    C.pink   = [0.89 0.47 0.64];
    C.blue   = [0.42 0.67 0.91];
    C.green  = [0.50 0.79 0.60];
    C.yellow = [0.93 0.78 0.36];
    C.lilac  = [0.70 0.60 0.90];
    C.peach  = [0.95 0.67 0.52];
    C.black  = [0.10 0.10 0.10];
end
