%% analytical_vs_numerical_HP_comparison.m
% Compare numerical nodal HP network simulations with voltage-driven
% analytical HP expressions for two memristors in series and parallel.
%
% Analytical expressions:
%   Series:
%     i(t) = v(t) / sqrt((sum M0_j)^2 - 2*(sum k_j)*int(v dt))
%
%   Parallel:
%     i(t) = v(t) * sum_j 1/sqrt(M0_j^2 - 2*k_j*int(v dt))

clear; close all; clc;

%% Plot settings
C = pastel_palette_report();

set(groot,'defaultFigureColor','w');
set(groot,'defaultAxesColor','w');
set(groot,'defaultAxesFontName','Times New Roman');
set(groot,'defaultTextFontName','Times New Roman');
set(groot,'defaultAxesFontSize',12);
set(groot,'defaultAxesBox','on');
set(groot,'defaultAxesTickDir','out');
set(groot,'defaultAxesLineWidth',1.0);
set(groot,'defaultLineLineWidth',1.8);

%% Input signal
T = 0.2;
N = 20000;
t = linspace(0,T,N);

f = 50;
A = 1.0;
V_in = A*sin(2*pi*f*t);

period = 1/f;
idx_final = t >= (t(end) - period);

%% HP parameters
params.Ron  = 100;
params.Roff = 30000;
params.mu   = 1.5e-12;
params.Ddev = 10e-9;
params.eta  = -1;

%% Numerical two-device networks
series_branches = [1 2; 2 3];
parallel_branches = [1 2; 1 2];

x0 = 0.3 * ones(2,1);

series_num = simulate_arbitrary_HP_network( ...
    t, V_in, series_branches, 3, 1, 3, params, x0);

parallel_num = simulate_arbitrary_HP_network( ...
    t, V_in, parallel_branches, 2, 1, 2, params, x0);

%% Analytical voltage-driven series and parallel
num_HP = 2;
M0 = params.Ron*x0 + params.Roff*(1 - x0);

% The analytical table uses M(q)=M0-k*q.
% The numerical model uses eta=-1, so the matching k is signed negative.
k_abs = (params.Roff - params.Ron) * params.mu * params.Ron / params.Ddev^2;
k_vec = -k_abs * ones(num_HP,1);

analytical = panayiotis_HP_analytical_voltage_driven(t, V_in, M0, k_vec);

%% Errors
series_I_error = series_num.I_port - analytical.I_series_V;
parallel_I_error = parallel_num.I_port - analytical.I_parallel_V;

series_M_error = series_num.M_eff - analytical.M_series_V;
parallel_M_error = parallel_num.M_eff - analytical.M_parallel_V;

%% Figure 1: series I-V numerical vs analytical
figure;
plot(V_in(idx_final), series_num.I_port(idx_final), ...
    'Color', C.blue, ...
    'DisplayName', 'Numerical nodal');
hold on;
plot(V_in(idx_final), analytical.I_series_V(idx_final), '--', ...
    'Color', C.pink, ...
    'DisplayName', 'Analytical');
hold off;
xlabel('Voltage input, v(t) [V]');
ylabel('Current output, i(t) [A]');
title('Two memristors in series: numerical vs analytical');
legend('Location','best');
grid on; box on;

%% Figure 2: parallel I-V numerical vs analytical
figure;
plot(V_in(idx_final), parallel_num.I_port(idx_final), ...
    'Color', C.green, ...
    'DisplayName', 'Numerical nodal');
hold on;
plot(V_in(idx_final), analytical.I_parallel_V(idx_final), '--', ...
    'Color', C.lilac, ...
    'DisplayName', 'Analytical');
hold off;
xlabel('Voltage input, v(t) [V]');
ylabel('Current output, i(t) [A]');
title('Two memristors in parallel: numerical vs analytical');
legend('Location','best');
grid on; box on;

%% Figure 3: effective memristance numerical vs analytical
figure;
plot(t, series_num.M_eff, ...
    'Color', C.blue, ...
    'DisplayName', 'Series numerical');
hold on;
plot(t, analytical.M_series_V, '--', ...
    'Color', C.pink, ...
    'DisplayName', 'Series analytical');
plot(t, parallel_num.M_eff, ...
    'Color', C.green, ...
    'DisplayName', 'Parallel numerical');
plot(t, analytical.M_parallel_V, '--', ...
    'Color', C.lilac, ...
    'DisplayName', 'Parallel analytical');
