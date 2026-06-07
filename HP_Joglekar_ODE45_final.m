%% HP_Joglekar_ODE45_final.m
% Joglekar-window HP model using ode45.
%
% Produces:
% 1) I-V response at 50 Hz
% 2) q-phi response at 50 Hz
% 3) memristance response at 50 Hz
% 4) input voltage and output current at 50 Hz
% 5) I-V response at different frequencies
% 6) I-V response at different amplitudes
% 7) hysteresis area versus frequency
% 8) hysteresis area versus amplitude

clear; close all; clc;

%% ============================================================
% Output folder
% ============================================================
outdir = 'results/figures/HP_Joglekar_final';

if ~exist('results','dir')
    mkdir('results');
end

if ~exist('results/figures','dir')
    mkdir('results/figures');
end

if ~exist(outdir,'dir')
    mkdir(outdir);
end

%% ============================================================
% Plot theme
% ============================================================
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
% Model and input parameters
% ============================================================
f_main = 50;       % main frequency [Hz]
A_main = 1.0;      % main voltage amplitude [V]

T = 0.2;
N = 20000;
tspan = linspace(0,T,N);

params.Ron  = 100;
params.Roff = 30000;
params.mu   = 1e-12;
params.D    = 10e-9;
params.eta  = -1;
params.x0   = 0.3;

p = 2;             % Joglekar window exponent

opts = odeset('RelTol',1e-6,'AbsTol',1e-9);

%% ============================================================
% Main 50 Hz simulation
% ============================================================
out_main = simulate_joglekar_ode45(tspan,A_main,f_main,params,p,opts);

t_main   = out_main.t;
V_main   = out_main.V;
I_main   = out_main.I;
M_main   = out_main.M;
G_main   = out_main.G;
q_main   = out_main.q;
phi_main = out_main.phi;
x_main   = out_main.x;

period = 1/f_main;
idx_main = t_main >= (t_main(end)-period);

A_loop_main = abs(trapz(V_main(idx_main), I_main(idx_main)));

fprintf('\n================ HP Joglekar model main case ================\n');
fprintf('f = %.1f Hz\n', f_main);
fprintf('A = %.2f V\n', A_main);
fprintf('Joglekar exponent p = %d\n', p);
fprintf('Initial state x0 = %.3f\n', params.x0);
fprintf('I-V loop area = %.4e VA\n', A_loop_main);
fprintf('M range = %.2f to %.2f ohm\n', min(M_main), max(M_main));
fprintf('x range = %.4f to %.4f\n', min(x_main), max(x_main));

%% ============================================================
% Figure 1: I-V response at 50 Hz
% ============================================================
hfig = figure;

plot(V_main(idx_main), I_main(idx_main), ...
    'Color', C.pink, ...
    'LineWidth', 2.0);

xlabel('Voltage, v(t) [V]');
ylabel('Current, i(t) [A]');
title('HP Joglekar model: I-V response at 50 Hz');
grid on;
box off;

format_and_save_figure(hfig, fullfile(outdir,'HP_Joglekar_IV_50Hz'));

%% ============================================================
% Figure 2: q-phi response at 50 Hz
% ============================================================
hfig = figure;

plot(q_main, phi_main, ...
    'Color', C.lilac, ...
    'LineWidth', 1.8);

xlabel('Charge, q(t) [C]');
ylabel('Flux, \phi(t) [Wb]');
title('HP Joglekar model: q-\phi response at 50 Hz');
grid on;
box off;

format_and_save_figure(hfig, fullfile(outdir,'HP_Joglekar_qphi_50Hz'));

%% ============================================================
% Figure 3: memristance response at 50 Hz
% ============================================================
hfig = figure;

plot(t_main, M_main, ...
    'Color', C.blue, ...
    'LineWidth', 1.8);

xlabel('Time, t [s]');
ylabel('Memristance, M(t) [\Omega]');
title('HP Joglekar model: memristance response at 50 Hz');
grid on;
box off;

format_and_save_figure(hfig, fullfile(outdir,'HP_Joglekar_memristance_50Hz'));

%% ============================================================
% Figure 4: voltage and current versus time
% ============================================================
hfig = figure;

yyaxis left
plot(t_main, V_main, ...
    'Color', C.pink, ...
    'LineWidth', 1.8);
ylabel('Voltage, v(t) [V]');
ax = gca;
ax.YColor = C.pink;

yyaxis right
plot(t_main, I_main, ...
    'Color', C.blue, ...
    'LineWidth', 1.8);
ylabel('Current, i(t) [A]');
ax = gca;
ax.YColor = C.blue;
ax.XColor = C.black;

xlabel('Time, t [s]');
title('HP Joglekar model: input voltage and output current at 50 Hz');
grid on;
box off;

format_and_save_figure(hfig, fullfile(outdir,'HP_Joglekar_voltage_current_time_50Hz'));

