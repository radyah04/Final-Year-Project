%% frequency_sweep_HPmodel_v3_matched_to_good_run.m
% Frequency sweep using the same HP model v3 settings as the good single run.
% Uses HPmodel_state_v2.m exactly.

clear; close all; clc;

addpath('code/models');

%% Plot settings
set(groot,'defaultAxesFontName','Times New Roman');
set(groot,'defaultTextFontName','Times New Roman');
set(groot,'defaultAxesFontSize',12);
set(groot,'defaultLineLineWidth',1.5);

%% Time settings
T = 0.2;
N = 20000;
t = linspace(0,T,N);

%% Frequency sweep
% Avoid very low frequencies first because they can saturate the state.
freqs = [50 75 100 150 200];

A = 1.0;

%% HP model v3 parameters: matched to your good run
params.Ron = 100;
params.Roff = 30000;
params.mu = 1e-12;
params.D = 10e-9;

R0 = params.Roff/10;
params.x0 = (params.Roff - R0)/(params.Roff - params.Ron);

params.eta = -1;

%% Storage
results = struct();
area_IV = zeros(size(freqs));
x_min = zeros(size(freqs));
x_max = zeros(size(freqs));

%% Run sweep
for ff = 1:length(freqs)

    f = freqs(ff);
    V = A*sin(2*pi*f*t);

    out = HPmodel_state_v2(t,V,params);

    I = out.I;
    q = out.q;
    phi = out.phi;
    x = out.x;

    period = 1/f;
    idx = t >= (t(end) - period);

    V_last = V(idx);
    I_last = I(idx);

    area_IV(ff) = polyarea(V_last,I_last);

    x_min(ff) = min(x);
    x_max(ff) = max(x);

    results(ff).f = f;
    results(ff).V = V;
    results(ff).I = I;
    results(ff).q = q;
    results(ff).phi = phi;
    results(ff).M = out.M;
    results(ff).G = out.G;
    results(ff).x = x;
    results(ff).idx = idx;
end

%% Figure 1: I-V loops, final cycle only
figure;
hold on;
for ff = 1:length(freqs)
    idx = results(ff).idx;
    plot(results(ff).V(idx), results(ff).I(idx));
end
hold off;
xlabel('Voltage, v(t) [V]');
ylabel('Current, i(t) [A]');
title('HP model v3: I-V response at different frequencies');
legend(string(freqs) + " Hz", 'Location','best');
grid on; box on;

%% Figure 2: q-phi response
figure;
hold on;
for ff = 1:length(freqs)
    plot(results(ff).q, results(ff).phi);
end
hold off;
xlabel('Charge, q(t) [C]');
ylabel('Flux, \phi(t) [Wb]');
title('HP model v3: q-\phi response at different frequencies');
legend(string(freqs) + " Hz", 'Location','best');
grid on; box on;

%% Figure 3: input voltage and output current over time
selectedFreqs = [50 100 200];

figure;
for s = 1:length(selectedFreqs)

    f_select = selectedFreqs(s);
    ff = find(freqs == f_select);

    subplot(length(selectedFreqs),2,2*s-1);
    plot(t,results(ff).V);
    xlabel('Time [s]');
    ylabel('Voltage [V]');
    title(['Input voltage, f = ', num2str(f_select), ' Hz']);
    grid on; box on;

    subplot(length(selectedFreqs),2,2*s);
    plot(t,results(ff).I);
    xlabel('Time [s]');
    ylabel('Current [A]');
    title(['Output current, f = ', num2str(f_select), ' Hz']);
    grid on; box on;
end

%% Figure 4: hysteresis area versus frequency
figure;
plot(freqs, area_IV, '-o');
xlabel('Frequency [Hz]');
ylabel('I-V loop area [V A]');
title('Hysteresis loop area versus frequency');
grid on; box on;

%% Figure 5: state evolution check
figure;
hold on;
for ff = 1:length(freqs)
    plot(t, results(ff).x);
end
hold off;
xlabel('Time [s]');
ylabel('State variable, x(t)');
title('State evolution at different frequencies');
legend(string(freqs) + " Hz", 'Location','best');
grid on; box on;

%% Summary table
summaryTable = table(freqs(:), area_IV(:), x_min(:), x_max(:), ...
    'VariableNames', {'Frequency_Hz','IV_Loop_Area','Min_x','Max_x'});

disp(summaryTable);

%% Warning check
fprintf('\nSaturation check:\n');
for ff = 1:length(freqs)
    if x_min(ff) <= 0 || x_max(ff) >= 1
        fprintf('%d Hz: WARNING, state reached boundary. x range = %.4f to %.4f\n', ...
            freqs(ff), x_min(ff), x_max(ff));
    else
        fprintf('%d Hz: OK. x range = %.4f to %.4f\n', ...
            freqs(ff), x_min(ff), x_max(ff));
    end
end
