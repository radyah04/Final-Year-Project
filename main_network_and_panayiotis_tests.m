%% main_network_and_panayiotis_tests.m
% This script does two things:
%
% Part 1: Arbitrary HP memristor network using matrix/nodal analysis.
%         Runs same initial states and different initial states.
%
% Part 2: Panayiotis-style analytical HP expressions for:
%         - voltage-driven series network
%         - current-driven series network
%         - voltage-driven parallel network
%         - current-driven parallel is noted as not analytically available.

clear; close all; clc;

%% ============================================================
% General plotting settings
% ============================================================
set(groot,'defaultAxesFontName','Times New Roman');
set(groot,'defaultTextFontName','Times New Roman');
set(groot,'defaultAxesFontSize',12);
set(groot,'defaultLineLineWidth',0.9);

%% ============================================================
% Input signal
% ============================================================
T = 0.2;
N = 20000;
t = linspace(0,T,N);
dt = t(2)-t(1);

f = 50;
A = 1.0;
V_in = A*sin(2*pi*f*t);

% Current input for current-driven analytical series case.
I_amp = 50e-6;
I_in = I_amp*sin(2*pi*f*t);

%% ============================================================
% HP memristor parameters
% ============================================================
params.Ron  = 100;
params.Roff = 30000;
params.mu   = 1.5e-12;
params.Ddev = 10e-9;
params.eta  = -1;

%% ============================================================
% Arbitrary network topology
% ============================================================
% Each row is one memristor branch: [start_node end_node]
%
% Network:
%
%        M1
%   1 -------- 2
%   | \        |
% M4|  \M3     |M2
%   |    \     |
%   4 -------- 3
%        M5
%
% Port voltage applied between node 1 and node 3.

branches = [
    1 2;   % M1
    2 3;   % M2
    1 3;   % M3
    1 4;   % M4
    4 3    % M5
];

num_nodes = 4;
port_pos = 1;
port_neg = 3;

%% ============================================================
% PART 1A: Arbitrary network, same initial state
% ============================================================
x0_same = 0.3 * ones(size(branches,1),1);

out_same = simulate_arbitrary_HP_network( ...
    t, V_in, branches, num_nodes, port_pos, port_neg, params, x0_same);

%% ============================================================
% PART 1B: Arbitrary network, different initial states
% ============================================================
x0_diff = [0.25; 0.35; 0.45; 0.30; 0.40];

out_diff = simulate_arbitrary_HP_network( ...
    t, V_in, branches, num_nodes, port_pos, port_neg, params, x0_diff);

%% ============================================================
% Plot arbitrary-network results
% ============================================================
period = 1/f;
idx_final = t >= (t(end) - period);

% Figure 1: topology
figure;
plot_network_topology(num_nodes, branches, port_pos, port_neg);
title('Arbitrary memristor network topology');

% Figure 2: I-V same vs different initial states
figure;
plot(V_in(idx_final), out_same.I_port(idx_final), 'LineWidth', 0.9);
hold on;
plot(V_in(idx_final), out_diff.I_port(idx_final), '--', 'LineWidth', 0.9);
hold off;
xlabel('Port voltage, v_P(t) [V]');
ylabel('Port current, i_P(t) [A]');
title('Terminal I-V response: same vs different initial states');
legend('Same initial states','Different initial states','Location','best');
grid on; box on;

% Figure 3: q-phi same vs different initial states
figure;
plot(out_same.q_port, out_same.phi_port, 'LineWidth', 0.9);
hold on;
plot(out_diff.q_port, out_diff.phi_port, '--', 'LineWidth', 0.9);
hold off;
xlabel('Port charge, q_P(t) [C]');
ylabel('Port flux, \phi_P(t) [Wb]');
title('Port flux-charge response');
legend('Same initial states','Different initial states','Location','best');
grid on; box on;

% Figure 4: effective conductance fingerprint comparison
figure;
plot(t, out_same.G_eff, 'LineWidth', 0.9);
hold on;
plot(t, out_diff.G_eff, '--', 'LineWidth', 0.9);
hold off;
xlabel('Time [s]');
ylabel('Effective conductance, G_{eff}(t) [S]');
title('Equivalent conductance fingerprint');
legend('Same initial states','Different initial states','Location','best');
grid on; box on;

