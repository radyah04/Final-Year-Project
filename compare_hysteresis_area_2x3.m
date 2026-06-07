%% compare_hysteresis_area_2x3.m
% Aesthetic 2x3 comparison of hysteresis loop area across the six models.
%
% Produces:
% 1) Frequency sweep area comparison, one panel per model
% 2) Amplitude sweep area comparison, one panel per model
% 3) Absolute frequency sweep comparison on one semilog plot

clear; close all; clc;

%% ============================================================
% Output folder
% ============================================================
outdir = fullfile('results','figures','comparison_hysteresis_area');

if ~exist(outdir,'dir')
    mkdir(outdir);
end

%% ============================================================
% Plot theme
% ============================================================
C = pastel_palette_report();
cols = [C.pink; C.blue; C.green; C.yellow; C.lilac; C.peach];

set(groot,'defaultFigureColor','w');
set(groot,'defaultAxesColor','w');
set(groot,'defaultAxesFontName','Times New Roman');
set(groot,'defaultTextFontName','Times New Roman');
set(groot,'defaultAxesFontSize',11);
set(groot,'defaultAxesLineWidth',1.0);
set(groot,'defaultAxesBox','off');
set(groot,'defaultAxesTickDir','out');
set(groot,'defaultLineLineWidth',1.9);

%% ============================================================
% Model summary files
% ============================================================
models = struct( ...
    'name', {}, ...
    'freqFile', {}, ...
    'ampFile', {});

models(1).name = 'HP v1';
models(1).freqFile = fullfile('results','figures','HP_v1_final_fixed','HPv1_frequency_sweep_summary.csv');
models(1).ampFile = fullfile('results','figures','HP_v1_final_fixed','HPv1_amplitude_sweep_summary.csv');

models(2).name = 'HP v2';
models(2).freqFile = fullfile('results','figures','HP_v2_final_fixed','HPv2_frequency_sweep_summary.csv');
models(2).ampFile = fullfile('results','figures','HP_v2_final_fixed','HPv2_amplitude_sweep_summary.csv');

models(3).name = 'HP v3';
models(3).freqFile = fullfile('results','figures_HP_v3_sweeps','HP_v3_frequency_sweep_summary.csv');
models(3).ampFile = fullfile('results','figures_HP_v3_sweeps','HP_v3_amplitude_sweep_summary.csv');

models(4).name = 'Joglekar';
models(4).freqFile = fullfile('results','figures','HP_Joglekar_final','HP_Joglekar_frequency_sweep_summary.csv');
models(4).ampFile = fullfile('results','figures','HP_Joglekar_final','HP_Joglekar_amplitude_sweep_summary.csv');

models(5).name = 'Prodromakis';
models(5).freqFile = fullfile('results','figures','HP_Prodromakis_final','HP_Prodromakis_frequency_sweep_summary.csv');
models(5).ampFile = fullfile('results','figures','HP_Prodromakis_final','HP_Prodromakis_amplitude_sweep_summary.csv');

models(6).name = 'Chalcogenide/MSS';
models(6).freqFile = fullfile('results','figures','Chalcogenide_MSS_full','Chalcogenide_MSS_frequency_sweep_summary.csv');
models(6).ampFile = fullfile('results','figures','Chalcogenide_MSS_full','Chalcogenide_MSS_amplitude_sweep_summary.csv');

%% ============================================================
% Read data
% ============================================================
for k = 1:numel(models)

    freqTable = readtable(models(k).freqFile);
    ampTable = readtable(models(k).ampFile);

    models(k).freq = freqTable.Frequency_Hz;
    models(k).areaFreq = freqTable.IV_Loop_Area;
    models(k).amp = ampTable.Amplitude_V;
    models(k).areaAmp = ampTable.IV_Loop_Area;
end

%% ============================================================
% Figure 1: frequency sweep area, 2x3 small multiples
% ============================================================
hfig = figure;
set(hfig,'Units','centimeters','Position',[2 2 24 14.5]);

tiledlayout(2,3,'TileSpacing','compact','Padding','compact');

for k = 1:numel(models)

    nexttile;

    [areaScaled, yLabelText] = scale_area_for_plot(models(k).areaFreq);

    plot(models(k).freq, areaScaled, 'o-', ...
        'Color', cols(k,:), ...
        'MarkerFaceColor', cols(k,:), ...
        'MarkerEdgeColor', C.black, ...
        'MarkerSize', 5.5, ...
        'LineWidth', 1.9);

    title(models(k).name, 'FontWeight','normal');
    xlabel('Frequency [Hz]');
    ylabel(yLabelText);
    grid on;
    box off;
    xlim([min(models(k).freq) max(models(k).freq)]);
