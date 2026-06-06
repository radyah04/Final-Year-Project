%% frequency_sweep_HPmodel_state_v2_clean.m
% Clean frequency sweep using HPmodel_state_v2.m exactly.
% Produces:
% 1) I-V loops
% 2) q-phi curves
% 3) voltage/current time plots
% 4) hysteresis loop area vs frequency

clear; close all; clc;

addpath('code/models');

%% Plot settings
set(groot,'defaultAxesFontName','Times New Roman');
set(groot,'defaultTextFontName','Times New Roman');
set(groot,'defaultAxesFontSize',12);
set(groot,'defaultLineLineWidth',0.9);

%% HP model v3 parameters
params.Ron  = 100;
params.Roff = 30000;
params.mu   = 1e-14;
params.D    = 10e-9;
params.x0   = 0.5;
params.eta  = -1;

%% Input settings
A = 0.2;                         % voltage amplitude [V]
freqs = [50 100 200 500 1000];   % safer frequency sweep [Hz]
T = 0.2;                         % same total time for all frequencies
N = 20000;
t = linspace(0,T,N);

%% Storage
area_IV = zeros(size(freqs));
deltaG = zeros(size(freqs));
results = struct();

%% Run sweep
for ff = 1:length(freqs)

    f = freqs(ff);
    V = A*sin(2*pi*f*t);

    out = HPmodel_state_v2(t,V,params);

    I = out.I;
    q = out.q;
    phi = out.phi;
    G = out.G;

    % Final cycle only
    idx = t >= (t(end) - 1/f);

    V_last = V(idx);
    I_last = I(idx);

    % Remove any NaNs
    valid = ~isnan(V_last) & ~isnan(I_last);
    V_last = V_last(valid);
    I_last = I_last(valid);

    % Geometric I-V loop area
    area_IV(ff) = polyarea(V_last, I_last);

    % Conductance change
    deltaG(ff) = G(end) - G(1);

    results(ff).f = f;
    results(ff).V = V;
    results(ff).I = I;
    results(ff).q = q;
    results(ff).phi = phi;
    results(ff).M = out.M;
    results(ff).G = G;
    results(ff).x = out.x;
    results(ff).idx = idx;
end

%% State evolution check
figure;
hold on;
for ff = 1:length(freqs)
    plot(t, results(ff).x, 'LineWidth', 0.9);
end
hold off;
xlabel('Time [s]');
ylabel('State variable, x(t)');
title('State evolution check');
legend(string(freqs) + " Hz", 'Location','best');
grid on; box on;

%% Figure 1: I-V loops, final cycle
figure;
hold on;
for ff = 1:length(freqs)
    idx = results(ff).idx;
    plot(results(ff).V(idx), results(ff).I(idx), 'LineWidth', 0.9);
end
hold off;
xlabel('Voltage, v(t) [V]');
ylabel('Current, i(t) [A]');
title('HP model v3: I-V response at different frequencies');
legend(string(freqs) + " Hz", 'Location','best');
grid on; box on;

%% Figure 2: q-phi curves, final cycle shifted to zero
figure;
hold on;
for ff = 1:length(freqs)
    idx = results(ff).idx;

    q_last = results(ff).q(idx);
    phi_last = results(ff).phi(idx);

    q_last = q_last - q_last(1);
    phi_last = phi_last - phi_last(1);

    plot(q_last, phi_last, 'LineWidth', 0.9);
end
hold off;
xlabel('Charge, q(t) [C]');
ylabel('Flux, \phi(t) [Wb]');
title('HP model v3: q-\phi response at different frequencies');
legend(string(freqs) + " Hz", 'Location','best');
grid on; box on;

%% Figure 3: input voltage and output current over time
% Plot only a few frequencies to avoid clutter.
selectedFreqs = [50 200 1000];

figure;
for s = 1:length(selectedFreqs)

    f_select = selectedFreqs(s);
    ff = find(freqs == f_select);

    subplot(length(selectedFreqs),2,2*s-1);
    plot(t, results(ff).V, 'LineWidth', 0.9);
    xlabel('Time [s]');
    ylabel('Voltage [V]');
    title(['Input voltage, f = ', num2str(f_select), ' Hz']);
    grid on; box on;

    subplot(length(selectedFreqs),2,2*s);
    plot(t, results(ff).I, 'LineWidth', 0.9);
    xlabel('Time [s]');
    ylabel('Current [A]');
    title(['Output current, f = ', num2str(f_select), ' Hz']);
    grid on; box on;
end

%% Figure 4: hysteresis loop area versus frequency
figure;
plot(freqs, area_IV, '-o', 'LineWidth', 0.9);
xlabel('Frequency [Hz]');
ylabel('I-V loop area [V A]');
title('Hysteresis loop area versus frequency');
grid on; box on;

%% Figure 5: conductance change versus frequency
figure;
plot(freqs, deltaG, '-o', 'LineWidth', 0.9);
xlabel('Frequency [Hz]');
ylabel('\DeltaG [S]');
title('Conductance change versus frequency');
grid on; box on;

%% Summary table
summaryTable = table(freqs(:), area_IV(:), deltaG(:), ...
    'VariableNames', {'Frequency_Hz','IV_Loop_Area','DeltaG_S'});

disp(summaryTable);
writetable(summaryTable, 'frequency_sweep_HPmodel_state_v2_summary.csv');
