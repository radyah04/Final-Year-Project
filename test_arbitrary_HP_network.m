%% Arbitrary HP memristor network simulation using nodal matrix analysis
% This simulates a general memristor network under voltage excitation.
% Each memristor is treated as an instantaneous conductance at each time step.

clear; close all; clc;

%% ============================================================
% 1. Input signal
% ============================================================

T = 0.2;                  % total simulation time [s]
N = 20000;                % number of samples
t = linspace(0,T,N);
dt = t(2)-t(1);

f = 50;                   % input frequency [Hz]
A = 1.0;                  % voltage amplitude [V]
V_in = A*sin(2*pi*f*t);   % applied port voltage

%% ============================================================
% 2. HP memristor parameters
% ============================================================

Ron  = 100;               % low resistance state [ohm]
Roff = 30000;             % high resistance state [ohm]
mu   = 1.5e-12;           % ion mobility
Ddev = 10e-9;             % device thickness [m]
eta  = -1;                % polarity convention

%% ============================================================
% 3. Define arbitrary network topology
% ============================================================

% Each row is one memristor branch: [start_node end_node]
%
% Example network:
%
%        M1
%   1 -------- 2
%   | \        |
% M4|  \M3     |M2
%   |    \     |
%   4 -------- 3
%        M5
%
% Port voltage is applied between node 1 and node 3.

branches = [
    1 2;   % M1
    2 3;   % M2
    1 3;   % M3 bridge/diagonal branch
    1 4;   % M4
    4 3    % M5
];

num_nodes = 4;
num_memristors = size(branches,1);

port_pos = 1;     % positive terminal
port_neg = 3;     % negative/reference terminal

%% ============================================================
% 4. Initial states
% ============================================================

x = zeros(num_memristors,N);

% Different initial states make the network response more interesting.
x(:,1) = 0.3 * ones(num_memristors,1);

M = zeros(num_memristors,N);
G = zeros(num_memristors,N);

V_branch = zeros(num_memristors,N);
I_branch = zeros(num_memristors,N);

I_port = zeros(1,N);
M_eff = zeros(1,N);
G_eff = zeros(1,N);

node_voltage_store = zeros(num_nodes,N);

%% ============================================================
% 5. Build incidence matrix for visual/checking
% ============================================================

Dinc = build_incidence_matrix(num_nodes, branches);

disp('Incidence matrix D:')
disp(Dinc)

%% ============================================================
% 6. Time-domain simulation
% ============================================================

for k = 1:N-1

    % ----- Device memristance and conductance -----
    M(:,k) = Ron*x(:,k) + Roff*(1 - x(:,k));
    G(:,k) = 1 ./ M(:,k);

    % ----- Solve circuit at this time step -----
    p = solve_node_voltages(num_nodes, branches, G(:,k), port_pos, port_neg, V_in(k));
    node_voltage_store(:,k) = p;

    % ----- Branch voltages and branch currents -----
    for m = 1:num_memristors
        a_node = branches(m,1);
        b_node = branches(m,2);

        V_branch(m,k) = p(a_node) - p(b_node);
        I_branch(m,k) = G(m,k) * V_branch(m,k);
    end

    % ----- Port current leaving the positive terminal -----
    I_port(k) = compute_port_current(branches, I_branch(:,k), port_pos);

    % ----- Effective terminal quantities -----
    if abs(I_port(k)) > 1e-12
        M_eff(k) = V_in(k) / I_port(k);
        G_eff(k) = 1 / M_eff(k);
    else
        M_eff(k) = NaN;
        G_eff(k) = NaN;
    end

    % ----- Update each HP memristor state using its own current -----
    for m = 1:num_memristors
        dxdt = eta * (mu*Ron/Ddev^2) * I_branch(m,k);
        x(m,k+1) = x(m,k) + dxdt*dt;

        % Bound state to physical interval.
        x(m,k+1) = min(max(x(m,k+1),0),1);
    end
end

%% ============================================================
% 7. Final sample
% ============================================================

M(:,N) = Ron*x(:,N) + Roff*(1 - x(:,N));
G(:,N) = 1 ./ M(:,N);

p = solve_node_voltages(num_nodes, branches, G(:,N), port_pos, port_neg, V_in(N));
node_voltage_store(:,N) = p;

for m = 1:num_memristors
    a_node = branches(m,1);
    b_node = branches(m,2);

    V_branch(m,N) = p(a_node) - p(b_node);
    I_branch(m,N) = G(m,N) * V_branch(m,N);
end

I_port(N) = compute_port_current(branches, I_branch(:,N), port_pos);

if abs(I_port(N)) > 1e-12
    M_eff(N) = V_in(N) / I_port(N);
    G_eff(N) = 1 / M_eff(N);
else
    M_eff(N) = NaN;
    G_eff(N) = NaN;
end

%% ============================================================
% 8. Derived port charge and flux
% ============================================================

q_port = cumtrapz(t,I_port);
phi_port = cumtrapz(t,V_in);

%% ============================================================
% 9. Choose final cycle for cleaner I-V plot
% ============================================================

period = 1/f;
idx_final = t >= (t(end) - period);

%% ============================================================
% 10. Report-quality plots
% ============================================================

set(groot,'defaultAxesFontName','Times New Roman');
set(groot,'defaultTextFontName','Times New Roman');
set(groot,'defaultAxesFontSize',12);
set(groot,'defaultLineLineWidth',0.9);

% Plot 1: network topology
figure;
plot_network_topology(num_nodes, branches, port_pos, port_neg);
title('Arbitrary memristor network topology');

% Plot 2: terminal I-V hysteresis
figure;
plot(V_in(idx_final), I_port(idx_final), 'LineWidth', 0.9);
xlabel('Port voltage, v_P(t) [V]');
ylabel('Port current, i_P(t) [A]');
title('Terminal I-V response of arbitrary HP memristor network');
grid on; box on;

