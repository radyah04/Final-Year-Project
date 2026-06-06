function set_project_plot_defaults()
% Global plot settings for the project.

set(groot, 'defaultFigureColor', 'w');
set(groot, 'defaultAxesColor', 'w');
set(groot, 'defaultAxesFontName', 'Times New Roman');
set(groot, 'defaultTextFontName', 'Times New Roman');
set(groot, 'defaultAxesFontSize', 12);
set(groot, 'defaultTextFontSize', 12);

set(groot, 'defaultAxesLineWidth', 1.0);
set(groot, 'defaultLineLineWidth', 1.8);

set(groot, 'defaultAxesBox', 'off');
set(groot, 'defaultAxesTickDir', 'out');
set(groot, 'defaultAxesTickLength', [0.015 0.015]);

set(groot, 'defaultAxesXGrid', 'on');
set(groot, 'defaultAxesYGrid', 'on');
set(groot, 'defaultAxesGridAlpha', 0.15);
set(groot, 'defaultAxesMinorGridAlpha', 0.08);

set(groot, 'defaultAxesXMinorGrid', 'off');
set(groot, 'defaultAxesYMinorGrid', 'off');

set(groot, 'defaultLegendBox', 'off');
set(groot, 'defaultLegendFontSize', 10);
set(groot, 'defaultLegendInterpreter', 'latex');

set(groot, 'defaultTextInterpreter', 'latex');
set(groot, 'defaultAxesTickLabelInterpreter', 'latex');

set(groot, 'defaultFigureVisible', 'on');

% Set default colour order to the project pastel palette.
set(groot, 'defaultAxesColorOrder', pastel_palette());
end
