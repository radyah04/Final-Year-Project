%% main_network_and_panayiotis_tests.m
% This script does two things:
%
% Part 1: HP memristor one-port comparison using matrix/nodal analysis.
%         Compares one memristor, 2 in series, 2 in parallel, and a
%         5-memristor bridge-style network.
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
% PART 1: Topology comparison
% ============================================================
% Each row of a branch matrix is one memristor branch: [start_node end_node].
% The equivalent one-port memristance is calculated as M_eff(t)=V_in/I_port.

case_names = { ...
    'Single memristor', ...
    'Two memristors in series', ...
    'Two memristors in parallel', ...
    'Five-memristor network'};

case_branches = { ...
    [1 2], ...
    [1 2; 2 3], ...
    [1 2; 1 2], ...
    [1 2; 2 3; 1 3; 1 4; 4 3]};

case_num_nodes = [2 3 2 4];
case_port_pos = [1 1 1 1];
case_port_neg = [2 3 2 3];

num_cases = numel(case_names);
case_out = cell(num_cases,1);
case_x0 = cell(num_cases,1);

for c = 1:num_cases
    num_memristors = size(case_branches{c},1);
    case_x0{c} = 0.3 * ones(num_memristors,1);

    case_out{c} = simulate_arbitrary_HP_network( ...
        t, V_in, case_branches{c}, case_num_nodes(c), ...
        case_port_pos(c), case_port_neg(c), params, case_x0{c});
end

single_out = case_out{1};

%% ============================================================
% Plot topology comparison results
% ============================================================
period = 1/f;
idx_final = t >= (t(end) - period);

% Figure 1: compared topologies
figure;
for c = 1:num_cases
    subplot(2,2,c);
    plot_network_topology(case_num_nodes(c), case_branches{c}, ...
        case_port_pos(c), case_port_neg(c));
    title(case_names{c});
end

% Figure 2: terminal I-V comparison
figure;
hold on;
for c = 1:num_cases
    plot(V_in(idx_final), case_out{c}.I_port(idx_final), ...
        'LineWidth', 0.9, 'DisplayName', case_names{c});
end
hold off;
xlabel('Port voltage, v_P(t) [V]');
ylabel('Port current, i_P(t) [A]');
title('Terminal I-V response: single memristor vs networks');
legend('Location','best');
grid on; box on;

% Figure 3: effective memristance comparison
figure;
hold on;
for c = 1:num_cases
    plot(t, case_out{c}.M_eff, ...
        'LineWidth', 0.9, 'DisplayName', case_names{c});
end
hold off;
xlabel('Time [s]');
ylabel('Effective memristance, M_{eff}(t) [\Omega]');
title('Equivalent one-port memristance');
legend('Location','best');
grid on; box on;

% Figure 4: difference from a single memristor
figure;
hold on;
for c = 2:num_cases
    delta_M = case_out{c}.M_eff - single_out.M_eff;
    plot(t, delta_M, 'LineWidth', 0.9, ...
        'DisplayName', sprintf('%s minus single', case_names{c}));
end
yline(0,'k:','Single memristor baseline');
hold off;
xlabel('Time [s]');
ylabel('\Delta M_{eff}(t) [\Omega]');
title('How much each topology differs from one memristor');
legend('Location','best');
grid on; box on;

% Figure 5: effective conductance comparison
figure;
hold on;
for c = 1:num_cases
    plot(t, case_out{c}.G_eff, ...
        'LineWidth', 0.9, 'DisplayName', case_names{c});
end
hold off;
xlabel('Time [s]');
ylabel('Effective conductance, G_{eff}(t) [S]');
title('Equivalent conductance fingerprint');
legend('Location','best');
grid on; box on;

% Figure 6: port q-phi comparison
figure;
hold on;
for c = 1:num_cases
    plot(case_out{c}.q_port, case_out{c}.phi_port, ...
        'LineWidth', 0.9, 'DisplayName', case_names{c});
end
hold off;
xlabel('Port charge, q_P(t) [C]');
ylabel('Port flux, \phi_P(t) [Wb]');
title('Port flux-charge response');
legend('Location','best');
grid on; box on;

