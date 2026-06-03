function plot_single_model_results(t,v,out,modelName)
%PLOT_SINGLE_MODEL_RESULTS Creates standard model validation plots.

figDir = 'results/figures';

if ~exist(figDir,'dir')
    mkdir(figDir);
end

%% Time response
figure;
yyaxis left
plot(t,v);
ylabel('Voltage, v(t) [V]');

yyaxis right
plot(t,out.i);
ylabel('Current, i(t) [A]');

xlabel('Time [s]');
title([modelName ' model: voltage and current response']);
grid on;

save_figure(gcf,fullfile(figDir,[modelName '_time_response']));

%% I-V hysteresis
figure;
plot(v,out.i);
xlabel('Voltage, v(t) [V]');
ylabel('Current, i(t) [A]');
title([modelName ' model: I-V hysteresis']);
grid on;

save_figure(gcf,fullfile(figDir,[modelName '_IV']));

%% q-phi relationship
figure;
plot(out.q,out.phi);
xlabel('Charge, q(t) [C]');
ylabel('Flux, \phi(t) [Wb]');
title([modelName ' model: q-\phi relationship']);
grid on;

save_figure(gcf,fullfile(figDir,[modelName '_q_phi']));

%% Memristance over time
figure;
plot(t,out.M);
xlabel('Time [s]');
ylabel('Memristance, M(t) [\Omega]');
title([modelName ' model: memristance response']);
grid on;

save_figure(gcf,fullfile(figDir,[modelName '_M_time']));

%% Conductance over time
figure;
plot(t,out.G);
xlabel('Time [s]');
ylabel('Conductance, G(t) [S]');
title([modelName ' model: conductance response']);
grid on;

save_figure(gcf,fullfile(figDir,[modelName '_G_time']));

%% State variable
if isfield(out,'x')
    figure;
    plot(t,out.x);
    xlabel('Time [s]');
    ylabel('State variable, x=w/D');
    title([modelName ' model: state evolution']);
    grid on;

    save_figure(gcf,fullfile(figDir,[modelName '_state']));
end

end
