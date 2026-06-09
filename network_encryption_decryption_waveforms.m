%% network_encryption_decryption_waveforms.m
% First-pass encryption/decryption test using HP memristor networks.
%
% Encryption:
%   Apply an input voltage waveform to a memristor network and record the
%   terminal current as the encrypted signal:
%
%       I_enc(t) = G_eq(t) V_in(t)
%
% Decryption:
%   Reuse the same network, same parameters, and same initial states to
%   reconstruct:
%
%       V_dec(t) = I_enc(t) / G_eq(t)
%
% This is a controlled numerical test of reversibility. The time-varying
% network conductance G_eq(t) acts like the key/fingerprint.

clear; close all; clc;

%% Plot settings
C = pastel_palette_report();
cols = [C.pink; C.blue; C.green; C.yellow; C.lilac; C.peach];

outdir = 'results/figures/network_encryption_decryption_waveforms';
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

%% Time and input waveforms
T = 0.2;
N = 20000;
t = linspace(0,T,N);

A = 1.0;
f = 50;
waveforms = define_input_waveforms(t, A, f);

%% HP parameters
params.Ron  = 100;
params.Roff = 30000;
params.mu   = 1.5e-12;
params.Ddev = 10e-9;
params.eta  = -1;

%% Network setup
network.name = 'Five-memristor network';
network.branches = [1 2; 2 3; 1 3; 1 4; 4 3];
network.num_nodes = 4;
network.port_pos = 1;
network.port_neg = 3;
network.x0 = 0.3 * ones(size(network.branches,1),1);

%% Encrypt/decrypt each waveform
num_waveforms = numel(waveforms);
enc_out = repmat(struct(), num_waveforms, 1);

for w = 1:num_waveforms
    net_out = simulate_arbitrary_HP_network( ...
        t, waveforms(w).V, ...
        network.branches, network.num_nodes, ...
        network.port_pos, network.port_neg, ...
        params, network.x0);

    I_encrypted = net_out.I_port;
    G_key = net_out.G_eff;

    V_decrypted = zeros(size(I_encrypted));
    valid_key = abs(G_key) > eps;
    V_decrypted(valid_key) = I_encrypted(valid_key) ./ G_key(valid_key);

    decrypt_error = V_decrypted - waveforms(w).V;

    enc_out(w).name = waveforms(w).name;
    enc_out(w).V_in = waveforms(w).V;
    enc_out(w).I_encrypted = I_encrypted;
    enc_out(w).G_key = G_key;
    enc_out(w).M_key = net_out.M_eff;
    enc_out(w).V_decrypted = V_decrypted;
    enc_out(w).error = decrypt_error;
    enc_out(w).max_abs_error = max(abs(decrypt_error));
    enc_out(w).rmse = sqrt(mean(decrypt_error.^2));
    enc_out(w).network = net_out;
end

%% Save numerical outputs
save(fullfile(outdir,'network_encryption_decryption_waveforms.mat'), ...
    't', 'waveforms', 'enc_out', 'network', 'params');

waveform_name = strings(num_waveforms,1);
max_abs_error = zeros(num_waveforms,1);
rmse = zeros(num_waveforms,1);
I_peak = zeros(num_waveforms,1);
G_mean = zeros(num_waveforms,1);
G_min = zeros(num_waveforms,1);
G_max = zeros(num_waveforms,1);

for w = 1:num_waveforms
    waveform_name(w) = string(enc_out(w).name);
    max_abs_error(w) = enc_out(w).max_abs_error;
    rmse(w) = enc_out(w).rmse;
    I_peak(w) = max(abs(enc_out(w).I_encrypted));
    G_mean(w) = mean(enc_out(w).G_key);
    G_min(w) = min(enc_out(w).G_key);
    G_max(w) = max(enc_out(w).G_key);
end

encryption_summary = table( ...
    waveform_name, max_abs_error, rmse, I_peak, G_mean, G_min, G_max);
writetable(encryption_summary, ...
    fullfile(outdir,'network_encryption_decryption_summary.csv'));

%% Figure 1: input, encrypted current, decrypted voltage
figure;
tiledlayout(num_waveforms,3,'TileSpacing','compact','Padding','compact');

for w = 1:num_waveforms
    nexttile;
    plot(t, enc_out(w).V_in, 'Color', C.pink);
    ylabel('V_{in} [V]');
    title(enc_out(w).name);
    grid on; box on;

    nexttile;
    plot(t, enc_out(w).I_encrypted, 'Color', C.blue);
    ylabel('I_{enc} [A]');
    title('Encrypted current');
    grid on; box on;

    nexttile;
    plot(t, enc_out(w).V_in, 'Color', C.pink, ...
        'DisplayName', 'Input');
    hold on;
    plot(t, enc_out(w).V_decrypted, '--', 'Color', C.green, ...
        'DisplayName', 'Decrypted');
    hold off;
    ylabel('Voltage [V]');
    title(sprintf('RMSE = %.2e V', enc_out(w).rmse));
    grid on; box on;

    if w == num_waveforms
        xlabel('Time [s]');
        nexttile(w*3 - 1);
        xlabel('Time [s]');
        nexttile(w*3);
        xlabel('Time [s]');
    end