% Standalone figures for each topology.
for c = 1:num_cases

    % Individual topology figure.
    figure;
    plot_network_topology(case_num_nodes(c), case_branches{c}, ...
        case_port_pos(c), case_port_neg(c));
    title(sprintf('%s topology', case_names{c}));

    % Individual I-V figure.
    figure;
    plot(V_in(idx_final), case_out{c}.I_port(idx_final), ...
        'LineWidth', 0.9, 'DisplayName', case_names{c});
    hold on;
    if c > 1
        plot(V_in(idx_final), single_out.I_port(idx_final), 'k--', ...
            'LineWidth', 0.9, 'DisplayName', 'Single memristor baseline');
    end
    hold off;
    xlabel('Port voltage, v_P(t) [V]');
    ylabel('Port current, i_P(t) [A]');
    title(sprintf('%s: terminal I-V response', case_names{c}));
    legend('Location','best');
    grid on; box on;

    % Individual effective memristance figure.
    figure;
    plot(t, case_out{c}.M_eff, ...
        'LineWidth', 0.9, 'DisplayName', case_names{c});
    hold on;
    if c > 1
        plot(t, single_out.M_eff, 'k--', ...
            'LineWidth', 0.9, 'DisplayName', 'Single memristor baseline');
    end
    hold off;
    xlabel('Time [s]');
    ylabel('Effective memristance, M_{eff}(t) [\Omega]');
    title(sprintf('%s: equivalent one-port memristance', case_names{c}));
    legend('Location','best');
    grid on; box on;

    % Individual q-phi figure.
    figure;
    plot(case_out{c}.q_port, case_out{c}.phi_port, ...
        'LineWidth', 0.9, 'DisplayName', case_names{c});
    hold on;
    if c > 1
        plot(single_out.q_port, single_out.phi_port, 'k--', ...
            'LineWidth', 0.9, 'DisplayName', 'Single memristor baseline');
    end
    hold off;
    xlabel('Port charge, q_P(t) [C]');
    ylabel('Port flux, \phi_P(t) [Wb]');
    title(sprintf('%s: port flux-charge response', case_names{c}));
    legend('Location','best');
    grid on; box on;

    % Individual difference figure for non-single topologies.
    if c > 1
        figure;
        delta_M = case_out{c}.M_eff - single_out.M_eff;
        plot(t, delta_M, 'LineWidth', 0.9, ...
            'DisplayName', sprintf('%s minus single', case_names{c}));
        yline(0,'k:','Single memristor baseline');
        xlabel('Time [s]');
        ylabel('\Delta M_{eff}(t) [\Omega]');
        title(sprintf('%s: difference from one memristor', case_names{c}));
        legend('Location','best');
        grid on; box on;
    end
end

%% ============================================================
% PART 2: Panayiotis analytical HP series and parallel formulas
% ============================================================
% These are the voltage-driven analytical HP expressions from the table.
% They are compared against the numerical nodal results for:
%   - two memristors in series
%   - two memristors in parallel

num_HP = 2;                      % compare against the two-device cases
x0_analytical = 0.3 * ones(num_HP,1);

M0 = params.Ron*x0_analytical + params.Roff*(1 - x0_analytical);

% The analytical table uses M(q)=M0-k*q.
% The numerical model uses eta=-1, which gives the matching signed k below.
k_abs = (params.Roff - params.Ron) * params.mu * params.Ron / params.Ddev^2;
k_vec = -k_abs * ones(num_HP,1);

analytical = panayiotis_HP_analytical(t, V_in, I_in, M0, k_vec);

series_case = 2;
parallel_case = 3;

series_I_error = case_out{series_case}.I_port - analytical.I_series_V;
parallel_I_error = case_out{parallel_case}.I_port - analytical.I_parallel_V;

series_M_error = case_out{series_case}.M_eff - analytical.M_series_V;
parallel_M_error = case_out{parallel_case}.M_eff - analytical.M_parallel_V;

%% ============================================================
% Plot numerical vs analytical voltage-driven results
% ============================================================

% Numerical vs analytical voltage-driven series I-V.
figure;
plot(V_in(idx_final), case_out{series_case}.I_port(idx_final), ...
    'LineWidth', 0.9, 'DisplayName', 'Numerical nodal');
hold on;
plot(V_in(idx_final), analytical.I_series_V(idx_final), '--', ...
    'LineWidth', 0.9, 'DisplayName', 'Analytical');
hold off;
xlabel('Voltage input, v(t) [V]');
ylabel('Current output, i(t) [A]');
title('Two memristors in series: numerical vs analytical I-V');
legend('Location','best');
grid on; box on;

% Numerical vs analytical voltage-driven parallel I-V.
figure;
plot(V_in(idx_final), case_out{parallel_case}.I_port(idx_final), ...
    'LineWidth', 0.9, 'DisplayName', 'Numerical nodal');
hold on;
plot(V_in(idx_final), analytical.I_parallel_V(idx_final), '--', ...
    'LineWidth', 0.9, 'DisplayName', 'Analytical');
hold off;
xlabel('Voltage input, v(t) [V]');
ylabel('Current output, i(t) [A]');
title('Two memristors in parallel: numerical vs analytical I-V');
legend('Location','best');
grid on; box on;

% Effective memristance: numerical vs analytical.
figure;
plot(t, case_out{series_case}.M_eff, 'LineWidth', 0.9, ...
    'DisplayName', 'Series numerical');