% Figure 5: state evolution for same initial state
figure;
plot(t, out_same.x', 'LineWidth', 0.9);
xlabel('Time [s]');
ylabel('State variable, x_m(t)');
title('State evolution, same initial states');
legend('M1','M2','M3','M4','M5','Location','best');
grid on; box on;

% Figure 6: state evolution for different initial states
figure;
plot(t, out_diff.x', 'LineWidth', 0.9);
xlabel('Time [s]');
ylabel('State variable, x_m(t)');
title('State evolution, different initial states');
legend('M1','M2','M3','M4','M5','Location','best');
grid on; box on;

% Figure 7: branch currents, same initial state
figure;
plot(t, out_same.I_branch', 'LineWidth', 0.9);
xlabel('Time [s]');
ylabel('Branch current [A]');
title('Individual branch currents, same initial states');
legend('I_1','I_2','I_3','I_4','I_5','Location','best');
grid on; box on;

% Figure 8: effective memristance comparison
figure;
plot(t, out_same.M_eff, 'LineWidth', 0.9);
hold on;
plot(t, out_diff.M_eff, '--', 'LineWidth', 0.9);
hold off;
xlabel('Time [s]');
ylabel('Effective memristance, M_{eff}(t) [\Omega]');
title('Time-domain effective memristance');
legend('Same initial states','Different initial states','Location','best');
grid on; box on;

%% ============================================================
% PART 2: Panayiotis analytical HP series and parallel formulas
% ============================================================
% These are analytical HP expressions.
% They are separate from the arbitrary nodal network simulation above.

num_HP = 3;                      % number of memristors in analytical network
x0_analytical = 0.3 * ones(num_HP,1);

M0 = params.Ron*x0_analytical + params.Roff*(1 - x0_analytical);

% HP coefficient using sign convention:
% M(q) = M0 - k*q
k2 = (params.Roff - params.Ron) * params.mu * params.Ron / params.Ddev^2;
k_vec = k2 * ones(num_HP,1);

analytical = panayiotis_HP_analytical(t, V_in, I_in, M0, k_vec);

%% ============================================================
% Plot Panayiotis analytical results
% ============================================================

% Figure 9: voltage-driven series I-V
figure;
plot(V_in(idx_final), analytical.I_series_V(idx_final), 'LineWidth', 0.9);
xlabel('Voltage input, v(t) [V]');
ylabel('Current output, i(t) [A]');
title('Panayiotis HP: voltage-driven series network');
grid on; box on;

% Figure 10: voltage-driven parallel I-V
figure;
plot(V_in(idx_final), analytical.I_parallel_V(idx_final), 'LineWidth', 0.9);
xlabel('Voltage input, v(t) [V]');
ylabel('Current output, i(t) [A]');
title('Panayiotis HP: voltage-driven parallel network');
grid on; box on;

% Figure 11: current-driven series response
figure;
plot(t, I_in, 'LineWidth', 0.9);
hold on;
plot(t, analytical.V_series_I, '--', 'LineWidth', 0.9);
hold off;
xlabel('Time [s]');
ylabel('Signal');
title('Panayiotis HP: current-driven series network');
legend('Input current i(t) [A]','Output voltage v(t) [V]','Location','best');
grid on; box on;

% Figure 12: compare effective memristances
figure;
plot(t, analytical.M_series_V, 'LineWidth', 0.9);
hold on;
plot(t, analytical.M_parallel_V, '--', 'LineWidth', 0.9);
hold off;
xlabel('Time [s]');
ylabel('Analytical equivalent memristance [\Omega]');
title('Analytical equivalent memristance: series vs parallel');
legend('Voltage-driven series','Voltage-driven parallel','Location','best');
grid on; box on;

%% ============================================================
% Print useful summary
% ============================================================
fprintf('\n================ SUMMARY ================\n');

fprintf('\nArbitrary network, same initial states:\n');
fprintf('Initial states: x0 = ');
fprintf('%.2f ', x0_same);
fprintf('\nInitial memristance for each device: %.2f ohm\n', ...
    params.Ron*x0_same(1) + params.Roff*(1-x0_same(1)));
fprintf('M_eff range: %.2f to %.2f ohm\n', ...
    min(out_same.M_eff,[],'omitnan'), max(out_same.M_eff,[],'omitnan'));

fprintf('\nArbitrary network, different initial states:\n');
fprintf('Initial states: x0 = ');
fprintf('%.2f ', x0_diff);
fprintf('\nM_eff range: %.2f to %.2f ohm\n', ...
    min(out_diff.M_eff,[],'omitnan'), max(out_diff.M_eff,[],'omitnan'));

fprintf('\nPanayiotis analytical formulas implemented:\n');
fprintf('- voltage-driven series HP network\n');
fprintf('- current-driven series HP network\n');
fprintf('- voltage-driven parallel HP network\n');
fprintf('- current-driven parallel HP network is not analytically implemented\n');
fprintf('  because it requires inversion of q(phi) to phi(q).\n');

%% ============================================================
% Local functions
% ============================================================

function out = simulate_arbitrary_HP_network(t, V_in, branches, num_nodes, port_pos, port_neg, params, x0)

    N = length(t);
    dt = t(2)-t(1);
    num_memristors = size(branches,1);

    x = zeros(num_memristors,N);
    M = zeros(num_memristors,N);
    G = zeros(num_memristors,N);
    V_branch = zeros(num_memristors,N);
    I_branch = zeros(num_memristors,N);
    I_port = zeros(1,N);
    M_eff = NaN(1,N);
    G_eff = NaN(1,N);
    node_voltage_store = zeros(num_nodes,N);

    x(:,1) = x0(:);

    Dinc = build_incidence_matrix(num_nodes, branches);

    for k = 1:N-1

        M(:,k) = params.Ron*x(:,k) + params.Roff*(1 - x(:,k));
        G(:,k) = 1 ./ M(:,k);

        p = solve_node_voltages(num_nodes, branches, G(:,k), port_pos, port_neg, V_in(k));
        node_voltage_store(:,k) = p;

        for m = 1:num_memristors
            a_node = branches(m,1);
            b_node = branches(m,2);

            V_branch(m,k) = p(a_node) - p(b_node);
            I_branch(m,k) = G(m,k) * V_branch(m,k);
        end

        I_port(k) = compute_port_current(branches, I_branch(:,k), port_pos);

        if abs(I_port(k)) > 1e-12
            M_eff(k) = V_in(k) / I_port(k);
            G_eff(k) = 1 / M_eff(k);
        end

        for m = 1:num_memristors
            dxdt = params.eta * (params.mu*params.Ron/params.Ddev^2) * I_branch(m,k);
            x(m,k+1) = x(m,k) + dxdt*dt;
            x(m,k+1) = min(max(x(m,k+1),0),1);
        end
    end

    M(:,N) = params.Ron*x(:,N) + params.Roff*(1 - x(:,N));
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
    end

    q_port = cumtrapz(t,I_port);
    phi_port = cumtrapz(t,V_in);

    out.x = x;
    out.M = M;
    out.G = G;
    out.V_branch = V_branch;
    out.I_branch = I_branch;
    out.I_port = I_port;
    out.M_eff = M_eff;
    out.G_eff = G_eff;
    out.q_port = q_port;
    out.phi_port = phi_port;
    out.node_voltage = node_voltage_store;
    out.Dinc = Dinc;
end

function analytical = panayiotis_HP_analytical(t, V_in, I_in, M0, k_vec)

    % Analytical HP formula convention:
    % M(q) = M0 - k*q.
    %
    % 1. Voltage-driven series:
    %    I = V / sqrt((sum M0)^2 - 2*(sum k)*int(V dt))
    %
    % 2. Current-driven series:
    %    V = I * sum(M0_j - k_j*q)
    %
    % 3. Voltage-driven parallel:
    %    I = V * sum_j 1/sqrt(M0_j^2 - 2*k_j*int(V dt))
    %
    % 4. Current-driven parallel:
    %    not closed-form analytically in the same simple way.

    phi = cumtrapz(t,V_in);
    q = cumtrapz(t,I_in);

    num_HP = length(M0);

    %% Voltage-driven series
    M0_series = sum(M0);
    k_series = sum(k_vec);

    sqrt_arg_series = M0_series^2 - 2*k_series*phi;
    sqrt_arg_series(sqrt_arg_series <= 0) = NaN;

    M_series_V = sqrt(sqrt_arg_series);
    I_series_V = V_in ./ M_series_V;

    %% Current-driven series
    M_each_series_I = zeros(num_HP,length(t));

    for j = 1:num_HP
        M_each_series_I(j,:) = M0(j) - k_vec(j)*q;
    end

    M_series_I = sum(M_each_series_I,1);
    V_series_I = I_in .* M_series_I;

    %% Voltage-driven parallel
    I_parallel_V = zeros(size(t));
    G_parallel_V = zeros(size(t));

    for j = 1:num_HP
        sqrt_arg_j = M0(j)^2 - 2*k_vec(j)*phi;
        sqrt_arg_j(sqrt_arg_j <= 0) = NaN;

        M_j = sqrt(sqrt_arg_j);
        G_j = 1 ./ M_j;

        G_parallel_V = G_parallel_V + G_j;
        I_parallel_V = I_parallel_V + V_in .* G_j;
    end

    M_parallel_V = 1 ./ G_parallel_V;

    %% Store
    analytical.phi = phi;
    analytical.q = q;

    analytical.I_series_V = I_series_V;
    analytical.M_series_V = M_series_V;

    analytical.V_series_I = V_series_I;
    analytical.M_series_I = M_series_I;

    analytical.I_parallel_V = I_parallel_V;
    analytical.M_parallel_V = M_parallel_V;
    analytical.G_parallel_V = G_parallel_V;
end

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

    fixed_nodes = [port_pos, port_neg];
    fixed_values = [Vport; 0];

    all_nodes = 1:num_nodes;
    unknown_nodes = setdiff(all_nodes, fixed_nodes);

    p = zeros(num_nodes,1);
    p(fixed_nodes) = fixed_values;

    if isempty(unknown_nodes)
        return;
    end

    Yuu = Y(unknown_nodes, unknown_nodes);
    Yuk = Y(unknown_nodes, fixed_nodes);

    rhs = -Yuk * fixed_values;
    p(unknown_nodes) = Yuu \ rhs;
end

function I_port = compute_port_current(branches, I_branch, port_pos)

    I_port = 0;

    for m = 1:size(branches,1)
        a = branches(m,1);
        b = branches(m,2);

        % Branch current is positive from a to b.
        if a == port_pos
            I_port = I_port + I_branch(m);
        elseif b == port_pos
            I_port = I_port - I_branch(m);
        end
    end
end

function plot_network_topology(num_nodes, branches, port_pos, port_neg)

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

        text(xm,ym,sprintf('M%d',m), ...
            'HorizontalAlignment','center', ...
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