% Plot 3: port q-phi curve
figure;
plot(q_port, phi_port, 'LineWidth', 0.9);
xlabel('Port charge, q_P(t) [C]');
ylabel('Port flux, \phi_P(t) [Wb]');
title('Port flux-charge response');
grid on; box on;

% Plot 4: effective memristance
figure;
plot(t, M_eff, 'LineWidth', 0.9);
xlabel('Time [s]');
ylabel('Effective memristance, M_{eff}(t) [\Omega]');
title('Time-domain effective memristance');
grid on; box on;

% Plot 5: effective conductance
figure;
plot(t, G_eff, 'LineWidth', 0.9);
xlabel('Time [s]');
ylabel('Effective conductance, G_{eff}(t) [S]');
title('Equivalent conductance fingerprint');
grid on; box on;

% Plot 6: individual memristor states
figure;
plot(t, x', 'LineWidth', 0.9);
xlabel('Time [s]');
ylabel('State variable, x_m(t)');
title('Individual memristor state evolution');
legend('M1','M2','M3','M4','M5','Location','best');
grid on; box on;

% Plot 7: individual branch currents
figure;
plot(t, I_branch', 'LineWidth', 0.9);
xlabel('Time [s]');
ylabel('Branch current [A]');
title('Individual branch currents');
legend('I_1','I_2','I_3','I_4','I_5','Location','best');
grid on; box on;

% Plot 8: individual memristances
figure;
plot(t, M', 'LineWidth', 0.9);
xlabel('Time [s]');
ylabel('Memristance [\Omega]');
title('Individual memristance evolution');
legend('M_1','M_2','M_3','M_4','M_5','Location','best');
grid on; box on;

%% ============================================================
% 11. Print useful values
% ============================================================

fprintf('\nFinal effective memristance: %.4f ohm\n', M_eff(end));
fprintf('Final effective conductance: %.4e S\n', G_eff(end));
fprintf('Minimum effective memristance: %.4f ohm\n', min(M_eff,[],'omitnan'));
fprintf('Maximum effective memristance: %.4f ohm\n', max(M_eff,[],'omitnan'));

%% ============================================================
% Local functions
% ============================================================

function Dinc = build_incidence_matrix(num_nodes, branches)

    num_branches = size(branches,1);
    Dinc = zeros(num_nodes,num_branches);

    for m = 1:num_branches
        a = branches(m,1);
        b = branches(m,2);

        Dinc(a,m) = 1;
        Dinc(b,m) = -1;
    end
end

function p = solve_node_voltages(num_nodes, branches, G_branch, port_pos, port_neg, Vport)

    % Build nodal admittance matrix.
    Y = zeros(num_nodes,num_nodes);

    for m = 1:size(branches,1)
        a = branches(m,1);
        b = branches(m,2);
        g = G_branch(m);

        Y(a,a) = Y(a,a) + g;
        Y(b,b) = Y(b,b) + g;
        Y(a,b) = Y(a,b) - g;
        Y(b,a) = Y(b,a) - g;
    end

    % Fixed node voltages.
    fixed_nodes = [port_pos, port_neg];
    fixed_values = [Vport; 0];

    all_nodes = 1:num_nodes;
    unknown_nodes = setdiff(all_nodes, fixed_nodes);

    p = zeros(num_nodes,1);
    p(fixed_nodes) = fixed_values;

    % Solve unknown internal node voltages.
    Yuu = Y(unknown_nodes, unknown_nodes);
    Yuk = Y(unknown_nodes, fixed_nodes);

    rhs = -Yuk * fixed_values;

    if isempty(unknown_nodes)
        return;
    end

    p(unknown_nodes) = Yuu \ rhs;
end

function I_port = compute_port_current(branches, I_branch, port_pos)

    I_port = 0;

    for m = 1:size(branches,1)
        a = branches(m,1);
        b = branches(m,2);

        % Current positive direction is from a to b.
        if a == port_pos
            I_port = I_port + I_branch(m);
        elseif b == port_pos
            I_port = I_port - I_branch(m);
        end
    end
end

function plot_network_topology(num_nodes, branches, port_pos, port_neg)

    % Simple fixed layout for 4-node example.
    % Change coordinates if using a different number of nodes.

    if num_nodes == 4
        coords = [
            0 1;    % node 1
            1 1;    % node 2
            1 0;    % node 3
            0 0     % node 4
        ];
    else
        theta = linspace(0,2*pi,num_nodes+1);
        theta(end) = [];
        coords = [cos(theta(:)), sin(theta(:))];
    end

    hold on;

    for m = 1:size(branches,1)
        a = branches(m,1);
        b = branches(m,2);

        xa = coords(a,1);
        ya = coords(a,2);
        xb = coords(b,1);
        yb = coords(b,2);

        plot([xa xb],[ya yb],'-','LineWidth',1.2);

        xm = (xa+xb)/2;
        ym = (ya+yb)/2;
        text(xm,ym,sprintf('M%d',m),'HorizontalAlignment','center', ...
            'BackgroundColor','w');
    end

    scatter(coords(:,1),coords(:,2),80,'filled');

    for n = 1:num_nodes
        text(coords(n,1),coords(n,2)+0.08,sprintf('%d',n), ...
            'HorizontalAlignment','center');
    end

    text(coords(port_pos,1),coords(port_pos,2)+0.18,'+ port', ...
        'HorizontalAlignment','center');

    text(coords(port_neg,1),coords(port_neg,2)-0.18,'- port', ...
        'HorizontalAlignment','center');

    axis equal;
    axis off;
    hold off;
end
