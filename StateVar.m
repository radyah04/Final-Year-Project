%% State Variable Analysis: HP vs. Chalcogenide
clear, clc, close all;

% Parameters
Fs = 100000; dt = 1/Fs;
freqs = [10, 100, 1000]; % Low, Medium, High
t_total = 0.05; % Fixed time window to compare oscillations

figure('Color', 'w', 'Position', [100 100 1200 500]);

for i = 1:length(freqs)
    f = freqs(i);
    t = 0:dt:t_total;
    V = 1.0 * sin(2 * pi * f * t);
    
    % --- 1. HP State Variable (w/D) ---
    [~, M_hp] = HPmodel_simple(100, 30000, 10^-14, 6e-9, V, Fs);
    % Back-calculate w/D from Memristance M = Ron*(w/D) + Roff*(1-w/D)
    w_D = (M_hp - 30000) / (100 - 30000); 
    
    subplot(1,2,1); hold on;
    plot(t, w_D, 'LineWidth', 1.5, 'DisplayName', [num2str(f) ' Hz']);
    
    % --- 2. Chalcogenide State Variable (X) ---
    [X_chal, ~, ~, ~] = chalcogenideModel(V, t, 0.1);
    
    subplot(1,2,2); hold on;
    plot(t, X_chal, 'LineWidth', 1.5, 'DisplayName', [num2str(f) ' Hz']);
end

% Formatting HP Plot
subplot(1,2,1);
title('HP Model: State Variable (w/D)');
xlabel('Time (s)'); ylabel('State w/D');
legend('show'); grid on; ylim([0 1]);

% Formatting Chalcogenide Plot
subplot(1,2,2);
title('Chalcogenide: State Variable (X)');
xlabel('Time (s)'); ylabel('State X');
legend('show'); grid on; ylim([0 1]);

% --- FUNCTIONS ---
function [I, M] = HPmodel_simple(Ron, Roff, mu, D, V, Fs)
    k2 = (Ron - Roff) * mu * Ron/(D^2); k3 = Roff / 10;
    dt = 1/Fs; phi = dt * cumtrapz(V);
    term = k3 - 2 * k2 * phi;
    term(term < (Ron^2/100)) = Ron^2/100;
    I = V ./ (term.^(1/2)); M = V./I;
end

function [X, G, I, M] = chalcogenideModel(V, time_vect, Xic)
    tau = 0.001; % Slightly slower for visual clarity
    [~, X] = ode45(@(t, X) fODE(t, X, V, time_vect, tau), time_vect, Xic);
    Roff = 1500; Ron = 500;
    G = X/Ron + (1 - X)/Roff; I = G .* V'; M = V./(I');
end

function dXdt = fODE(t, X, V, time_vect, tau)
    beta_var = 1/0.026; Von = 0.27; Voff = 0.27;
    V_interp = interp1(time_vect, V, t);
    dXdt = 1/tau * ((1./(1 + exp(-beta_var .* (V_interp - Von))) .* (1 - X)) ...
            - (1 - 1./(1 + exp(-beta_var .* (V_interp + Voff)))) .* X);
end