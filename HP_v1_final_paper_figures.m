%% HP_v1_final_paper_figures.m
% HP model v1: analytical voltage-history HP model
%
% Produces:
% 1) I-V response at 50 Hz
% 2) I-V response at different frequencies
% 3) I-V response at different amplitudes
% 4) q-phi response at 50 Hz
% 5) memristance response at 50 Hz
% 6) input voltage and output current at 50 Hz

clear; close all; clc;

%% ============================================================
% Output folder
% ============================================================
outdir = 'results/figures/HP_v1_final';

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
% Main simulation settings
% ============================================================
f_main = 50;       % main frequency used later for network work
A_main = 1.0;      % voltage amplitude [V]

T = 0.2;
N = 20000;
t = linspace(0,T,N);

%% ============================================================
% HP v1 parameters
% ============================================================
params.Ron  = 100;
params.Roff = 30000;
params.mu   = 1e-12;
params.D    = 10e-9;

% Match the same initial memristance style used in HP v3
R0 = params.Roff/10;       % initial memristance [ohm]

% Analytical HP coefficient
k2 = (params.Roff - params.Ron) * params.mu * params.Ron / params.D^2;

%% ============================================================
% Main 50 Hz simulation
% ============================================================
V_main = A_main*sin(2*pi*f_main*t);

out_main = HPmodel_v1_analytical(t,V_main,R0,k2);

I_main   = out_main.I;
M_main   = out_main.M;
G_main   = out_main.G;
q_main   = out_main.q;
phi_main = out_main.phi;

period = 1/f_main;
idx_main = t >= (t(end)-period);

A_loop_main = abs(trapz(V_main(idx_main), I_main(idx_main)));

fprintf('\nHP v1 model main case\n');
fprintf('f = %.1f Hz, A = %.2f V\n', f_main, A_main);
fprintf('Initial memristance R0 = %.2f ohm\n', R0);
fprintf('I-V loop area = %.4e VA\n', A_loop_main);
fprintf('M range = %.2f to %.2f ohm\n', min(M_main), max(M_main));

%% ============================================================
% Figure 1: I-V at 50 Hz
% ============================================================
hfig = figure;
plot(V_main(idx_main), I_main(idx_main), ...
    'Color', C.pink, 'LineWidth', 2.0);
xlabel('Voltage, v(t) [V]');
ylabel('Current, i(t) [A]');
title('HP v1 model: I-V response at 50 Hz');
grid on;
box off;
format_and_save_figure(hfig, fullfile(outdir,'HPv1_IV_50Hz'));

%% ============================================================
% Figure 2: I-V at different frequencies
% ============================================================
freqs = [50 75 100 150 200];
cols = [C.pink; C.blue; C.green; C.yellow; C.lilac];

area_freq = zeros(size(freqs));

hfig = figure;
hold on;

for kk = 1:length(freqs)

    f = freqs(kk);
    V = A_main*sin(2*pi*f*t);

    out = HPmodel_v1_analytical(t,V,R0,k2);
    I = out.I;

    period = 1/f;
    idx = t >= (t(end)-period);

    area_freq(kk) = abs(trapz(V(idx), I(idx)));

    plot(V(idx), I(idx), ...
        'Color', cols(kk,:), ...
        'LineWidth', 1.8, ...
        'DisplayName', sprintf('%d Hz', f));
end

hold off;
xlabel('Voltage, v(t) [V]');
ylabel('Current, i(t) [A]');
title('HP v1 model: I-V response at different frequencies');
legend('Location','best');
grid on;
box off;
format_and_save_figure(hfig, fullfile(outdir,'HPv1_IV_frequency_sweep'));

%% ============================================================
% Figure 3: q-phi at 50 Hz
% ============================================================
hfig = figure;
plot(q_main, phi_main, ...
    'Color', C.lilac, 'LineWidth', 1.8);
xlabel('Charge, q(t) [C]');
ylabel('Flux, \phi(t) [Wb]');
title('HP v1 model: q-\phi response at 50 Hz');
grid on;
box off;
format_and_save_figure(hfig, fullfile(outdir,'HPv1_qphi_50Hz'));

%% ============================================================
% Figure 4: I-V at different amplitudes
% ============================================================
amps = [0.5 0.75 1.0 1.25 1.5];

area_amp = zeros(size(amps));

hfig = figure;
hold on;

for kk = 1:length(amps)

    A = amps(kk);
    V = A*sin(2*pi*f_main*t);

    out = HPmodel_v1_analytical(t,V,R0,k2);
    I = out.I;

    period = 1/f_main;
    idx = t >= (t(end)-period);

    area_amp(kk) = abs(trapz(V(idx), I(idx)));

    plot(V(idx), I(idx), ...
        'Color', cols(kk,:), ...
        'LineWidth', 1.8, ...
        'DisplayName', sprintf('%.2f V', A));
end

hold off;
xlabel('Voltage, v(t) [V]');
ylabel('Current, i(t) [A]');
title('HP v1 model: I-V response at different amplitudes');
legend('Location','best');
grid on;
box off;
format_and_save_figure(hfig, fullfile(outdir,'HPv1_IV_amplitude_sweep'));

%% ============================================================
% Figure 5: memristance at 50 Hz
% ============================================================
hfig = figure;
plot(t, M_main, ...
    'Color', C.blue, 'LineWidth', 1.8);
xlabel('Time, t [s]');
ylabel('Memristance, M(t) [\Omega]');
title('HP v1 model: memristance response at 50 Hz');
grid on;
box off;
format_and_save_figure(hfig, fullfile(outdir,'HPv1_memristance_50Hz'));

