%% HP_Prodromakis_final.m
% Prodromakis-window HP model: frequency and amplitude sweeps.
%
% Produces:
% 1) I-V response at 50 Hz
% 2) q-phi response at 50 Hz
% 3) q-phi points at 50 Hz
% 4) I-V response at different frequencies
% 5) q-phi response at different frequencies
% 6) I-V response at different amplitudes
% 7) input voltage and output current at 50 Hz
% 8) memristance response at 50 Hz
% 9) state evolution at 50 Hz
% 10) hysteresis area versus frequency
% 11) hysteresis area versus amplitude

clear; close all; clc;

%% ============================================================
% Output folder
% ============================================================
outdir = 'results/figures/HP_Prodromakis_final';

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
cols = [C.pink; C.blue; C.green; C.yellow; C.lilac; C.peach];

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
% Time and sweep parameters
% ============================================================
T = 0.2;           % simulation time [s]
N = 20000;         % number of time points
t = linspace(0,T,N);

freqs = [50 75 100 150 200];     % frequency sweep [Hz]
amps = [0.5 0.75 1.0 1.25 1.5];  % amplitude sweep [V]

f_main = 50;       % main frequency [Hz]
A_main = 1.0;      % main amplitude [V]

%% ============================================================
% Prodromakis HP-window parameters
% ============================================================
params.Ron = 100;
params.Roff = 30000;
params.mu = 1e-12;
params.D = 10e-9;
params.x0 = 0.1;   % start near OFF
params.eta = 1;
params.p1 = 1;     % Prodromakis window scaling parameter
params.p2 = 2;     % Prodromakis window exponent

%% ============================================================
% Main 50 Hz simulation
% ============================================================
V_main = A_main*sin(2*pi*f_main*t);
out_main = HP_Prodromakis(t,V_main,params);

period_main = 1/f_main;
idx_main = t >= (t(end)-period_main);

A_loop_main = abs(trapz(V_main(idx_main), out_main.I(idx_main)));

fprintf('\n================ HP Prodromakis model main case ================\n');
fprintf('f = %.1f Hz\n', f_main);
fprintf('A = %.2f V\n', A_main);
fprintf('Initial state x0 = %.3f\n', params.x0);
fprintf('p1 = %.3f, p2 = %.3f\n', params.p1, params.p2);
fprintf('I-V loop area = %.4e VA\n', A_loop_main);
fprintf('M range = %.2f to %.2f ohm\n', min(out_main.M), max(out_main.M));
fprintf('x range = %.4f to %.4f\n', min(out_main.x), max(out_main.x));

%% ============================================================
% Figure 1: I-V response at 50 Hz
% ============================================================
hfig = figure;

plot(V_main, out_main.I, ...
    'Color', C.pink, ...
    'LineWidth', 1.8);

xlabel('Voltage, v(t) [V]');
ylabel('Current, i(t) [A]');
title('Prodromakis HP model: I-V response at 50 Hz');
grid on;
box off;

format_and_save_figure(hfig, fullfile(outdir,'HP_Prodromakis_IV_50Hz'));

%% ============================================================
% Figure 2: q-phi response at 50 Hz
% ============================================================
hfig = figure;

plot(out_main.q, out_main.phi, ...
    'Color', C.lilac, ...
    'LineWidth', 1.8);

xlabel('Charge, q(t) [C]');
ylabel('Flux, \phi(t) [Wb]');
title('Prodromakis HP model: q-\phi response at 50 Hz');
grid on;
box off;

format_and_save_figure(hfig, fullfile(outdir,'HP_Prodromakis_qphi_50Hz'));

%% ============================================================
% Figure 3: q-phi points at 50 Hz
% ============================================================
hfig = figure;

skip = 10;
plot(out_main.q(1:skip:end), out_main.phi(1:skip:end), '.', ...
    'Color', C.lilac, ...
    'MarkerSize', 4);

xlabel('Charge, q(t) [C]');
ylabel('Flux, \phi(t) [Wb]');
title('Prodromakis HP model: q-\phi points at 50 Hz');
grid on;
box off;