end

legend('Location','best');
format_and_save_figure(gcf, ...
    fullfile(outdir,'waveform_encryption_decryption_panel'), 22, 1.05);

%% Figure 2: conductance keys
figure;
hold on;
for w = 1:num_waveforms
    plot(t, enc_out(w).G_key, ...
        'Color', cols(w,:), ...
        'DisplayName', enc_out(w).name);
end
hold off;
xlabel('Time [s]');
ylabel('Network conductance key, G_{eq}(t) [S]');
title('Waveform-dependent network conductance keys');
legend('Location','best');
grid on; box on;
format_and_save_figure(gcf, fullfile(outdir,'waveform_conductance_keys'));

%% Figure 3: decryption error
figure;
hold on;
for w = 1:num_waveforms
    plot(t, enc_out(w).error, ...
        'Color', cols(w,:), ...
        'DisplayName', enc_out(w).name);
end
hold off;
xlabel('Time [s]');
ylabel('V_{dec}(t) - V_{in}(t) [V]');
title('Decryption reconstruction error');
legend('Location','best');
grid on; box on;
format_and_save_figure(gcf, fullfile(outdir,'waveform_decryption_error'));

%% Numerical summary
fprintf('\n================ MEMRISTOR NETWORK ENCRYPTION TEST ================\n');
fprintf('Network = %s\n', network.name);
fprintf('Encrypted signal = terminal current, I_enc(t)\n');
fprintf('Key/fingerprint = identical-state G_eq(t)\n');
fprintf('Decryption rule = V_dec(t) = I_enc(t)/G_eq(t)\n');

for w = 1:num_waveforms
    fprintf('\n%s:\n', enc_out(w).name);
    fprintf('Peak encrypted current = %.4e A\n', max(abs(enc_out(w).I_encrypted)));
    fprintf('G_eq range = %.4e to %.4e S\n', ...
        min(enc_out(w).G_key), max(enc_out(w).G_key));
    fprintf('Max absolute decryption error = %.4e V\n', enc_out(w).max_abs_error);
    fprintf('Decryption RMSE = %.4e V\n', enc_out(w).rmse);
end

fprintf('\nSaved data to %s\n', ...
    fullfile(outdir,'network_encryption_decryption_waveforms.mat'));
fprintf('Saved summary to %s\n', ...
    fullfile(outdir,'network_encryption_decryption_summary.csv'));

%% Local functions
function waveforms = define_input_waveforms(t, A, f)

    waveforms(1).name = 'Sinusoidal';
    waveforms(1).V = A*sin(2*pi*f*t);

    waveforms(2).name = 'Triangle';
    waveforms(2).V = A*project_sawtooth(2*pi*f*t, 0.5);

    waveforms(3).name = 'Sawtooth';
    waveforms(3).V = A*project_sawtooth(2*pi*f*t, 1.0);

    waveforms(4).name = 'Sum of sinusoids';
    waveforms(4).V = 0.5*A*(sin(2*pi*f*t) + cos(2*pi*2*f*t));

    waveforms(5).name = 'Product of sinusoids';
    waveforms(5).V = A*sin(2*pi*f*t).*cos(2*pi*2*f*t);
end

function y = project_sawtooth(theta, width)

    if exist('sawtooth','file') == 2
        y = sawtooth(theta, width);
        return;
    end

    phase = mod(theta/(2*pi), 1);

    if width <= 0 || width > 1
        error('Sawtooth width must satisfy 0 < width <= 1.');
    end

    if width == 1
        y = 2*phase - 1;
        return;
    end

    y = zeros(size(theta));
    rising = phase < width;
    y(rising) = -1 + 2*phase(rising)/width;
    y(~rising) = 1 - 2*(phase(~rising) - width)/(1 - width);
end

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
    M_eff = zeros(1,N);
    G_eff = zeros(1,N);
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
        G_eff(k) = compute_port_conductance(num_nodes, branches, G(:,k), ...
            port_pos, port_neg);
        M_eff(k) = 1 / G_eff(k);

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
    G_eff(N) = compute_port_conductance(num_nodes, branches, G(:,N), ...
        port_pos, port_neg);
    M_eff(N) = 1 / G_eff(N);

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

function G_port = compute_port_conductance(num_nodes, branches, G_branch, port_pos, port_neg)

    p_unit = solve_node_voltages(num_nodes, branches, G_branch, port_pos, port_neg, 1);
    I_branch_unit = zeros(size(G_branch));

    for m = 1:size(branches,1)
        a_node = branches(m,1);
        b_node = branches(m,2);
        I_branch_unit(m) = G_branch(m) * (p_unit(a_node) - p_unit(b_node));
    end

    G_port = compute_port_current(branches, I_branch_unit, port_pos);
end
