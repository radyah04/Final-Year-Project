%% reciprocity_test_1x3.m
% Reciprocity check across the seven single-device memristor models.
%
% For each model:
% 1) Apply sinusoidal voltage v(t), measure current i(t).
% 2) Re-apply i(t) as a current input, reconstruct output voltage v_out(t).
% 3) Save one 1x3 figure and one separate error figure.

clear; close all; clc;

%% ============================================================
% Output folder
% ============================================================
outdir = fullfile('results','figures','reciprocity_test');

if ~exist(outdir,'dir')
    mkdir(outdir);
end

%% ============================================================
% Plot theme
% ============================================================
C = pastel_palette_report();

set(groot,'defaultFigureColor','w');
set(groot,'defaultAxesColor','w');
set(groot,'defaultAxesFontName','Times New Roman');
set(groot,'defaultTextFontName','Times New Roman');
set(groot,'defaultAxesFontSize',11);
set(groot,'defaultAxesLineWidth',1.0);
set(groot,'defaultAxesBox','off');
set(groot,'defaultAxesTickDir','out');
set(groot,'defaultLineLineWidth',1.8);

%% ============================================================
% Time and voltage input
% ============================================================
f_main = 50;
T = 1/f_main;
N = 20000;
t = linspace(0,T,N);
A = 1;
V = A*sin(2*pi*f_main*t);

%% ============================================================
% Model definitions
% ============================================================
base.Ron = 100;
base.Roff = 30000;
base.mu = 1e-12;
base.D = 10e-9;

R0 = base.Roff/10;
k_eff = (base.Roff - base.Ron)*base.mu*base.Ron/base.D^2;

models = struct('name', {}, 'slug', {}, 'type', {}, 'params', {});

models(1).name = 'HP v1';
models(1).slug = 'HP_v1';
models(1).type = 'hp_charge';
models(1).params = struct('R0', R0, 'k_eff', k_eff);

models(2).name = 'HP v2';
models(2).slug = 'HP_v2';
models(2).type = 'hp_charge';
models(2).params = struct('R0', R0, 'k_eff', k_eff);

models(3).name = 'HP v3';
models(3).slug = 'HP_v3';
models(3).type = 'hp_state';
models(3).params = base;
models(3).params.x0 = (base.Roff - R0)/(base.Roff - base.Ron);
models(3).params.eta = -1;

models(4).name = 'Joglekar';
models(4).slug = 'Joglekar';
models(4).type = 'joglekar';
models(4).params = base;
models(4).params.x0 = 0.3;
models(4).params.eta = -1;
models(4).params.p = 1;

models(5).name = 'Prodromakis';
models(5).slug = 'Prodromakis';
models(5).type = 'prodromakis';
models(5).params = base;
models(5).params.x0 = 0.1;
models(5).params.eta = 1;
models(5).params.p1 = 1;
models(5).params.p2 = 2;

models(6).name = 'Chalcogenide/MSS';
models(6).slug = 'Chalcogenide_MSS';
models(6).type = 'chalcogenide';
models(6).params = struct( ...
    'G_ON', 1e-3, ...
    'G_OFF', 1e-5, ...
    'X0', 0.1, ...
    'tau', 5e-4, ...
    'beta', 35, ...
    'V_on', 0.18, ...
    'V_off', 0.27);

models(7).name = 'Chalcogenide/MSS nonlinear';
models(7).slug = 'Chalcogenide_MSS_nonlinear';
models(7).type = 'chalcogenide';
models(7).params = struct( ...
    'G_ON', 1e-3, ...
    'G_OFF', 1e-5, ...
    'X0', 0.1, ...
    'tau', 2e-3, ...
    'beta', 25, ...
    'V_on', 0.27, ...
    'V_off', 0.27);

%% ============================================================
% Reciprocity simulations and plots
% ============================================================
rmse = zeros(numel(models),1);
maxAbsError = zeros(numel(models),1);