format_and_save_figure(hfig, fullfile(outdir,'HP_Prodromakis_qphi_points_50Hz'));

%% ============================================================
% Figure 4: frequency sweep I-V
% ============================================================
area_freq = zeros(size(freqs));

hfig = figure;
hold on;

for kk = 1:length(freqs)

    f = freqs(kk);
    V = A_main*sin(2*pi*f*t);
    out = HP_Prodromakis(t,V,params);

    period = 1/f;
    idx = t >= (t(end)-period);

    area_freq(kk) = abs(trapz(V(idx), out.I(idx)));

    plot(V(idx), out.I(idx), ...
        'Color', cols(kk,:), ...
        'LineWidth', 1.8, ...
        'DisplayName', sprintf('%d Hz', f));
end

hold off;
xlabel('Voltage, v(t) [V]');
ylabel('Current, i(t) [A]');
title('Prodromakis HP model: I-V response at different frequencies');
legend('Location','best');
grid on;
box off;

format_and_save_figure(hfig, fullfile(outdir,'HP_Prodromakis_IV_frequency_sweep'));

%% ============================================================
% Figure 5: frequency sweep q-phi
% ============================================================
hfig = figure;
hold on;

for kk = 1:length(freqs)

    f = freqs(kk);
    V = A_main*sin(2*pi*f*t);
    out = HP_Prodromakis(t,V,params);

    period = 1/f;
    idx = t >= (t(end)-period);

    plot(out.q(idx), out.phi(idx), ...
        'Color', cols(kk,:), ...
        'LineWidth', 1.8, ...
        'DisplayName', sprintf('%d Hz', f));
end

hold off;
xlabel('Charge, q(t) [C]');
ylabel('Flux, \phi(t) [Wb]');
title('Prodromakis HP model: q-\phi response at different frequencies');
legend('Location','best');
grid on;
box off;

format_and_save_figure(hfig, fullfile(outdir,'HP_Prodromakis_qphi_frequency_sweep'));

%% ============================================================
% Figure 6: amplitude sweep I-V
% ============================================================
area_amp = zeros(size(amps));

hfig = figure;
hold on;

for kk = 1:length(amps)

    A = amps(kk);
    V = A*sin(2*pi*f_main*t);
    out = HP_Prodromakis(t,V,params);

    idx = t >= (t(end)-period_main);

    area_amp(kk) = abs(trapz(V(idx), out.I(idx)));

    plot(V(idx), out.I(idx), ...
        'Color', cols(kk,:), ...
        'LineWidth', 1.8, ...
        'DisplayName', sprintf('%.2f V', A));
end

hold off;
xlabel('Voltage, v(t) [V]');
ylabel('Current, i(t) [A]');
title('Prodromakis HP model: I-V response at different amplitudes');
legend('Location','best');
grid on;
box off;

format_and_save_figure(hfig, fullfile(outdir,'HP_Prodromakis_IV_amplitude_sweep'));

%% ============================================================
% Figure 7: input voltage and output current at 50 Hz
% ============================================================
hfig = figure;

yyaxis left
plot(t, V_main, ...
    'Color', C.pink, ...
    'LineWidth', 1.8);
ylabel('Voltage, v(t) [V]');
ax = gca;
ax.YColor = C.pink;

yyaxis right
plot(t, out_main.I, ...
    'Color', C.blue, ...
    'LineWidth', 1.8);
ylabel('Current, i(t) [A]');
ax = gca;
ax.YColor = C.blue;
ax.XColor = C.black;

xlabel('Time, t [s]');
title('Prodromakis HP model: input voltage and output current at 50 Hz');
grid on;
box off;

format_and_save_figure(hfig, fullfile(outdir,'HP_Prodromakis_voltage_current_time_50Hz'));

%% ============================================================
% Figure 8: memristance response at 50 Hz
% ============================================================
hfig = figure;

plot(t, out_main.M, ...
    'Color', C.yellow, ...
    'LineWidth', 1.8);

xlabel('Time, t [s]');
ylabel('Memristance, M(t) [\Omega]');
title('Prodromakis HP model: memristance response at 50 Hz');
grid on;
box off;