%% ============================================================
% Figure 6: input voltage and output current at 50 Hz
% Axis colours match plotted signal colours
% ============================================================
hfig = figure;

yyaxis left
plot(t, V_main, ...
    'Color', C.pink, 'LineWidth', 1.8);
ylabel('Voltage, v(t) [V]');
ax = gca;
ax.YColor = C.pink;

yyaxis right
plot(t, I_main, ...
    'Color', C.blue, 'LineWidth', 1.8);
ylabel('Current, i(t) [A]');
ax = gca;
ax.YColor = C.blue;

ax.XColor = C.black;

xlabel('Time, t [s]');
title('HP v1 model: input voltage and output current at 50 Hz');
grid on;
box off;
format_and_save_figure(hfig, fullfile(outdir,'HPv1_voltage_current_time_50Hz'));

%% ============================================================
% Optional: area summary plots
% ============================================================
hfig = figure;
plot(freqs, area_freq, 'o-', ...
    'Color', C.green, ...
    'MarkerFaceColor', C.green, ...
    'MarkerEdgeColor', C.black, ...
    'LineWidth', 1.8);
xlabel('Frequency [Hz]');
ylabel('I-V loop area, |\oint i dv| [VA]');
title('HP v1 model: hysteresis area versus frequency');
grid on;
box off;
format_and_save_figure(hfig, fullfile(outdir,'HPv1_area_vs_frequency'));

hfig = figure;
plot(amps, area_amp, 'o-', ...
    'Color', C.peach, ...
    'MarkerFaceColor', C.peach, ...
    'MarkerEdgeColor', C.black, ...
    'LineWidth', 1.8);
xlabel('Amplitude [V]');
ylabel('I-V loop area, |\oint i dv| [VA]');
title('HP v1 model: hysteresis area versus amplitude');
grid on;
box off;
format_and_save_figure(hfig, fullfile(outdir,'HPv1_area_vs_amplitude'));

%% ============================================================
% Save summary tables
% ============================================================
frequencyTable = table(freqs(:), area_freq(:), ...
    'VariableNames', {'Frequency_Hz','IV_Loop_Area'});

amplitudeTable = table(amps(:), area_amp(:), ...
    'VariableNames', {'Amplitude_V','IV_Loop_Area'});

writetable(frequencyTable, fullfile(outdir,'HPv1_frequency_sweep_summary.csv'));
writetable(amplitudeTable, fullfile(outdir,'HPv1_amplitude_sweep_summary.csv'));

disp(frequencyTable);
disp(amplitudeTable);

fprintf('\nFigures saved in:\n%s\n', outdir);

%% ============================================================
% Local function: HP v1 analytical model
% ============================================================
function out = HPmodel_v1_analytical(t,V,R0,k2)

    phi = cumtrapz(t,V);

    sqrt_arg = R0^2 - 2*k2*phi;

    % Avoid invalid square root if parameters are too aggressive
    if any(sqrt_arg <= 0)
        warning('HP v1: square-root argument became non-positive. Check amplitude, frequency, R0 or k2.');
        sqrt_arg(sqrt_arg <= 0) = NaN;
    end

    M = sqrt(sqrt_arg);
    I = V ./ M;
    G = 1 ./ M;

    q = cumtrapz(t,I);

    out.I = I;
    out.M = M;
    out.G = G;
    out.q = q;
    out.phi = phi;
end

%% ============================================================
% Local function: pastel palette
% ============================================================
function C = pastel_palette_report()
% Brighter pastel palette with good contrast for report plots

    C.pink   = [0.89 0.47 0.64];
    C.blue   = [0.42 0.67 0.91];
    C.green  = [0.50 0.79 0.60];
    C.yellow = [0.93 0.78 0.36];
    C.lilac  = [0.70 0.60 0.90];
    C.peach  = [0.95 0.67 0.52];

    C.black  = [0.10 0.10 0.10];
end

%% ============================================================
% Local function: formatting and export
% ============================================================
function format_and_save_figure(hfig, fname, picturewidth, hw_ratio)

    if nargin < 3
        picturewidth = 16;
    end

    if nargin < 4
        hw_ratio = 0.62;
    end

    set(hfig, 'Color', 'w');
    set(hfig, 'Units', 'centimeters', ...
        'Position', [3 3 picturewidth hw_ratio*picturewidth]);

    ax = findall(hfig,'type','axes');

    for k = 1:length(ax)
        set(ax(k), ...
            'FontName','Times New Roman', ...
            'FontSize',12, ...
            'LineWidth',1.0, ...
            'Box','off', ...
            'TickDir','out', ...
            'GridAlpha',0.12, ...
            'MinorGridAlpha',0.08);

        grid(ax(k),'on');

        % Keep x-axis black, but do not overwrite yyaxis coloured y-axes
        ax(k).XColor = [0.10 0.10 0.10];
    end

    lgd = findall(hfig,'type','legend');
    for k = 1:length(lgd)
        set(lgd(k), ...
            'Box','off', ...
            'FontName','Times New Roman', ...
            'FontSize',10);
    end

    drawnow;

    pos = get(hfig,'Position');

    set(hfig, ...
        'PaperPositionMode','Auto', ...
        'PaperUnits','centimeters', ...
        'PaperSize',[pos(3), pos(4)]);

    print(hfig, [fname '.png'], '-dpng', '-r600');
    print(hfig, [fname '.pdf'], '-dpdf', '-painters');
end
