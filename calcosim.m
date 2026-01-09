%% Chalcogenide Memristor Analysis (4 Graphs)
clear, clc, close all;

%---------------------------CONFIGURATION----------------------------------
Xic = 0.1;            % Initial state (0 = Fully OFF, 1 = Fully ON)
Fs = 50000;           % Lower sampling rate is better for ode45 stability
dt = 1/Fs;

% Default baseline values
f_base = 100; 
A_base = 1.0;         % Note: Must be > 0.27V to trigger switching
tau_base = 0.0001;    % Time constant from your function

%-------------------- Graph 1: Varying Frequency ----------------------
freqs = [50, 200, 500, 1000]; 
figure(1); hold on;
for f = freqs
    t_vect = 0:dt:2/f;
    V = A_base * sin(2 * pi * f * t_vect);
    [~, ~, I, ~] = chalcogenideModel(V, t_vect, Xic);
    plot(V, I, 'Linewidth', 1.5, 'DisplayName', sprintf('%d Hz', f));
end
title('1. Chalcogenide: Varying Frequencies'); xlabel('V (V)'); ylabel('I (A)');
legend('show'); grid on;

%-------------------- Graph 2: Varying Amplitude ----------------------
amps = [0.2, 0.4, 0.6, 1.0]; % Threshold is ~0.27V
figure(2); hold on;
for A = amps
    t_vect = 0:dt:2/f_base;
    V = A * sin(2 * pi * f_base * t_vect);
    [~, ~, I, ~] = chalcogenideModel(V, t_vect, Xic);
    plot(V, I, 'Linewidth', 1.5, 'DisplayName', sprintf('A = %.1fV', A));
end
title('2. Chalcogenide: Varying Amplitudes'); xlabel('V (V)'); ylabel('I (A)');
legend('show'); grid on;

%-------------------- Graph 3: Varying Time Constant (tau) --------------
% In this model, tau represents the switching speed (replaces Thickness D)
tau_values = [0.0001, 0.001, 0.01]; 
figure(3); hold on;
for tau_val = tau_values
    t_vect = 0:dt:2/f_base;
    V = A_base * sin(2 * pi * f_base * t_vect);
    % We pass tau_val into a modified version of your function
    [~, ~, I, ~] = chalcogenideModel_param(V, t_vect, Xic, tau_val);
    plot(V, I, 'Linewidth', 1.5, 'DisplayName', sprintf('\\tau = %.4f', tau_val));
end
title('3. Chalcogenide: Varying Time Constant \tau'); xlabel('V (V)'); ylabel('I (A)');
legend('show'); grid on;

%-------------------- Graph 4: Varying Input Shapes -------------------
figure(4); hold on;
shapes = {'Sine', 'Triangle', 'Square'};
t_vect = 0:dt:2/f_base;
for i = 1:length(shapes)
    if strcmp(shapes{i}, 'Sine'), V = A_base * sin(2 * pi * f_base * t_vect);
    elseif strcmp(shapes{i}, 'Triangle'), V = A_base * sawtooth(2 * pi * f_base * t_vect, 0.5);
    else, V = A_base * square(2 * pi * f_base * t_vect); end
    
    [~, ~, I, ~] = chalcogenideModel(V, t_vect, Xic);
    plot(V, I, 'Linewidth', 1.5, 'DisplayName', shapes{i});
end
title('4. Chalcogenide: Different Input Waveforms');
xlabel('V (V)'); ylabel('I (A)'); legend('show'); grid on;

%---------------------------MODEL FUNCTIONS--------------------------------

function [X, G, I, M] = chalcogenideModel(V, time_vect, Xic)
    tau = 0.0001; % Fixed for baseline
    [X, G, I, M] = chalcogenideModel_param(V, time_vect, Xic, tau);
end

function [X, G, I, M] = chalcogenideModel_param(V, time_vect, Xic, tau)
    % Solving the ODE using your logic
    options = odeset('RelTol',1e-5,'AbsTol',1e-8);
    [~, X] = ode45(@(t, X) fODE(t, X, V, time_vect, tau), time_vect, Xic, options);
    
    Roff = 1500; Ron = 500;
    % Conductance based on state X
    G = X/Ron + (1 - X)/Roff;
    I = G .* V';
    M = V./(I');
end

function dXdt = fODE(t, X, V, time_vect, tau)
    beta_var = 1/0.026; 
    Von = 0.27; Voff = 0.27;
    V_interp = interp1(time_vect, V, t); 
    
    % The Sigmoid-based switching logic from your function
    dXdt = 1/tau * ( (1./(1 + exp(-beta_var .* (V_interp - Von))) .* (1 - X)) ...
            - (1 - 1./(1 + exp(-beta_var .* (V_interp + Voff)))) .* X );
end