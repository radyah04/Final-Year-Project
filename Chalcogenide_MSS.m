%% Chalcogenide_MSS.m
% Chalcogenide/MSS model: nonlinear ODE state-update, full plots and sweeps.
%
% Produces:
% 1) I-V response at 50 Hz
% 2) q-phi points at 50 Hz
% 3) input voltage and output current at 50 Hz
% 4) conductance response at 50 Hz
% 5) state response at 50 Hz
% 6) I-V response at different frequencies
% 7) I-V response at different amplitudes
% 8) hysteresis area versus frequency
% 9) hysteresis area versus amplitude

clear; close all; clc;

%% ============================================================
% Output folder
% ============================================================
outdir = 'results/figures/Chalcogenide_MSS_full';

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
% Simulation parameters
% ============================================================
T = 0.02;           % one period at 50 Hz [s]
N = 20000;
t = linspace(0,T,N);

f_main = 50;        % main frequency [Hz]
A_main = 0.5;       % voltage amplitude [V]
V_main = A_main*sin(2*pi*f_main*t);

freqs = [50 75 100 150 200];
amps = [0.25 0.5 0.75 1.0 1.25 1.5];

%% ============================================================
% Chalcogenide/MSS parameters: nonlinear ODE
% ============================================================
params.G_ON = 1e-3;    % ON conductance [S]
params.G_OFF = 1e-5;   % OFF conductance [S]
params.X0 = 0.1;       % initial normalized state
% Tuned so the positive half-cycle produces visible q-phi curvature.
params.tau = 5e-4;     % time constant [s]
params.beta = 35;      % switching steepness
params.V_on = 0.18;    % positive threshold [V]
params.V_off = 0.27;   % negative threshold [V]

out_main = simulate_chalcogenide_mss(t,V_main,params);

A_loop_main = abs(trapz(V_main,out_main.I));

fprintf('\n================ Chalcogenide/MSS nonlinear model main case ================\n');
fprintf('f = %.1f Hz\n', f_main);
fprintf('A = %.2f V\n', A_main);
fprintf('Initial state X0 = %.3f\n', params.X0);
fprintf('tau = %.4e s\n', params.tau);
fprintf('beta = %.2f\n', params.beta);
fprintf('I-V loop area = %.4e VA\n', A_loop_main);
fprintf('G range = %.4e to %.4e S\n', min(out_main.G), max(out_main.G));
fprintf('X range = %.4f to %.4f\n', min(out_main.X), max(out_main.X));

%% ============================================================
% Figure 1: I-V response at 50 Hz
% ============================================================
hfig = figure;

plot(V_main,out_main.I, ...
    'Color', C.pink, ...
    'LineWidth', 1.8);

xlabel('Voltage, v(t) [V]');
ylabel('Current, i(t) [A]');
title('Chalcogenide/MSS model: I-V response at 50 Hz');
grid on;
box off;

format_and_save_figure(hfig, fullfile(outdir,'Chalcogenide_MSS_IV_50Hz'));

%% ============================================================
% Figure 2: q-phi points at 50 Hz
% ============================================================
hfig = figure;

skip = 25;
idx_qphi = t <= (0.5/f_main);

q_qphi = out_main.q(idx_qphi);
phi_qphi = out_main.phi(idx_qphi);

scatter(q_qphi(1:skip:end), phi_qphi(1:skip:end), ...
    10, ...
    'MarkerFaceColor', C.lilac, ...
    'MarkerEdgeColor', 'none', ...
    'MarkerFaceAlpha', 0.65);

xlabel('Charge, q(t) [C]');
ylabel('Flux, \phi(t) [Wb]');
title('Chalcogenide/MSS model: q-\phi points at 50 Hz');
grid on;
box off;

format_and_save_figure(hfig, fullfile(outdir,'Chalcogenide_MSS_qphi_50Hz'));

%% ============================================================
% Figure 3: input voltage and output current at 50 Hz
% ============================================================
hfig = figure;

yyaxis left
plot(t,V_main, ...
    'Color', C.pink, ...
    'LineWidth', 1.8);
ylabel('Voltage, v(t) [V]');
ax = gca;
ax.YColor = C.pink;

yyaxis right
plot(t,out_main.I, ...
    'Color', C.blue, ...
    'LineWidth', 1.8);
ylabel('Current, i(t) [A]');
ax = gca;
ax.YColor = C.blue;
ax.XColor = C.black;

xlabel('Time, t [s]');
title('Chalcogenide/MSS model: input voltage and output current at 50 Hz');
grid on;
box off;

format_and_save_figure(hfig, fullfile(outdir,'Chalcogenide_MSS_voltage_current_time_50Hz'));

%% ============================================================
% Figure 4: conductance response at 50 Hz
% ============================================================
hfig = figure;

plot(t,out_main.G, ...
    'Color', C.green, ...
    'LineWidth', 1.8);

xlabel('Time, t [s]');
ylabel('Conductance, G(t) [S]');
title('Chalcogenide/MSS model: conductance response at 50 Hz');
grid on;
box off;

format_and_save_figure(hfig, fullfile(outdir,'Chalcogenide_MSS_conductance_50Hz'));

%% ============================================================
% Figure 5: state response at 50 Hz
% ============================================================
hfig = figure;

plot(t,out_main.X, ...
    'Color', C.peach, ...
    'LineWidth', 1.8);

