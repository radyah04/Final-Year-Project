%% network_reduction_numerical.m
% Numerical one-port reduction for HP memristor topologies.
%
% This script compares:
%   1) one memristor
%   2) two memristors in series
%   3) two memristors in parallel
%   4) five-memristor bridge-style network
%
% The network is reduced numerically using:
%   M_eff(t) = v_P(t) / i_P(t)

clear; close all; clc;

%% Plot settings
C = pastel_palette_report();
cols = [C.pink; C.blue; C.green; C.yellow; C.lilac; C.peach];

make_extra_plots = true;

outdir = 'results/figures/network_reduction_numerical';
if ~exist('results','dir')
    mkdir('results');
end
if ~exist('results/figures','dir')
    mkdir('results/figures');
end
if ~exist(outdir,'dir')
    mkdir(outdir);
end

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

%% Topologies
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

%% Figure 1: terminal I-V comparison
figure;
hold on;
for c = 1:num_cases
    plot(V_in(idx_final), case_out{c}.I_port(idx_final), ...
        'Color', cols(c,:), ...
        'DisplayName', case_names{c});
end
hold off;
xlabel('Port voltage, v_P(t) [V]');
ylabel('Port current, i_P(t) [A]');
title('Numerical terminal I-V comparison');
legend('Location','best');
grid on; box on;
format_and_save_figure(gcf, fullfile(outdir,'network_reduction_IV_comparison'));

%% Figure 2: numerical effective memristance
figure;
hold on;
for c = 1:num_cases
    plot(t, case_out{c}.M_eff, ...
        'Color', cols(c,:), ...
        'DisplayName', case_names{c});
end
hold off;
xlabel('Time [s]');
ylabel('Effective memristance, M_{eff}(t) [\Omega]');
title('Numerical one-port memristance');
legend('Location','best');
grid on; box on;
format_and_save_figure(gcf, fullfile(outdir,'network_reduction_Meff_comparison'));

%% Figure 3: difference from one memristor
figure;
hold on;
for c = 2:num_cases
    delta_M = case_out{c}.M_eff - single_out.M_eff;
    plot(t, delta_M, ...
        'Color', cols(c,:), ...
        'DisplayName', sprintf('%s minus single', case_names{c}));
end
yline(0,':','Single memristor baseline', 'Color', C.black);
hold off;
xlabel('Time [s]');
ylabel('\Delta M_{eff}(t) [\Omega]');
title('Numerical difference from one memristor');
legend('Location','best');
grid on; box on;
format_and_save_figure(gcf, fullfile(outdir,'network_reduction_Meff_difference_from_single'));

%% Extra numerical plots
if make_extra_plots

    % Figure 4: topology panel.
    figure;
    for c = 1:num_cases
        subplot(2,2,c);
        plot_network_topology(case_num_nodes(c), case_branches{c}, ...
            case_port_pos(c), case_port_neg(c), C);
        title(case_names{c});
    end
    format_and_save_figure(gcf, fullfile(outdir,'network_reduction_topologies'));

    % Figure 5: effective conductance comparison.
    figure;
    hold on;
    for c = 1:num_cases
        plot(t, case_out{c}.G_eff, ...
            'Color', cols(c,:), ...
            'DisplayName', case_names{c});
    end
    hold off;
    xlabel('Time [s]');
    ylabel('Effective conductance, G_{eff}(t) [S]');
    title('Numerical effective conductance fingerprint');
    legend('Location','best');
    grid on; box on;
    format_and_save_figure(gcf, fullfile(outdir,'network_reduction_Geff_comparison'));

    % Figure 6: port flux-charge comparison.
    figure;
    hold on;
    for c = 1:num_cases
        plot(case_out{c}.q_port, case_out{c}.phi_port, ...
            'Color', cols(c,:), ...
            'DisplayName', case_names{c});
    end
    hold off;
    xlabel('Port charge, q_P(t) [C]');
    ylabel('Port flux, \phi_P(t) [Wb]');
    title('Numerical port flux-charge response');
    legend('Location','best');
    grid on; box on;
    format_and_save_figure(gcf, fullfile(outdir,'network_reduction_qphi_comparison'));

    % Figure 7: voltage and terminal current for each topology.
    figure;
    yyaxis left;
    plot(t, V_in, 'Color', C.pink, 'DisplayName', 'Input voltage');
    ylabel('Port voltage, v_P(t) [V]');
    ax = gca;
    ax.YColor = C.pink;

    yyaxis right;
    hold on;
    for c = 1:num_cases
        plot(t, case_out{c}.I_port, ...
            'Color', cols(c,:), ...
            'DisplayName', case_names{c});
    end
    hold off;
    ylabel('Port current, i_P(t) [A]');
    ax = gca;
    ax.YColor = C.blue;
    ax.XColor = C.black;
    xlabel('Time [s]');
    title('Input voltage and numerical port currents');
    legend('Location','best');
    grid on; box on;
    format_and_save_figure(gcf, fullfile(outdir,'network_reduction_voltage_and_port_currents'));

    five_case = 4;
    branch_cols = [C.pink; C.blue; C.green; C.yellow; C.lilac];

    % Figure 8: five-memristor network state evolution.
    figure;
    hold on;
    for m = 1:size(case_out{five_case}.x,1)
        plot(t, case_out{five_case}.x(m,:), ...
            'Color', branch_cols(m,:), ...
            'DisplayName', sprintf('M%d',m));
    end
    hold off;
    xlabel('Time [s]');
    ylabel('State variable, x_m(t)');
    title('Five-memristor network state evolution');
    legend('Location','best');
    grid on; box on;
    format_and_save_figure(gcf, fullfile(outdir,'network_reduction_five_network_states'));

    % Figure 9: five-memristor branch currents.
    figure;
    hold on;
    for m = 1:size(case_out{five_case}.I_branch,1)
        plot(t, case_out{five_case}.I_branch(m,:), ...
            'Color', branch_cols(m,:), ...
            'DisplayName', sprintf('I_%d',m));
    end
    hold off;
    xlabel('Time [s]');
    ylabel('Branch current [A]');
    title('Five-memristor network branch currents');
    legend('Location','best');
    grid on; box on;
    format_and_save_figure(gcf, fullfile(outdir,'network_reduction_five_network_branch_currents'));

    % Figure 10: five-memristor individual memristances.
    figure;
    hold on;
    for m = 1:size(case_out{five_case}.M,1)
        plot(t, case_out{five_case}.M(m,:), ...
            'Color', branch_cols(m,:), ...
            'DisplayName', sprintf('M_%d',m));
    end
    hold off;
    xlabel('Time [s]');
    ylabel('Memristance [\Omega]');
    title('Five-memristor individual memristances');
    legend('Location','best');
    grid on; box on;
    format_and_save_figure(gcf, fullfile(outdir,'network_reduction_five_network_individual_memristances'));