%% ============================================================
% Figure 5: I-V response at different frequencies
% ============================================================
freqs = [50 75 100 150 200];
cols = [C.pink; C.blue; C.green; C.yellow; C.lilac];

area_freq = zeros(size(freqs));

hfig = figure;
hold on;

for kk = 1:length(freqs)

    f = freqs(kk);
    out = simulate_joglekar_ode45(tspan,A_main,f,params,p,opts);

    period = 1/f;
    idx = out.t >= (out.t(end)-period);

    area_freq(kk) = abs(trapz(out.V(idx), out.I(idx)));

    plot(out.V(idx), out.I(idx), ...
        'Color', cols(kk,:), ...
        'LineWidth', 1.8, ...
        'DisplayName', sprintf('%d Hz', f));
end

hold off;
xlabel('Voltage, v(t) [V]');
ylabel('Current, i(t) [A]');
title('HP Joglekar model: I-V response at different frequencies');
legend('Location','best');
grid on;
box off;

format_and_save_figure(hfig, fullfile(outdir,'HP_Joglekar_IV_frequency_sweep'));

%% ============================================================
% Figure 6: I-V response at different amplitudes
% ============================================================
amps = [0.5 0.75 1.0 1.25 1.5];

area_amp = zeros(size(amps));

hfig = figure;
hold on;

for kk = 1:length(amps)

    A = amps(kk);
    out = simulate_joglekar_ode45(tspan,A,f_main,params,p,opts);

    idx = out.t >= (out.t(end)-1/f_main);

    area_amp(kk) = abs(trapz(out.V(idx), out.I(idx)));

    plot(out.V(idx), out.I(idx), ...
        'Color', cols(kk,:), ...
        'LineWidth', 1.8, ...
        'DisplayName', sprintf('%.2f V', A));
end

hold off;
xlabel('Voltage, v(t) [V]');
ylabel('Current, i(t) [A]');
title('HP Joglekar model: I-V response at different amplitudes');
legend('Location','best');
grid on;
box off;

format_and_save_figure(hfig, fullfile(outdir,'HP_Joglekar_IV_amplitude_sweep'));

%% ============================================================
% Figure 7: hysteresis area versus frequency
% ============================================================
hfig = figure;

plot(freqs, area_freq, 'o-', ...
    'Color', C.green, ...
    'MarkerFaceColor', C.green, ...
    'MarkerEdgeColor', C.black, ...
    'LineWidth', 1.8);

xlabel('Frequency [Hz]');
ylabel('I-V loop area, |\oint i dv| [VA]');
title('HP Joglekar model: hysteresis area versus frequency');
grid on;
box off;

format_and_save_figure(hfig, fullfile(outdir,'HP_Joglekar_area_vs_frequency'));

%% ============================================================
% Figure 8: hysteresis area versus amplitude
% ============================================================
hfig = figure;

plot(amps, area_amp, 'o-', ...
    'Color', C.peach, ...
    'MarkerFaceColor', C.peach, ...
    'MarkerEdgeColor', C.black, ...
    'LineWidth', 1.8);

xlabel('Amplitude [V]');
ylabel('I-V loop area, |\oint i dv| [VA]');
title('HP Joglekar model: hysteresis area versus amplitude');
grid on;
box off;

format_and_save_figure(hfig, fullfile(outdir,'HP_Joglekar_area_vs_amplitude'));

%% ============================================================
% Save summary tables
% ============================================================
frequencyTable = table(freqs(:), area_freq(:), ...
    'VariableNames', {'Frequency_Hz','IV_Loop_Area'});

amplitudeTable = table(amps(:), area_amp(:), ...
    'VariableNames', {'Amplitude_V','IV_Loop_Area'});

writetable(frequencyTable, fullfile(outdir,'HP_Joglekar_frequency_sweep_summary.csv'));
writetable(amplitudeTable, fullfile(outdir,'HP_Joglekar_amplitude_sweep_summary.csv'));

disp(frequencyTable);
disp(amplitudeTable);

fprintf('\nFigures saved in:\n%s\n', outdir);

%% ============================================================
% Local function: Joglekar-window HP model solved with ode45
% ============================================================
function out = simulate_joglekar_ode45(tspan,A,f,params,p,opts)

    Vfun = @(t) A*sin(2*pi*f*t);

    odefun = @(t,x) params.eta ...
        *(params.mu*params.Ron/params.D^2) ...
        *(Vfun(t)/(params.Ron*x + params.Roff*(1-x))) ...
        *(1-(2*x-1)^(2*p));

    [t,x] = ode45(odefun,tspan,params.x0,opts);

    V = Vfun(t);
    M = params.Ron*x + params.Roff*(1-x);
    I = V./M;
    G = 1./M;
    q = cumtrapz(t,I);
    phi = cumtrapz(t,V);

    out.t = t;
    out.x = x;
    out.V = V;
    out.I = I;
    out.M = M;
    out.G = G;
    out.q = q;
    out.phi = phi;
end
