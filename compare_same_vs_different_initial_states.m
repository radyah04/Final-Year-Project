%% compare_same_vs_different_initial_states.m
% Arbitrary HP memristor network simulation.
% Runs two cases:
%   1) all memristors start with same state
%   2) memristors start with different states

clear; close all; clc;

%% Plot settings
set(groot,'defaultAxesFontName','Times New Roman');
set(groot,'defaultTextFontName','Times New Roman');
set(groot,'defaultAxesFontSize',12);
set(groot,'defaultLineLineWidth',0.9);

%% Input voltage
T = 0.2;
N = 20000;
t = linspace(0,T,N);
dt = t(2)-t(1);

f = 50;
A = 1.0;
V_in = A*sin(2*pi*f*t);

%% HP parameters
params.Ron  = 100;
params.Roff = 30000;
params.mu   = 1.5e-12;
params.Ddev = 10e-9;
params.eta  = -1;

%% Network topology
% Each row is one memristor branch: [start_node end_node]
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

num_memristors = size(branches,1);

%% Initial condition cases

% Case 1: all memristors start the same
x0_same = 0.3 * ones(num_memristors,1);

% Case 2: memristors start differently
x0_diff = [0.25; 0.35; 0.45; 0.30; 0.40];

%% Run both simulations

out_same = simulate_arbitrary_HP_network( ...
    t, V_in, branches, num_nodes, port_pos, port_neg, params, x0_same);

out_diff = simulate_arbitrary_HP_network( ...
    t, V_in, branches, num_nodes, port_pos, port_neg, params, x0_diff);

%% Final cycle index for clean I-V plots
period = 1/f;
idx_final = t >= (t(end) - period);

%% Figure 1: topology
figure;
plot_network_topology(num_nodes, branches, port_pos, port_neg);
title('Arbitrary HP memristor network topology');

%% Figure 2: terminal I-V response
figure;
plot(V_in(idx_final), out_same.I_port(idx_final), 'LineWidth', 0.9);
hold on;
plot(V_in(idx_final), out_diff.I_port(idx_final), '--', 'LineWidth', 0.9);
hold off;
xlabel('Port voltage, v_P(t) [V]');
ylabel('Port current, i_P(t) [A]');
title('Terminal I-V response');
legend('Same initial states','Different initial states','Location','best');
grid on; box on;

%% Figure 3: port q-phi response
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

%% Figure 4: effective memristance
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

%% Figure 5: effective conductance fingerprint
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

%% Figure 6: state evolution, same initial states
figure;
plot(t, out_same.x', 'LineWidth', 0.9);
xlabel('Time [s]');
ylabel('State variable, x_m(t)');
title('Individual state evolution: same initial states');
legend('M1','M2','M3','M4','M5','Location','best');
grid on; box on;

%% Figure 7: state evolution, different initial states
figure;
plot(t, out_diff.x', 'LineWidth', 0.9);
xlabel('Time [s]');
ylabel('State variable, x_m(t)');
title('Individual state evolution: different initial states');
legend('M1','M2','M3','M4','M5','Location','best');
grid on; box on;

%% Figure 8: branch currents, same initial states
figure;
plot(t, out_same.I_branch', 'LineWidth', 0.9);
xlabel('Time [s]');
ylabel('Branch current [A]');
title('Individual branch currents: same initial states');
legend('I_1','I_2','I_3','I_4','I_5','Location','best');
grid on; box on;

%% Figure 9: branch currents, different initial states
figure;
plot(t, out_diff.I_branch', 'LineWidth', 0.9);
xlabel('Time [s]');
ylabel('Branch current [A]');
title('Individual branch currents: different initial states');
legend('I_1','I_2','I_3','I_4','I_5','Location','best');
grid on; box on;

%% Figure 10: individual memristances, same initial states
figure;
plot(t, out_same.M', 'LineWidth', 0.9);
xlabel('Time [s]');
ylabel('Memristance [\Omega]');
title('Individual memristance evolution: same initial states');
legend('M_1','M_2','M_3','M_4','M_5','Location','best');
grid on; box on;

%% Figure 11: individual memristances, different initial states
figure;
plot(t, out_diff.M', 'LineWidth', 0.9);
xlabel('Time [s]');
ylabel('Memristance [\Omega]');
title('Individual memristance evolution: different initial states');
legend('M_1','M_2','M_3','M_4','M_5','Location','best');
grid on; box on;

%% Print summary
M0_same = params.Ron*x0_same(1) + params.Roff*(1 - x0_same(1));
M0_diff = params.Ron*x0_diff + params.Roff*(1 - x0_diff);

fprintf('\n================ SAME INITIAL STATES ================\n');
fprintf('x0 = ');
fprintf('%.2f ', x0_same);
fprintf('\nInitial memristance of every branch = %.2f ohm\n', M0_same);
fprintf('M_eff range = %.2f to %.2f ohm\n', ...
    min(out_same.M_eff,[],'omitnan'), max(out_same.M_eff,[],'omitnan'));

fprintf('\n================ DIFFERENT INITIAL STATES ================\n');
fprintf('x0 = ');
fprintf('%.2f ', x0_diff);
fprintf('\nInitial memristances = ');
fprintf('%.2f ', M0_diff);
fprintf('ohm\n');
fprintf('M_eff range = %.2f to %.2f ohm\n', ...
    min(out_diff.M_eff,[],'omitnan'), max(out_diff.M_eff,[],'omitnan'));

fprintf('\nMain interpretation:\n');
fprintf('Same initial states isolate topology effects.\n');
fprintf('Different initial states show sensitivity to device initial conditions.\n');

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

        % Memristance and conductance
        M(:,k) = params.Ron*x(:,k) + params.Roff*(1 - x(:,k));
        G(:,k) = 1 ./ M(:,k);

        % Solve node voltages
        p = solve_node_voltages(num_nodes, branches, G(:,k), port_pos, port_neg, V_in(k));
        node_voltage_store(:,k) = p;

        % Branch voltages and currents
        for m = 1:num_memristors
            a_node = branches(m,1);
            b_node = branches(m,2);

            V_branch(m,k) = p(a_node) - p(b_node);
            I_branch(m,k) = G(m,k) * V_branch(m,k);
        end

        % Port current
        I_port(k) = compute_port_current(branches, I_branch(:,k), port_pos);

        % Effective terminal quantities
        if abs(I_port(k)) > 1e-12
            M_eff(k) = V_in(k) / I_port(k);
            G_eff(k) = 1 / M_eff(k);
        end

        % HP state update
        for m = 1:num_memristors
            dxdt = params.eta * (params.mu*params.Ron/params.Ddev^2) * I_branch(m,k);
            x(m,k+1) = x(m,k) + dxdt*dt;

            % Keep state physical
            x(m,k+1) = min(max(x(m,k+1),0),1);
        end
    end

    % Final sample
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

    % Port charge and flux
    q_port = cumtrapz(t,I_port);
    phi_port = cumtrapz(t,V_in);

    % Store outputs
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

    % Build nodal admittance matrix
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

    % Fixed port voltages
    fixed_nodes = [port_pos, port_neg];
    fixed_values = [Vport; 0];

    all_nodes = 1:num_nodes;
    unknown_nodes = setdiff(all_nodes, fixed_nodes);

    p = zeros(num_nodes,1);
    p(fixed_nodes) = fixed_values;

    if isempty(unknown_nodes)
        return;
    end

    % Solve unknown node voltages
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
