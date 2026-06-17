%% HP-Based Mathematical Framework: All 8 Governing Equations
clear; clc; close all;

% --- HP Physical Parameters ---
Ron = 100; Roff = 30000; mu = 10^-14; D = 6e-9;
Fs = 100000; dt = 1/Fs; t = 0:dt:0.05; f = 60;
V_amp = 1.5; I_amp = 0.001; 

% --- Mapping to Table 3.1 Constants ---
M0 = Roff; 
k = ((Ron - Roff) * mu * Ron) / (D^2); 

% Input signals and integrals
v_in = V_amp * sin(2*pi*f*t);
i_in = I_amp * sin(2*pi*f*t);
phi_in = cumtrapz(t, v_in);
q_in = cumtrapz(t, i_in);

figure('Color', 'w', 'Name', 'HP-Based Mathematical Framework (8 Modes)');

%% --- SECTION 1: CHARGE CONTROLLED (M depends on q) ---

% 1. i-Driven, LDE
v1 = i_in .* (M0 + k * q_in); 
subplot(4,2,1); plot(v1, i_in, 'b'); title('1. Chg-Ctrl, i-Drv (LDE)'); 
xlabel('Voltage (V)'); ylabel('Current (A)'); grid on;

% 2. i-Driven, BDE
v2 = i_in .* (1/M0 - (k/M0^2) * q_in).^-1; 
subplot(4,2,3); plot(v2, i_in, 'b--'); title('2. Chg-Ctrl, i-Drv (BDE)'); 
xlabel('Voltage (V)'); ylabel('Current (A)'); grid on;

% 3. v-Driven, LDE
i3 = (v_in ./ M0) .* exp((k .* phi_in) ./ (M0^2));
subplot(4,2,5); plot(v_in, i3, 'r'); title('3. Chg-Ctrl, v-Drv (LDE)'); 
xlabel('Voltage (V)'); ylabel('Current (A)'); grid on;

% 4. v-Driven, BDE
i4 = v_in ./ sqrt(M0^2 + 2 * k * phi_in); 
subplot(4,2,7); plot(v_in, i4, 'r--'); title('4. Chg-Ctrl, v-Drv (BDE)'); 
xlabel('Voltage (V)'); ylabel('Current (A)'); grid on;

%% --- SECTION 2: FLUX CONTROLLED (M depends on phi) ---

% 5. i-Driven, LDE
v5 = i_in .* M0 .* exp(k * q_in);
subplot(4,2,2); plot(v5, i_in, 'g'); title('5. Flux-Ctrl, i-Drv (LDE)'); 
xlabel('Voltage (V)'); ylabel('Current (A)'); grid on;

% 6. i-Driven, BDE
v6 = i_in .* (M0 + k * q_in);
subplot(4,2,4); plot(v6, i_in, 'g--'); title('6. Flux-Ctrl, i-Drv (BDE)'); 
xlabel('Voltage (V)'); ylabel('Current (A)'); grid on;

% 7. v-Driven, LDE
i7 = v_in .* (1/M0 - (k/M0^2) * phi_in);
subplot(4,2,6); plot(v_in, i7, 'm'); title('7. Flux-Ctrl, v-Drv (LDE)'); 
xlabel('Voltage (V)'); ylabel('Current (A)'); grid on;

% 8. v-Driven, BDE
i8 = v_in ./ (M0 + k * phi_in);
subplot(4,2,8); plot(v_in, i8, 'm--'); title('8. Flux-Ctrl, v-Drv (BDE)'); 
xlabel('Voltage (V)'); ylabel('Current (A)'); grid on;

% Adjust layout for readability
sgtitle('Memristor I-V Response from General Solutions of the HP model');