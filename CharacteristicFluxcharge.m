%% Flux vs. Charge Analysis for HP and Chalcogenide Models
clear, clc, close all;

% Parameters
Ron = 100; Roff = 30000; mu = 10^-14; D = 6e-9;
Fs = 100000; dt = 1/Fs;
f = 10; % Low frequency to see significant state change
t = 0:dt:1/f;
V = 1.5 * sin(2 * pi * f * t);

% --- 1. HP MODEL DATA ---
[I_hp, ~] = HPmodel_simple(Ron, Roff, mu, D, V, Fs);
flux_hp = cumtrapz(t, V);
charge_hp = cumtrapz(t, I_hp);

% --- 2. CHALCOGENIDE MODEL DATA ---
Xic = 0.1;
[~, ~, I_chal, ~] = chalcogenideModel(V, t, Xic);
flux_chal = cumtrapz(t, V);
charge_chal = cumtrapz(t, I_chal);

% --- PLOTTING ---
figure('Color', 'w', 'Position', [100 100 1000 400]);

% HP Plot
subplot(1,2,1);
plot(charge_hp, flux_hp, 'b', 'LineWidth', 2);
title('HP Model: Flux vs. Charge');
xlabel('Charge q (C)'); ylabel('Flux \phi (Wb)');
grid on;

% Chalcogenide Plot
subplot(1,2,2);
plot(charge_chal, flux_chal, 'r', 'LineWidth', 2);
title('Chalcogenide: Flux vs. Charge');
xlabel('Charge q (C)'); ylabel('Flux \phi (Wb)');
grid on;

% ------------------ FUNCTIONS ------------------
function [I, M] = HPmodel_simple(Ron, Roff, mu, D, V, Fs)
    k2 = (Ron - Roff) * mu * Ron/(D^2);
    k3 = Roff / 10;
    dt = 1/Fs;
    phi = dt * cumtrapz(V);
    term = k3 - 2 * k2 * phi;
    term(term < (Ron^2/100)) = Ron^2/100;
    I = V ./ (term.^(1/2));
    M = V./I;
end

function [X, G, I, M] = chalcogenideModel(V, time_vect, Xic)
    tau = 0.0001;
    [~, X] = ode45(@(t, X) fODE(t, X, V, time_vect, tau), time_vect, Xic);
    Roff = 1500; Ron = 500;
    G = X/Ron + (1 - X)/Roff;
    I = G .* V';
    M = V./(I');
end

function dXdt = fODE(t, X, V, time_vect, tau)
    beta_var = 1/0.026; Von = 0.27; Voff = 0.27;
    V_interp = interp1(time_vect, V, t);
    dXdt = 1/tau * ((1./(1 + exp(-beta_var .* (V_interp - Von))) .* (1 - X)) ...
            - (1 - 1./(1 + exp(-beta_var .* (V_interp + Voff)))) .* X);
end