hold off;
xlabel('Time [s]');
ylabel('Equivalent memristance [\Omega]');
title('Equivalent memristance: numerical vs analytical');
legend('Location','best');
grid on; box on;

%% Figure 4: current error
figure;
plot(t, series_I_error, ...
    'Color', C.blue, ...
    'DisplayName', 'Series numerical - analytical');
hold on;
plot(t, parallel_I_error, '--', ...
    'Color', C.green, ...
    'DisplayName', 'Parallel numerical - analytical');
yline(0,':', 'Color', C.black);
hold off;
xlabel('Time [s]');
ylabel('Current error [A]');
title('Current error');
legend('Location','best');
grid on; box on;

%% Figure 5: effective memristance error
figure;
plot(t, series_M_error, ...
    'Color', C.blue, ...
    'DisplayName', 'Series numerical - analytical');
hold on;
plot(t, parallel_M_error, '--', ...
    'Color', C.green, ...
    'DisplayName', 'Parallel numerical - analytical');
yline(0,':', 'Color', C.black);
hold off;
xlabel('Time [s]');
ylabel('M_{eff} error [\Omega]');
title('Effective memristance error');
legend('Location','best');
grid on; box on;

%% Summary
fprintf('\n================ ANALYTICAL VS NUMERICAL ================\n');
fprintf('Series max |current error| = %.4e A\n', ...
    max(abs(series_I_error),[],'omitnan'));
fprintf('Parallel max |current error| = %.4e A\n', ...
    max(abs(parallel_I_error),[],'omitnan'));
fprintf('Series max |M_eff error| = %.4e ohm\n', ...
    max(abs(series_M_error),[],'omitnan'));
fprintf('Parallel max |M_eff error| = %.4e ohm\n', ...
    max(abs(parallel_M_error),[],'omitnan'));

%% Local functions
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

    x(:,1) = x0(:);

    for k = 1:N-1
        M(:,k) = params.Ron*x(:,k) + params.Roff*(1 - x(:,k));
        G(:,k) = 1 ./ M(:,k);

        p = solve_node_voltages(num_nodes, branches, G(:,k), port_pos, port_neg, V_in(k));

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

    out.x = x;
    out.M = M;
    out.G = G;
    out.V_branch = V_branch;
    out.I_branch = I_branch;
    out.I_port = I_port;
    out.M_eff = M_eff;
    out.G_eff = G_eff;
end

function analytical = panayiotis_HP_analytical_voltage_driven(t, V_in, M0, k_vec)

    phi = cumtrapz(t,V_in);

    M0_series = sum(M0);
    k_series = sum(k_vec);

    sqrt_arg_series = M0_series^2 - 2*k_series*phi;
    sqrt_arg_series(sqrt_arg_series <= 0) = NaN;

    M_series_V = sqrt(sqrt_arg_series);
    I_series_V = V_in ./ M_series_V;

    G_parallel_V = zeros(size(t));

    for j = 1:length(M0)
        sqrt_arg_j = M0(j)^2 - 2*k_vec(j)*phi;
        sqrt_arg_j(sqrt_arg_j <= 0) = NaN;

        M_j = sqrt(sqrt_arg_j);
        G_parallel_V = G_parallel_V + 1 ./ M_j;
    end

    I_parallel_V = V_in .* G_parallel_V;
    M_parallel_V = 1 ./ G_parallel_V;

    analytical.phi = phi;
    analytical.I_series_V = I_series_V;
    analytical.M_series_V = M_series_V;
    analytical.I_parallel_V = I_parallel_V;
    analytical.M_parallel_V = M_parallel_V;
    analytical.G_parallel_V = G_parallel_V;
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
    unknown_nodes = setdiff(1:num_nodes, fixed_nodes);

    p = zeros(num_nodes,1);
    p(fixed_nodes) = fixed_values;

    if isempty(unknown_nodes)
        return;
    end

    Yuu = Y(unknown_nodes, unknown_nodes);
    Yuk = Y(unknown_nodes, fixed_nodes);

    p(unknown_nodes) = Yuu \ (-Yuk * fixed_values);
end

function I_port = compute_port_current(branches, I_branch, port_pos)

    I_port = 0;

    for m = 1:size(branches,1)
        a = branches(m,1);
        b = branches(m,2);

        if a == port_pos
            I_port = I_port + I_branch(m);
        elseif b == port_pos
            I_port = I_port - I_branch(m);
        end
    end
end