format_and_save_figure(hfig, fullfile(outdir,'HP_Prodromakis_memristance_50Hz'));

%% ============================================================
% Figure 9: state evolution at 50 Hz
% ============================================================
hfig = figure;

plot(t, out_main.x, ...
    'Color', C.green, ...
    'LineWidth', 1.8);

xlabel('Time, t [s]');
ylabel('State variable, x = w/D');
title('Prodromakis HP model: state evolution at 50 Hz');
grid on;
box off;

format_and_save_figure(hfig, fullfile(outdir,'HP_Prodromakis_state_50Hz'));

%% ============================================================
% Figure 10: hysteresis area versus frequency
% ============================================================
hfig = figure;

plot(freqs, area_freq, 'o-', ...
    'Color', C.green, ...
    'MarkerFaceColor', C.green, ...
    'MarkerEdgeColor', C.black, ...
    'LineWidth', 1.8);

xlabel('Frequency [Hz]');
ylabel('I-V loop area, |\oint i dv| [VA]');
title('Prodromakis HP model: hysteresis area versus frequency');
grid on;
box off;

format_and_save_figure(hfig, fullfile(outdir,'HP_Prodromakis_area_vs_frequency'));

%% ============================================================
% Figure 11: hysteresis area versus amplitude
% ============================================================
hfig = figure;

plot(amps, area_amp, 'o-', ...
    'Color', C.peach, ...
    'MarkerFaceColor', C.peach, ...
    'MarkerEdgeColor', C.black, ...
    'LineWidth', 1.8);

xlabel('Amplitude [V]');
ylabel('I-V loop area, |\oint i dv| [VA]');
title('Prodromakis HP model: hysteresis area versus amplitude');
grid on;
box off;

format_and_save_figure(hfig, fullfile(outdir,'HP_Prodromakis_area_vs_amplitude'));

%% ============================================================
% Save summary tables
% ============================================================
frequencyTable = table(freqs(:), area_freq(:), ...
    'VariableNames', {'Frequency_Hz','IV_Loop_Area'});

amplitudeTable = table(amps(:), area_amp(:), ...
    'VariableNames', {'Amplitude_V','IV_Loop_Area'});

writetable(frequencyTable, fullfile(outdir,'HP_Prodromakis_frequency_sweep_summary.csv'));
writetable(amplitudeTable, fullfile(outdir,'HP_Prodromakis_amplitude_sweep_summary.csv'));

disp(frequencyTable);
disp(amplitudeTable);

fprintf('\nFigures saved in:\n%s\n', outdir);

%% ============================================================
% Local function: Prodromakis-window HP model
% ============================================================
function out = HP_Prodromakis(t,V,params)

    Ron = params.Ron;
    Roff = params.Roff;
    mu = params.mu;
    D = params.D;
    x0 = params.x0;
    eta = params.eta;
    p1 = params.p1;
    p2 = params.p2;

    N = length(t);
    x = zeros(1,N);
    M = zeros(1,N);
    G = zeros(1,N);
    I = zeros(1,N);

    x(1) = x0;

    for k = 1:N-1

        M(k) = Ron*x(k) + Roff*(1-x(k));
        I(k) = V(k)/M(k);

        window = p1*(1 - ((x(k)-0.5)^2 + 0.75)^p2);
        dxdt = eta*(mu*Ron/D^2)*I(k)*window;

        x(k+1) = x(k) + dxdt*(t(k+1)-t(k));
        x(k+1) = min(max(x(k+1),0),1);
    end

    M(N) = Ron*x(N) + Roff*(1-x(N));
    I(N) = V(N)/M(N);
    G = 1./M;

    q = cumtrapz(t,I);
    phi = cumtrapz(t,V);

    out.I = I;
    out.M = M;
    out.G = G;
    out.x = x;
    out.q = q;
    out.phi = phi;
end

%% ============================================================
% Local function: pastel palette
% ============================================================
function C = pastel_palette_report()

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

    set(hfig, ...
        'Units', 'centimeters', ...
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
