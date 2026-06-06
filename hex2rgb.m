function rgb = hex2rgb(hex)
% Convert hex colour string like '#fcc2d7' to RGB triple in [0,1].

hex = char(hex);
if hex(1) == '#'
    hex = hex(2:end);
end

rgb = [hex2dec(hex(1:2)), hex2dec(hex(3:4)), hex2dec(hex(5:6))] / 255;
end