for m = 1:numel(models)

    out_v = simulate_voltage_driven_model(t,V,models(m));
    out_i = simulate_current_driven_model(t,out_v.I,models(m));

    I_out = out_v.I;
    V_out = out_i.V;
    err = V_out - V;

    rmse(m) = sqrt(mean(err.^2,'omitnan'));
    maxAbsError(m) = max(abs(err),[],'omitnan');

    hfig = figure;
    set(hfig,'Units','centimeters','Position',[2 2 24 8]);
    tiledlayout(1,3,'TileSpacing','compact','Padding','compact');

    nexttile;
    plot(t,V,'Color',C.pink,'LineWidth',1.5);
    xlabel('Time, t [s]');
    ylabel('Voltage [V]');
    title([models(m).name ' input v(t)'], 'FontWeight','normal');
    grid on; box off;

    nexttile;
    plot(t,I_out,'Color',C.blue,'LineWidth',1.5);
    xlabel('Time, t [s]');
    ylabel('Current [A]');
    title([models(m).name ' output i(t)'], 'FontWeight','normal');
    grid on; box off;

    nexttile;
    plot(t,V,'--','Color',C.black,'LineWidth',1.2,'DisplayName','v_{in}');
    hold on;
    plot(t,V_out,'Color',C.peach,'LineWidth',1.5,'DisplayName','v_{out}');
    hold off;
    xlabel('Time, t [s]');
    ylabel('Voltage [V]');
    title([models(m).name ' v_{out}(t) vs v(t)'], 'FontWeight','normal');
    legend('Location','best');
    grid on; box off;

    sgtitle([models(m).name ' Reciprocity Test'], ...
        'FontName','Times New Roman', ...
        'FontSize',15, ...
        'FontWeight','normal');

    format_reciprocity_figure(hfig,C);
    save_reciprocity_figure(hfig, fullfile(outdir,[models(m).slug '_reciprocity_1x3']), 24, 8);

    hfig = figure;
    plot(t,err,'Color',C.lilac,'LineWidth',1.5);
    xlabel('Time, t [s]');
    ylabel('v_{out}(t) - v(t) [V]');
    title([models(m).name ' Reciprocity Error'], 'FontWeight','normal');
    grid on; box off;

    format_reciprocity_figure(hfig,C);
    save_reciprocity_figure(hfig, fullfile(outdir,[models(m).slug '_reciprocity_error']), 16, 9);
end

summaryTable = table({models.name}', rmse, maxAbsError, ...
    'VariableNames', {'Model','RMSE_V','MaxAbsError_V'});
writetable(summaryTable, fullfile(outdir,'reciprocity_error_summary.csv'));

disp(summaryTable);
fprintf('\nReciprocity figures saved in:\n%s\n', outdir);

%% ============================================================
% Local function: voltage-driven dispatch
% ============================================================
function out = simulate_voltage_driven_model(t,V,model)

    switch model.type
        case 'hp_charge'
            out = simulate_hp_charge_voltage(t,V,model.params);
        case 'hp_state'
            out = simulate_hp_state_voltage(t,V,model.params,@window_linear);
        case 'joglekar'
            out = simulate_hp_state_voltage(t,V,model.params,@window_joglekar);
        case 'prodromakis'
            out = simulate_hp_state_voltage(t,V,model.params,@window_prodromakis);
        case 'chalcogenide'
            out = simulate_chalcogenide_voltage(t,V,model.params);
        otherwise
            error('Unknown model type: %s', model.type);
    end
end

%% ============================================================
% Local function: current-driven dispatch
% ============================================================
function out = simulate_current_driven_model(t,I,model)

    switch model.type
        case 'hp_charge'
            out = simulate_hp_charge_current(t,I,model.params);
        case 'hp_state'
            out = simulate_hp_state_current(t,I,model.params,@window_linear);
        case 'joglekar'
            out = simulate_hp_state_current(t,I,model.params,@window_joglekar);
        case 'prodromakis'
            out = simulate_hp_state_current(t,I,model.params,@window_prodromakis);
        case 'chalcogenide'
            out = simulate_chalcogenide_current(t,I,model.params);
        otherwise
            error('Unknown model type: %s', model.type);
    end