end

%% Numerical summary
fprintf('\n================ NUMERICAL NETWORK REDUCTION ================\n');

for c = 1:num_cases
    I_last = case_out{c}.I_port(idx_final);
    V_last = V_in(idx_final);
    loop_area = abs(trapz(V_last,I_last));

    fprintf('\n%s:\n', case_names{c});
    fprintf('Number of memristors = %d\n', size(case_branches{c},1));
    fprintf('Initial x0 = ');
    fprintf('%.2f ', case_x0{c});
    fprintf('\nFinal numerical M_eff = %.4f ohm\n', case_out{c}.M_eff(end));
    fprintf('M_eff range = %.4f to %.4f ohm\n', ...
        min(case_out{c}.M_eff,[],'omitnan'), ...
        max(case_out{c}.M_eff,[],'omitnan'));
    fprintf('Final-cycle I-V loop area = %.4e VA\n', loop_area);
end

fprintf('\nSingle memristor numerical equivalent is in single_out.M_eff.\n');
fprintf('All numerical topology outputs are in case_out.\n');

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
    node_voltage_store = zeros(num_nodes,N);

    x(:,1) = x0(:);

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

    out.x = x;
    out.M = M;
    out.G = G;
    out.V_branch = V_branch;
    out.I_branch = I_branch;
    out.I_port = I_port;
    out.M_eff = M_eff;
    out.G_eff = G_eff;
    out.q_port = cumtrapz(t,I_port);
    out.phi_port = cumtrapz(t,V_in);
    out.node_voltage = node_voltage_store;
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

function plot_network_topology(num_nodes, branches, port_pos, port_neg, C)

    if num_nodes == 4
        coords = [
            0 1;
            1 1;
            1 0;
            0 0
        ];
    else
        theta = linspace(0,2*pi,num_nodes+1);
        theta(end) = [];
        coords = [cos(theta(:)), sin(theta(:))];
    end

    hold on;

    branch_pairs = sort(branches,2);

    for m = 1:size(branches,1)
        a = branches(m,1);
        b = branches(m,2);

        xa = coords(a,1);
        ya = coords(a,2);
        xb = coords(b,1);
        yb = coords(b,2);

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

        branch_color = C.blue;
        if mod(m,2) == 1
            branch_color = C.lilac;
        end

        plot([xa_plot xb_plot],[ya_plot yb_plot], ...
            '-', 'Color', branch_color, 'LineWidth', 1.8);

        xm = (xa_plot+xb_plot)/2;
        ym = (ya_plot+yb_plot)/2;

        text(xm,ym,sprintf('M%d',m), ...
            'HorizontalAlignment','center', ...
            'BackgroundColor','w', ...
            'Color', C.black);
    end

    scatter(coords(:,1),coords(:,2),80, ...
        'MarkerFaceColor', C.pink, ...
        'MarkerEdgeColor', C.black);

    for n = 1:num_nodes
        text(coords(n,1),coords(n,2)+0.08,sprintf('%d',n), ...
            'HorizontalAlignment','center', ...
            'Color', C.black);
    end

    text(coords(port_pos,1),coords(port_pos,2)+0.18,'+ port', ...
        'HorizontalAlignment','center', ...
        'Color', C.green);

    text(coords(port_neg,1),coords(port_neg,2)-0.18,'- port', ...
        'HorizontalAlignment','center', ...
        'Color', C.pink);

    axis equal;
    axis off;
    hold off;
end
