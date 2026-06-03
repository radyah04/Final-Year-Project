function save_figure(figHandle,filename)
%SAVE_FIGURE Saves figure as high-resolution PNG and vector PDF.

exportgraphics(figHandle,[filename '.png'],'Resolution',600);
exportgraphics(figHandle,[filename '.pdf'],'ContentType','vector');

end
