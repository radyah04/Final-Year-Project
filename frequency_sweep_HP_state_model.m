%% frequency_sweep_HP_state_model.m
% Frequency sweep for explicit state-update HP memristor model.
% Produces:
% 1) I-V loops for different frequencies
% 2) q-phi curves for different frequencies
% 3) input voltage and output current over time
% 4) hysteresis loop area versus frequency

clear; close all; clc;

%% Plot settings
set(groot,'defaultAxesFontName','Times New Roman');
set(groot,'defaultTextFontName','Times New Roman');
set(groot,'defaultAxesFontSize',12);
set(groot,'defaultLineLineWidth',0.9);

%% HP parameters
params.Ron  = 100;        % Ohm
params.Roff = 30000;      % Ohm
params.mu   = 1.5e-12;    % ion mobility
params.D    = 10e-9;      % device thickness [m]
params.eta  = -1;         % polarity convention
params.x0   = 0.3;        % initial state

%% Input settings
A = 1.0;                  % voltage amplitude [V]
freqs = [10 25 50 100 250 500];   % frequencies to test [Hz]

nCycles = 5;              % simulate same number of cycles for each frequency
samplesPerCycle = 2000;   % resolution per cycle

%% Storage
area_IV = zeros(size(freqs));
deltaG = zeros(size(freqs));

results = struct();

%% Run frequency sweep
for ff = 1:length(freqs)

    f = freqs(ff);

    T = nCycles/f;
    N = nCycles*samplesPerCycle;
    t = linspace(0,T,N);
    dt = t(2)-t(1);

    V = A*sin(2*pi*f*t);

    out = simulate_HP_state(t,V,params);

    I = out.I;
    M = out.M;
    G = out.G;
    x = out.x;
    q = out.q;
    phi = out.phi;

    % Final cycle only for clean I-V loop
    idx = t >= (t(end) - 1/f);

    V_last = V(idx);
    I_last = I(idx);

    % Hysteresis loop area in I-V plane
    % This is geometric loop area, useful for comparing frequency effect.
    area_IV(ff) = polyarea(V_last, I_last);

    % Conductance change across simulation
    deltaG(ff) = G(end) - G(1);

    % Store
    results(ff).f = f;
    results(ff).t = t;
    results(ff).V = V;
    results(ff).I = I;
    results(ff).M = M;
    results(ff).G = G;
    results(ff).x = x;
    results(ff).q = q;
    results(ff).phi = phi;
    results(ff).idx = idx;
end

%% Figure 1: I-V loops for different frequencies
figure;
hold on;
for ff = 1:length(freqs)
    idx = results(ff).idx;
    plot(results(ff).V(idx), results(ff).I(idx), 'LineWidth', 0.9);
end
hold off;
xlabel('Voltage, v(t) [V]');
ylabel('Current, i(t) [A]');
title('HP state-update model: I-V response at different frequencies');
legend(string(freqs) + " Hz", 'Location','best');
grid on; box on;

%% Figure 2: q-phi curves for different frequencies
figure;
hold on;
for ff = 1:length(freqs)
    idx = results(ff).idx;

    q_last = results(ff).q(idx);
    phi_last = results(ff).phi(idx);

    % Shift final cycle to start at zero for easier comparison
    q_last = q_last - q_last(1);
    phi_last = phi_last - phi_last(1);

    plot(q_last, phi_last, 'LineWidth', 0.9);
end
hold off;
xlabel('Charge, q(t) [C]');
ylabel('Flux, \phi(t) [Wb]');
title('HP state-update model: q-\phi response at different frequencies');
legend(string(freqs) + " Hz", 'Location','best');
grid on; box on;

%% Figure 3: input voltage and output current over time
% To avoid clutter, plot selected frequencies only.
selectedFreqs = [10 50 250];
figure;
for s = 1:length(selectedFreqs)
    f_select = selectedFreqs(s);
    ff = find(freqs == f_select);

    t = results(ff).t;
    V = results(ff).V;
    I = results(ff).I;

    subplot(length(selectedFreqs),2,2*s-1);
    plot(t,V,'LineWidth',0.9);
    xlabel('Time [s]');
    ylabel('Voltage [V]');
    title(['Input voltage, f = ', num2str(f_select), ' Hz']);
    grid on; box on;

    subplot(length(selectedFreqs),2,2*s);
    plot(t,I,'LineWidth',0.9);
    xlabel('Time [s]');
    ylabel('Current [A]');
    title(['Output current, f = ', num2str(f_select), ' Hz']);
    grid on; box on;
end

%% Figure 4: hysteresis loop area versus frequency
figure;
plot(freqs, area_IV, '-o', 'LineWidth', 0.9);
xlabel('Frequency [Hz]');
ylabel('I-V loop area');
title('Hysteresis loop area versus frequency');
grid on; box on;

%% Figure 5: conductance change versus frequency
figure;
plot(freqs, deltaG, '-o', 'LineWidth', 0.9);
xlabel('Frequency [Hz]');
ylabel('\DeltaG [S]');
title('Conductance change versus frequency');
grid on; box on;

%% Print summary table
summaryTable = table(freqs(:), area_IV(:), deltaG(:), ...
    'VariableNames', {'Frequency_Hz','IV_Loop_Area','DeltaG_S'});

disp(summaryTable);

%% Optional: save table
writetable(summaryTable, 'frequency_sweep_HP_summary.csv');

%% ============================================================
% Local function: explicit state-update HP model
% ============================================================
function out = simulate_HP_state(t,V,params)

    N = length(t);
    dt = t(2)-t(1);

    Ron = params.Ron;
    Roff = params.Roff;
    mu = params.mu;
    D = params.D;
    eta = params.eta;
    x0 = params.x0;

    x = zeros(1,N);
    M = zeros(1,N);
    G = zeros(1,N);
    I = zeros(1,N);

    x(1) = x0;

    for k = 1:N-1

        M(k) = Ron*x(k) + Roff*(1 - x(k));
        G(k) = 1/M(k);
        I(k) = V(k)/M(k);

        dxdt = eta*(mu*Ron/D^2)*I(k);
        x(k+1) = x(k) + dxdt*dt;

        % physical state bounds
        x(k+1) = min(max(x(k+1),0),1);
    end

    M(N) = Ron*x(N) + Roff*(1 - x(N));
    G(N) = 1/M(N);
    I(N) = V(N)/M(N);

    q = cumtrapz(t,I);
    phi = cumtrapz(t,V);

    out.I = I;
    out.M = M;
    out.G = G;
    out.x = x;
    out.q = q;
    out.phi = phi;
end
