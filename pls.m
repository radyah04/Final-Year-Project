%% HP Memristor Multi-Parameter Simulation
clear, clc, close all;

%---------------------------PARAMETERS-------------------------------------
Ron = 100;            % ON resistance (Ω)
Roff = 30000;         % OFF resistance (Ω)
mu = 10^(-10)*10^(-4); % Vacancy mobility
Fs = 1000000;         % 1MHz Sampling Rate
dt = 1/Fs;

% Default baseline values
f_base = 100; 
A_base = 1.0;
D_base = 6e-9;

%-------------------- Figure 1: Varying Frequency ----------------------
freqs = [100, 2500, 10000, 50000]; 
figure(1); hold on;
for f = freqs
    t = 0:dt:2/f;
    V = A_base * sin(2 * pi * f * t);
    [I, ~] = HPmodel(Ron, Roff, mu, D_base, V, Fs);
    plot(V, I, 'Linewidth', 1.5, 'DisplayName', sprintf('%d Hz', f));
end
title('1. I-V Response: Varying Frequencies'); xlabel('V (V)'); ylabel('I (A)');
legend('show', 'Location', 'southeast'); grid on;

%-------------------- Figure 2: Varying Amplitude ----------------------
amps = [0.5, 1.0, 1.5, 2.0];
figure(2); hold on;
for A = amps
    t = 0:dt:2/f_base;
    V = A * sin(2 * pi * f_base * t);
    [I, ~] = HPmodel(Ron, Roff, mu, D_base, V, Fs);
    plot(V, I, 'Linewidth', 1.5, 'DisplayName', sprintf('A = %.1fV', A));
end
title('2. I-V Response: Varying Amplitudes'); xlabel('V (V)'); ylabel('I (A)');
legend('show', 'Location', 'southeast'); grid on;

%-------------------- Figure 3: Varying Thickness (D) ------------------
thicknesses = [6e-9, 8e-9, 10e-9]; 
figure(3); hold on;
for D = thicknesses
    t = 0:dt:2/f_base;
    V = A_base * sin(2 * pi * f_base * t);
    [I, ~] = HPmodel(Ron, Roff, mu, D, V, Fs);
    plot(V, I, 'Linewidth', 1.5, 'DisplayName', sprintf('D = %.0f nm', D*1e9));
end
title('3. I-V Response: Varying Film Thickness D'); xlabel('V (V)'); ylabel('I (A)');
legend('show', 'Location', 'southeast'); grid on;

%-------------------- Figure 4: Varying Input Shapes -------------------
figure(4); hold on;
shapes = {'Sine', 'Triangle', 'Square'};
t = 0:dt:2/f_base;

for i = 1:length(shapes)
    if strcmp(shapes{i}, 'Sine')
        V = A_base * sin(2 * pi * f_base * t);
    elseif strcmp(shapes{i}, 'Triangle')
        V = A_base * sawtooth(2 * pi * f_base * t, 0.5);
    else % Square
        V = A_base * square(2 * pi * f_base * t);
    end
    
    [I, ~] = HPmodel(Ron, Roff, mu, D_base, V, Fs);
    plot(V, I, 'Linewidth', 2, 'DisplayName', shapes{i});
end

% FIX: Limit the Y-axis so the Sine wave (mA range) isn't crushed by spikes
ylim([-0.015, 0.015]); 

title('4. I-V Response: Different Input Waveforms (100 Hz)');
xlabel('V (V)'); ylabel('I (A)'); 
legend('show', 'Location', 'southeast'); grid on;

%---------------------------MODEL FUNCTION---------------------------------
function [I, M] = HPmodel(Ron, Roff, mu, D, V, Fs)
    k2 = (Ron - Roff) * mu * Ron/(D^2);
    k3 = Roff / 10;
    dt = 1/Fs;
    
    % Use cumulative trapezoidal integration for flux
    phi = dt * cumtrapz(V); 
    
    % The core HP equation: M(t) = sqrt(k3 - 2*k2*phi)
    term = k3 - 2 * k2 * phi;
    
    % Boundary Protection: prevent negative values or division by zero
    % This keeps the math from exploding without using a formal window function
    term(term < (Ron^2/100)) = Ron^2/100; 
    
    I = V ./ (term.^(1/2));
    
    % Calculate Memristance
    M = zeros(size(I));
    nonzero_idx = (I ~= 0);
    M(nonzero_idx) = V(nonzero_idx) ./ I(nonzero_idx);
    M(~nonzero_idx) = Roff; 
end