end

sgtitle('Hysteresis Area versus Frequency Across Models', ...
    'FontName','Times New Roman', ...
    'FontSize',16, ...
    'FontWeight','normal');

format_comparison_figure(hfig);
save_comparison_figure(hfig, fullfile(outdir,'HysteresisArea_frequency_2x3'), 24, 14.5);

%% ============================================================
% Figure 2: amplitude sweep area, 2x3 small multiples
% ============================================================
hfig = figure;
set(hfig,'Units','centimeters','Position',[2 2 24 14.5]);

tiledlayout(2,3,'TileSpacing','compact','Padding','compact');

for k = 1:numel(models)

    nexttile;

    [areaScaled, yLabelText] = scale_area_for_plot(models(k).areaAmp);

    plot(models(k).amp, areaScaled, 'o-', ...
        'Color', cols(k,:), ...
        'MarkerFaceColor', cols(k,:), ...
        'MarkerEdgeColor', C.black, ...
        'MarkerSize', 5.5, ...
        'LineWidth', 1.9);

    title(models(k).name, 'FontWeight','normal');
    xlabel('Amplitude [V]');
    ylabel(yLabelText);
    grid on;
    box off;
    xlim([min(models(k).amp) max(models(k).amp)]);
end

sgtitle('Hysteresis Area versus Voltage Amplitude Across Models', ...
    'FontName','Times New Roman', ...
    'FontSize',16, ...
    'FontWeight','normal');

format_comparison_figure(hfig);
save_comparison_figure(hfig, fullfile(outdir,'HysteresisArea_amplitude_2x3'), 24, 14.5);

%% ============================================================
% Figure 3: absolute comparison on one semilog axis
% ============================================================
hfig = figure;
hold on;

for k = 1:numel(models)
    semilogy(models(k).freq, models(k).areaFreq, 'o-', ...
        'Color', cols(k,:), ...
        'MarkerFaceColor', cols(k,:), ...
        'MarkerEdgeColor', C.black, ...
        'MarkerSize', 5.5, ...
        'LineWidth', 1.9, ...
        'DisplayName', models(k).name);
end

hold off;
xlabel('Frequency [Hz]');
ylabel('Hysteresis area [VA]');
title('Absolute Hysteresis Area Comparison');
legend('Location','best');
grid on;
box off;

format_comparison_figure(hfig);
save_comparison_figure(hfig, fullfile(outdir,'HysteresisArea_frequency_semilog_all_models'), 16, 10);

fprintf('\nComparison figures saved in:\n%s\n', outdir);

%% ============================================================
% Local function: readable engineering-scale y-axis
% ============================================================
function [areaScaled, yLabelText] = scale_area_for_plot(area)

    maxArea = max(abs(area));

    if maxArea >= 1e-3
        scale = 1e-3;
        unitText = 'mVA';
    elseif maxArea >= 1e-6
        scale = 1e-6;
        unitText = '\muVA';
    elseif maxArea >= 1e-9
        scale = 1e-9;
        unitText = 'nVA';
    elseif maxArea >= 1e-12
        scale = 1e-12;
        unitText = 'pVA';
    else
        scale = 1;
        unitText = 'VA';
    end

    areaScaled = area./scale;
    yLabelText = ['Hysteresis area [' unitText ']'];
end

%% ============================================================
% Local function: common final styling
% ============================================================
function format_comparison_figure(hfig)

    Cblack = [0.10 0.10 0.10];
    ax = findall(hfig,'type','axes');

    for kk = 1:length(ax)
        set(ax(kk), ...
            'FontName','Times New Roman', ...
            'FontSize',10.5, ...
            'LineWidth',1.0, ...
            'Box','off', ...
            'TickDir','out', ...
            'XColor',Cblack, ...
            'YColor',Cblack, ...
            'GridAlpha',0.14, ...
            'MinorGridAlpha',0.08);
        grid(ax(kk),'on');
    end

    lgd = findall(hfig,'type','legend');

    for kk = 1:length(lgd)
        set(lgd(kk), ...
            'Box','off', ...
            'FontName','Times New Roman', ...
            'FontSize',10);
    end
end

%% ============================================================
% Local function: PNG and PDF export
% ============================================================
function save_comparison_figure(hfig, fname, picturewidth, pictureheight)

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