end

%% ============================================================
% Local function: HP v1/v2 charge-controlled voltage drive
% ============================================================
function out = simulate_hp_charge_voltage(t,V,params)

    N = length(t);
    dt = t(2)-t(1);

    q = zeros(1,N);
    phi = zeros(1,N);
    M = zeros(1,N);
    I = zeros(1,N);

    for k = 1:N-1
        M(k) = params.R0 + params.k_eff*q(k);
        I(k) = V(k)/M(k);
        q(k+1) = q(k) + I(k)*dt;
        phi(k+1) = phi(k) + V(k)*dt;
    end

    M(N) = params.R0 + params.k_eff*q(N);
    I(N) = V(N)/M(N);

    out.I = I;
    out.M = M;
    out.G = 1./M;
    out.q = q;
    out.phi = phi;
end

%% ============================================================
% Local function: HP v1/v2 charge-controlled current drive
% ============================================================
function out = simulate_hp_charge_current(t,I,params)

    N = length(t);
    dt = t(2)-t(1);

    q = zeros(1,N);
    M = zeros(1,N);
    V = zeros(1,N);

    for k = 1:N-1
        M(k) = params.R0 + params.k_eff*q(k);
        V(k) = I(k)*M(k);
        q(k+1) = q(k) + I(k)*dt;
    end

    M(N) = params.R0 + params.k_eff*q(N);
    V(N) = I(N)*M(N);

    out.V = V;
    out.M = M;
    out.G = 1./M;
    out.q = q;
    out.phi = cumtrapz(t,V);
end

%% ============================================================
% Local function: HP-family state model under voltage drive
% ============================================================
function out = simulate_hp_state_voltage(t,V,params,window_fun)

    N = length(t);
    dt = t(2)-t(1);

    x = zeros(1,N);
    M = zeros(1,N);
    I = zeros(1,N);

    x(1) = params.x0;

    for k = 1:N-1
        M(k) = params.Ron*x(k) + params.Roff*(1-x(k));
        I(k) = V(k)/M(k);
        dxdt = params.eta*(params.mu*params.Ron/params.D^2)*I(k)*window_fun(x(k),params);
        x(k+1) = min(max(x(k) + dxdt*dt,0),1);
    end

    M(N) = params.Ron*x(N) + params.Roff*(1-x(N));
    I(N) = V(N)/M(N);

    out.I = I;
    out.M = M;
    out.G = 1./M;
    out.x = x;
    out.q = cumtrapz(t,I);
    out.phi = cumtrapz(t,V);
end

%% ============================================================
% Local function: HP-family state model under current drive
% ============================================================
function out = simulate_hp_state_current(t,I,params,window_fun)

    N = length(t);
    dt = t(2)-t(1);

    x = zeros(1,N);
    M = zeros(1,N);
    V = zeros(1,N);

    x(1) = params.x0;

    for k = 1:N-1
        M(k) = params.Ron*x(k) + params.Roff*(1-x(k));
        V(k) = I(k)*M(k);
        dxdt = params.eta*(params.mu*params.Ron/params.D^2)*I(k)*window_fun(x(k),params);
        x(k+1) = min(max(x(k) + dxdt*dt,0),1);
    end

    M(N) = params.Ron*x(N) + params.Roff*(1-x(N));
    V(N) = I(N)*M(N);

    out.V = V;
    out.M = M;
    out.G = 1./M;
    out.x = x;
    out.q = cumtrapz(t,I);
    out.phi = cumtrapz(t,V);
end

