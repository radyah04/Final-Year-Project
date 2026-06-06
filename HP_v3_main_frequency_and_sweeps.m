%% HP_v3_main_frequency_and_sweeps.m
% HP model v3: explicit state-update model
%
% This script produces:
% 1) Main 50 Hz results
% 2) I-V comparison for different frequencies
% 3) I-V comparison for different amplitudes
% 4) Hysteresis loop area calculations
%
% Main frequency for later network simulations:
% f_main = 50 Hz

clear; close all; clc;
C = pastel_palette_report();

set(groot,'defaultFigureColor','w');
set(groot,'defaultAxesColor','w');
set(groot,'defaultAxesFontName','Times New Roman');
set(groot,'defaultTextFontName','Times New Roman');
set(groot,'defaultAxesFontSize',12);
set(groot,'defaultAxesBox','off');
set(groot,'defaultAxesTickDir','out');
set(groot,'defaultAxesLineWidth',1.0);
set(groot,'defaultLineLineWidth',1.8);
set(groot,'defaultFigureVisible','on');

addpath('code/models');

%% ============================================================
% Figure export settings
% ============================================================
outdir = 'results/figures_HP_v3_sweeps';

if ~exist('results','dir')
    mkdir('results');
end

if ~exist(outdir,'dir')
    mkdir(outdir);
end

%% ============================================================
% Main simulation settings
% ============================================================
T = 0.2;
N = 20000;
t = linspace(0,T,N);

f_main = 50;      % main frequency used later for network simulations
A_main = 1.0;     % main voltage amplitude

%% ============================================================
% HP model v3 parameters
% Matched to your good single-memristor run
% ============================================================
params.Ron = 100;
params.Roff = 30000;
params.mu = 1e-12;
params.D = 10e-9;

R0 = params.Roff/10;
params.x0 = (params.Roff - R0)/(params.Roff - params.Ron);

params.eta = -1;

%% ============================================================
% Main 50 Hz simulation
% ============================================================
V_main = A_main*sin(2*pi*f_main*t);
out_main = HPmodel_state_v2(t,V_main,params);

I_main = out_main.I;
q_main = out_main.q;
phi_main = out_main.phi;
M_main = out_main.M;
G_main = out_main.G;
x_main = out_main.x;

idx_main = t >= (t(end) - 1/f_main);

V_last = V_main(idx_main);
I_last = I_main(idx_main);

A_loop_main = abs(trapz(V_last,I_last));

fprintf('\nMain case: f = %g Hz, A = %g V\n', f_main, A_main);
fprintf('Initial state x0 = %.4f\n', params.x0);
fprintf('Initial memristance R0 = %.2f ohm\n', R0);
fprintf('I-V loop area = %.4e V A\n', A_loop_main);
fprintf('State range: x = %.4f to %.4f\n', min(x_main), max(x_main));

%% ============================================================
% Figure 1: main I-V loop at 50 Hz
% ============================================================
hfig = figure;
plot(V_main(idx_main), I_main(idx_main), '-', ...
    'Color', C.pink, ...
    'LineWidth', 2.0, ...
    'DisplayName', '50 Hz');
xlabel('Voltage, v(t) [V]');
ylabel('Current, i(t) [A]');
title('HP v3 model: I-V response at 50 Hz');
legend('Location','best');
grid on;
box on;
format_and_save_figure(hfig, fullfile(outdir,'HPv3_IV_50Hz'));

%% ============================================================
% Figure 2: main q-phi response
% ============================================================
hfig = figure;
plot(q_main, phi_main, 'Color', C.lilac, 'LineWidth', 1.8);
xlabel('Charge, q(t) [C]');
ylabel('Flux, \phi(t) [Wb]');
title('HP v3 model: q-\phi response at 50 Hz');
grid on;
box on;
format_and_save_figure(hfig, fullfile(outdir,'HPv3_q_phi_50Hz'));

%% ============================================================
% Figure 3: input voltage and output current over time
% ============================================================
hfig = figure;

yyaxis left;
plot(t, V_main, 'Color', C.pink, 'LineWidth', 1.8);
ylabel('Voltage, $v(t)$ [V]', 'Interpreter','latex');
ax = gca;
ax.YColor = C.pink;

yyaxis right;
plot(t, I_main, 'Color', C.blue, 'LineWidth', 1.8);
ylabel('Current, $i(t)$ [A]', 'Interpreter','latex');
ax.YColor = C.blue;

ax.XColor = C.black;
xlabel('Time, $t$ [s]', 'Interpreter','latex');
title('HP v3 model: input voltage and output current at 50 Hz');
grid on;
box off;
format_and_save_figure(hfig, fullfile(outdir,'HPv3_voltage_current_time_50Hz'));

%% ============================================================
% Figure 4: state variable x(t)
% ============================================================
hfig = figure;
plot(t, x_main, 'Color', C.lilac, 'LineWidth', 1.8);
xlabel('Time, t [s]');
ylabel('State variable, x(t)');
title('HP v3 model: state evolution at 50 Hz');
grid on;
box on;
format_and_save_figure(hfig, fullfile(outdir,'HPv3_state_time_50Hz'));

%% ============================================================
% Figure 5: memristance M(t)
% ============================================================
hfig = figure;
plot(t, M_main, 'Color', C.blue, 'LineWidth', 1.8);
xlabel('Time, t [s]');
ylabel('Memristance, M(t) [\Omega]');
title('HP v3 model: memristance response at 50 Hz');
grid on;
box on;
format_and_save_figure(hfig, fullfile(outdir,'HPv3_memristance_time_50Hz'));