xlabel('Time, t [s]');
ylabel('State variable, X(t)');
title('Chalcogenide/MSS model: state response at 50 Hz');
grid on;
box off;

format_and_save_figure(hfig, fullfile(outdir,'Chalcogenide_MSS_state_50Hz'));

%% ============================================================
% Figure 6: I-V response at different frequencies
% ============================================================
area_freq = zeros(size(freqs));

hfig = figure;
hold on;

for kk = 1:length(freqs)

    f = freqs(kk);
    t_sweep = linspace(0,1/f,N);
    V_sweep = A_main*sin(2*pi*f*t_sweep);
    out = simulate_chalcogenide_mss(t_sweep,V_sweep,params);

    area_freq(kk) = abs(trapz(V_sweep,out.I));

    plot(V_sweep,out.I, ...
        'Color', cols(kk,:), ...
        'LineWidth', 1.8, ...
        'DisplayName', sprintf('%d Hz', f));
end

hold off;
xlabel('Voltage, v(t) [V]');
ylabel('Current, i(t) [A]');
title('Chalcogenide/MSS model: I-V response at different frequencies');
legend('Location','best');
grid on;
box off;

format_and_save_figure(hfig, fullfile(outdir,'Chalcogenide_MSS_IV_frequency_sweep'));

%% ============================================================
% Figure 7: I-V response at different amplitudes
% ============================================================
area_amp = zeros(size(amps));

hfig = figure;
hold on;

for kk = 1:length(amps)

    A = amps(kk);
    V_sweep = A*sin(2*pi*f_main*t);
    out = simulate_chalcogenide_mss(t,V_sweep,params);

    area_amp(kk) = abs(trapz(V_sweep,out.I));

    plot(V_sweep,out.I, ...
        'Color', cols(kk,:), ...
        'LineWidth', 1.8, ...
        'DisplayName', sprintf('%.2f V', A));
end

hold off;
xlabel('Voltage, v(t) [V]');
ylabel('Current, i(t) [A]');
title('Chalcogenide/MSS model: I-V response at different amplitudes');
legend('Location','best');
grid on;
box off;

format_and_save_figure(hfig, fullfile(outdir,'Chalcogenide_MSS_IV_amplitude_sweep'));

%% ============================================================
% Figure 8: hysteresis area versus frequency
% ============================================================
hfig = figure;

plot(freqs, area_freq, 'o-', ...
    'Color', C.green, ...
    'MarkerFaceColor', C.green, ...
    'MarkerEdgeColor', C.black, ...
    'LineWidth', 1.8);

xlabel('Frequency [Hz]');
ylabel('I-V loop area, |\oint i dv| [VA]');
title('Chalcogenide/MSS model: hysteresis area versus frequency');
grid on;
box off;

format_and_save_figure(hfig, fullfile(outdir,'Chalcogenide_MSS_area_vs_frequency'));

%% ============================================================
% Figure 9: hysteresis area versus amplitude
% ============================================================
hfig = figure;

plot(amps, area_amp, 'o-', ...
    'Color', C.peach, ...
    'MarkerFaceColor', C.peach, ...
    'MarkerEdgeColor', C.black, ...
    'LineWidth', 1.8);

xlabel('Amplitude [V]');
ylabel('I-V loop area, |\oint i dv| [VA]');
title('Chalcogenide/MSS model: hysteresis area versus amplitude');
grid on;
box off;

format_and_save_figure(hfig, fullfile(outdir,'Chalcogenide_MSS_area_vs_amplitude'));

%% ============================================================
% Save summary tables
% ============================================================
frequencyTable = table(freqs(:), area_freq(:), ...
    'VariableNames', {'Frequency_Hz','IV_Loop_Area'});

amplitudeTable = table(amps(:), area_amp(:), ...
    'VariableNames', {'Amplitude_V','IV_Loop_Area'});

writetable(frequencyTable, fullfile(outdir,'Chalcogenide_MSS_frequency_sweep_summary.csv'));
writetable(amplitudeTable, fullfile(outdir,'Chalcogenide_MSS_amplitude_sweep_summary.csv'));

disp(frequencyTable);
disp(amplitudeTable);

fprintf('\nFigures saved in:\n%s\n', outdir);

%% ============================================================
% Local function: nonlinear Chalcogenide/MSS state update
% ============================================================
function out = simulate_chalcogenide_mss(t,V,params)

    N = length(t);

    X = zeros(1,N);
    I = zeros(1,N);
    G = zeros(1,N);

    X(1) = params.X0;

    for k = 1:N-1

        G(k) = X(k)*params.G_ON + (1-X(k))*params.G_OFF;
        I(k) = G(k)*V(k);

        p_on = 1/(1 + exp(-params.beta*(V(k)-params.V_on)));
        p_off = 1/(1 + exp(-params.beta*(-V(k)-params.V_off)));
        dxdt = ((1-X(k))*p_on - X(k)*p_off)/params.tau;

        X(k+1) = X(k) + dxdt*(t(k+1)-t(k));
        X(k+1) = min(max(X(k+1),0),1);
    end

    G(N) = X(N)*params.G_ON + (1-X(N))*params.G_OFF;
    I(N) = G(N)*V(N);

    out.X = X;
    out.I = I;
    out.G = G;
    out.q = cumtrapz(t,I);
    out.phi = cumtrapz(t,V);
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
