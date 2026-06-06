function format_and_save_figure(hfig, fname, picturewidth, hw_ratio)

if nargin < 3
    picturewidth = 16;
end
if nargin < 4
    hw_ratio = 0.62;
end

set(hfig,'Color','w');
set(hfig,'Units','centimeters','Position',[3 3 picturewidth hw_ratio*picturewidth]);

ax = findall(hfig,'type','axes');
for k = 1:length(ax)
    set(ax(k), ...
        'FontName','Times New Roman', ...
        'FontSize',12, ...
        'LineWidth',1.0, ...
        'Box','off', ...
        'TickDir','out', ...
        'XColor',[0 0 0], ...
        'GridAlpha',0.12, ...
        'MinorGridAlpha',0.08);
    grid(ax(k),'on');
end

lgd = findall(hfig,'type','legend');
for k = 1:length(lgd)
    set(lgd(k), ...
        'Box','off', ...
        'FontName','Times New Roman', ...
        'FontSize',10);
end

drawnow;

pos = get(hfig,'Position');
set(hfig,'PaperPositionMode','Auto');
set(hfig,'PaperUnits','centimeters');
set(hfig,'PaperSize',[pos(3), pos(4)]);

print(hfig,[fname '.png'],'-dpng','-r600');
print(hfig,[fname '.pdf'],'-dpdf','-painters');
end