%% ============================================================
% Local function: Chalcogenide/MSS voltage drive
% ============================================================
function out = simulate_chalcogenide_voltage(t,V,params)

    N = length(t);
    X = zeros(1,N);
    I = zeros(1,N);
    G = zeros(1,N);

    X(1) = params.X0;

    for k = 1:N-1
        G(k) = X(k)*params.G_ON + (1-X(k))*params.G_OFF;
        I(k) = G(k)*V(k);
        X(k+1) = update_chalcogenide_state(X(k),V(k),t(k+1)-t(k),params);
    end

    G(N) = X(N)*params.G_ON + (1-X(N))*params.G_OFF;
    I(N) = G(N)*V(N);

    out.I = I;
    out.G = G;
    out.M = 1./G;
    out.X = X;
    out.q = cumtrapz(t,I);
    out.phi = cumtrapz(t,V);
end

%% ============================================================
% Local function: Chalcogenide/MSS current drive
% ============================================================
function out = simulate_chalcogenide_current(t,I,params)

    N = length(t);
    X = zeros(1,N);
    V = zeros(1,N);
    G = zeros(1,N);

    X(1) = params.X0;

    for k = 1:N-1
        G(k) = X(k)*params.G_ON + (1-X(k))*params.G_OFF;
        V(k) = I(k)/G(k);
        X(k+1) = update_chalcogenide_state(X(k),V(k),t(k+1)-t(k),params);
    end

    G(N) = X(N)*params.G_ON + (1-X(N))*params.G_OFF;
    V(N) = I(N)/G(N);

    out.V = V;
    out.G = G;
    out.M = 1./G;
    out.X = X;
    out.q = cumtrapz(t,I);
    out.phi = cumtrapz(t,V);
end

%% ============================================================
% Local function: Chalcogenide/MSS state step
% ============================================================
function X_next = update_chalcogenide_state(X,V,dt,params)

    p_on = 1/(1 + exp(-params.beta*(V-params.V_on)));
    p_off = 1/(1 + exp(-params.beta*(-V-params.V_off)));
    dxdt = ((1-X)*p_on - X*p_off)/params.tau;
    X_next = min(max(X + dxdt*dt,0),1);
end

%% ============================================================
% Window functions
% ============================================================
function w = window_linear(~,~)
    w = 1;
end

function w = window_joglekar(x,params)
    w = 1 - (2*x - 1)^(2*params.p);
end

function w = window_prodromakis(x,params)
    w = params.p1*(1 - ((x - 0.5)^2 + 0.75)^params.p2);
end

%% ============================================================
% Local function: common formatting
% ============================================================
function format_reciprocity_figure(hfig,C)

    ax = findall(hfig,'type','axes');

    for k = 1:length(ax)
        set(ax(k), ...
            'FontName','Times New Roman', ...
            'FontSize',10.5, ...
            'LineWidth',1.0, ...
            'Box','off', ...
            'TickDir','out', ...
            'XColor',C.black, ...
            'YColor',C.black, ...
            'GridAlpha',0.14, ...
            'MinorGridAlpha',0.08);
        grid(ax(k),'on');
    end

    lgd = findall(hfig,'type','legend');

    for k = 1:length(lgd)
        set(lgd(k), ...
            'Box','off', ...
            'FontName','Times New Roman', ...
            'FontSize',9.5);
    end
end

%% ============================================================
% Local function: PNG and PDF export
% ============================================================
function save_reciprocity_figure(hfig, fname, picturewidth, pictureheight)

    set(hfig, ...
        'Color','w', ...
        'Units','centimeters', ...
        'Position',[3 3 picturewidth pictureheight]);

    drawnow;

    set(hfig, ...
        'PaperPositionMode','Auto', ...
        'PaperUnits','centimeters', ...
        'PaperSize',[picturewidth pictureheight]);

    print(hfig, [fname '.png'], '-dpng', '-r600');
    print(hfig, [fname '.pdf'], '-dpdf', '-painters');
end