hold on;
plot(t, analytical.M_series_V, '--', 'LineWidth', 0.9, ...
    'DisplayName', 'Series analytical');
plot(t, case_out{parallel_case}.M_eff, 'LineWidth', 0.9, ...
    'DisplayName', 'Parallel numerical');
plot(t, analytical.M_parallel_V, '--', 'LineWidth', 0.9, ...
    'DisplayName', 'Parallel analytical');
hold off;
xlabel('Time [s]');
ylabel('Equivalent memristance [\Omega]');
title('Voltage-driven equivalent memristance: numerical vs analytical');
legend('Location','best');
grid on; box on;

% Current error over time.
figure;
plot(t, series_I_error, 'LineWidth', 0.9, ...
    'DisplayName', 'Series: numerical - analytical');
hold on;
plot(t, parallel_I_error, '--', 'LineWidth', 0.9, ...
    'DisplayName', 'Parallel: numerical - analytical');
yline(0,'k:');
hold off;
xlabel('Time [s]');
ylabel('Current error [A]');
title('Numerical minus analytical current error');
legend('Location','best');
grid on; box on;

% Effective memristance error over time.
figure;
plot(t, series_M_error, 'LineWidth', 0.9, ...
    'DisplayName', 'Series: numerical - analytical');
hold on;
plot(t, parallel_M_error, '--', 'LineWidth', 0.9, ...
    'DisplayName', 'Parallel: numerical - analytical');
yline(0,'k:');
hold off;
xlabel('Time [s]');
ylabel('M_{eff} error [\Omega]');
title('Numerical minus analytical memristance error');
legend('Location','best');
grid on; box on;

%% ============================================================
% Print useful summary
% ============================================================
fprintf('\n================ SUMMARY ================\n');

fprintf('\nTopology comparison under the same voltage input:\n');
for c = 1:num_cases
    I_last = case_out{c}.I_port(idx_final);
    V_last = V_in(idx_final);
    loop_area = abs(trapz(V_last,I_last));

    fprintf('\n%s:\n', case_names{c});
    fprintf('Number of memristors = %d\n', size(case_branches{c},1));
    fprintf('Initial states: x0 = ');
    fprintf('%.2f ', case_x0{c});
    fprintf('\nM_eff range: %.2f to %.2f ohm\n', ...
        min(case_out{c}.M_eff,[],'omitnan'), ...
        max(case_out{c}.M_eff,[],'omitnan'));
    fprintf('Final-cycle I-V loop area = %.4e VA\n', loop_area);

    if c > 1
        delta_M = case_out{c}.M_eff - single_out.M_eff;
        fprintf('Difference from single M_eff range: %.2f to %.2f ohm\n', ...
            min(delta_M,[],'omitnan'), max(delta_M,[],'omitnan'));
    end
end

fprintf('\nPanayiotis analytical formulas implemented:\n');
fprintf('- voltage-driven series HP network, compared to numerical 2-series case\n');
fprintf('- voltage-driven parallel HP network, compared to numerical 2-parallel case\n');
fprintf('- current-driven series HP network retained in the helper function\n');
fprintf('- current-driven parallel HP network is not analytically implemented\n');
fprintf('  because it requires inversion of q(phi) to phi(q).\n');

fprintf('\nNumerical vs analytical voltage-driven errors:\n');
fprintf('Series max |current error| = %.4e A\n', ...
    max(abs(series_I_error),[],'omitnan'));
fprintf('Parallel max |current error| = %.4e A\n', ...
    max(abs(parallel_I_error),[],'omitnan'));
fprintf('Series max |M_eff error| = %.4e ohm\n', ...
    max(abs(series_M_error),[],'omitnan'));
fprintf('Parallel max |M_eff error| = %.4e ohm\n', ...
    max(abs(parallel_M_error),[],'omitnan'));

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

        branch_pairs = sort(branches,2);
        same_pair = find(branch_pairs(:,1) == min(a,b) & ...
            branch_pairs(:,2) == max(a,b));
        duplicate_position = find(same_pair == m);
        duplicate_count = numel(same_pair);

        dx = xb - xa;
        dy = yb - ya;
        branch_length = hypot(dx,dy);

        if branch_length > 0
            nx = -dy / branch_length;
            ny = dx / branch_length;
        else
            nx = 0;
            ny = 0;
        end

        offset = 0.08 * (duplicate_position - (duplicate_count + 1)/2);
        xa_plot = xa + offset*nx;
        ya_plot = ya + offset*ny;
        xb_plot = xb + offset*nx;
        yb_plot = yb + offset*ny;

        plot([xa_plot xb_plot],[ya_plot yb_plot],'-','LineWidth',1.2);

        xm = (xa_plot+xb_plot)/2;
        ym = (ya_plot+yb_plot)/2;

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