%% ============================================================
% Figure 6: conductance G(t)
% ============================================================
hfig = figure;
plot(t, G_main, 'Color', C.green, 'LineWidth', 1.8);
xlabel('Time, t [s]');
ylabel('Conductance, G(t) [S]');
title('HP v3 model: conductance response at 50 Hz');
grid on;
box on;
format_and_save_figure(hfig, fullfile(outdir,'HPv3_conductance_time_50Hz'));

%% ============================================================
% Frequency sweep: I-V only
% ============================================================
freqs = [50 75 100 150 200];
area_freq = zeros(size(freqs));
x_min_freq = zeros(size(freqs));
x_max_freq = zeros(size(freqs));

freq_results = struct();
cols = [C.pink; C.blue; C.green; C.yellow; C.lilac];

for kk = 1:length(freqs)

    f = freqs(kk);
    V = A_main*sin(2*pi*f*t);

    out = HPmodel_state_v2(t,V,params);

    idx = t >= (t(end) - 1/f);

    V_last = V(idx);
    I_last = out.I(idx);

    area_freq(kk) = abs(trapz(V_last,I_last));
    x_min_freq(kk) = min(out.x);
    x_max_freq(kk) = max(out.x);

    freq_results(kk).f = f;
    freq_results(kk).V = V;
    freq_results(kk).I = out.I;
    freq_results(kk).idx = idx;
end

hfig = figure;
hold on;
for kk = 1:length(freqs)
    idx = freq_results(kk).idx;
    plot(freq_results(kk).V(idx), freq_results(kk).I(idx), ...
        'Color', cols(kk,:), ...
        'LineWidth', 1.8, ...
        'DisplayName', [num2str(freqs(kk)) ' Hz']);
end
hold off;
xlabel('Voltage, v(t) [V]');
ylabel('Current, i(t) [A]');
title('HP v3 model: I-V response at different frequencies');
legend('Location','best');
grid on;
box on;
format_and_save_figure(hfig, fullfile(outdir,'HPv3_IV_different_frequencies'));

%% ============================================================
% Frequency sweep area plot
% ============================================================
hfig = figure;
plot(freqs, area_freq, '-o', ...
    'Color', C.lilac, ...
    'MarkerFaceColor', C.lilac, ...
    'MarkerEdgeColor', C.lilac, ...
    'LineWidth', 1.8, ...
    'MarkerSize', 5);
xlabel('Frequency [Hz]');
ylabel('I-V loop area [VA]');
title('Hysteresis loop area versus frequency');
grid on;
box on;
format_and_save_figure(hfig, fullfile(outdir,'HP_v3_frequency_sweep_area'));

%% ============================================================
% Amplitude sweep: I-V only
% ============================================================
amps = [0.25 0.5 0.75 1.0 1.25];
area_amp = zeros(size(amps));
x_min_amp = zeros(size(amps));
x_max_amp = zeros(size(amps));

amp_results = struct();

for kk = 1:length(amps)

    A = amps(kk);
    V = A*sin(2*pi*f_main*t);

    out = HPmodel_state_v2(t,V,params);

    idx = t >= (t(end) - 1/f_main);

    V_last = V(idx);
    I_last = out.I(idx);

    area_amp(kk) = abs(trapz(V_last,I_last));
    x_min_amp(kk) = min(out.x);
    x_max_amp(kk) = max(out.x);

    amp_results(kk).A = A;
    amp_results(kk).V = V;
    amp_results(kk).I = out.I;
    amp_results(kk).idx = idx;
end

hfig = figure;
hold on;
for kk = 1:length(amps)
    idx = amp_results(kk).idx;
    plot(amp_results(kk).V(idx), amp_results(kk).I(idx), ...
        'Color', cols(kk,:), ...
        'LineWidth', 1.8, ...
        'DisplayName', ['A = ' num2str(amps(kk)) ' V']);
end
hold off;
xlabel('Voltage, v(t) [V]');
ylabel('Current, i(t) [A]');
title('HP v3 model: I-V response at different amplitudes');
legend('Location','best');
grid on;
box on;
format_and_save_figure(hfig, fullfile(outdir,'HPv3_IV_different_amplitudes'));

%% ============================================================
% Amplitude sweep area plot
% ============================================================
hfig = figure;
plot(amps, area_amp, '-o', ...
    'Color', C.lilac, ...
    'MarkerFaceColor', C.lilac, ...
    'MarkerEdgeColor', C.lilac, ...
    'LineWidth', 1.8, ...
    'MarkerSize', 5);
xlabel('Amplitude [V]');
ylabel('I-V loop area [VA]');
title('Hysteresis loop area versus amplitude');
grid on;
box on;
format_and_save_figure(hfig, fullfile(outdir,'HP_v3_amplitude_sweep_area'));

%% ============================================================
% Save summary table
% ============================================================
frequencyTable = table(freqs(:), area_freq(:), x_min_freq(:), x_max_freq(:), ...
    'VariableNames', {'Frequency_Hz','IV_Loop_Area','Min_x','Max_x'});

amplitudeTable = table(amps(:), area_amp(:), x_min_amp(:), x_max_amp(:), ...
    'VariableNames', {'Amplitude_V','IV_Loop_Area','Min_x','Max_x'});

disp(frequencyTable);
disp(amplitudeTable);

writetable(frequencyTable, fullfile(outdir,'HP_v3_frequency_sweep_summary.csv'));
writetable(amplitudeTable, fullfile(outdir,'HP_v3_amplitude_sweep_summary.csv'));

fprintf('\nFigures saved in: %s\n', outdir);
