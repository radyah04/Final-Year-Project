function network_encryption_decryption_ui
%NETWORK_ENCRYPTION_DECRYPTION_UI Interactive memristor network encryption demo.
%
% Run with:
%   network_encryption_decryption_ui
%
% The branch matrix defines one memristor per row:
%   [start_node end_node]
%
% Encryption uses the branch matrix and "Encryption x0". Decryption uses the
% same encrypted current, but recomputes the network key using "Decryption
% x0". The decrypted signal only matches well when the decryption initial
% conditions match the encryption initial conditions.

    C = local_palette();
    app = struct();
    app.encrypted = [];

    app.fig = uifigure( ...
        'Name', 'Memristor Network Encryption Demo', ...
        'Position', [80 80 1320 760], ...
        'Color', [1 1 1]);

    main = uigridlayout(app.fig, [1 2]);
    main.ColumnWidth = {360, '1x'};
    main.RowHeight = {'1x'};
    main.Padding = [12 12 12 12];
    main.ColumnSpacing = 14;

    controls = uipanel(main, 'Title', 'Network and Signal');
    controls.Layout.Row = 1;
    controls.Layout.Column = 1;
    controls.BackgroundColor = [1 1 1];

    cg = uigridlayout(controls, [22 2]);
    cg.ColumnWidth = {150, '1x'};
    cg.RowHeight = { ...
        24, 122, 32, 32, 32, 32, 32, 32, 32, ...
        32, 32, 32, 32, 32, 32, 32, 32, 36, 36, 36, 48, '1x'};
    cg.Padding = [10 10 10 10];
    cg.RowSpacing = 8;

    branchLabel = uilabel(cg, 'Text', 'Branch matrix [a b]');
    branchLabel.Layout.Row = 1;
    branchLabel.Layout.Column = [1 2];
    app.branchTable = uitable(cg, ...
        'Data', [1 2; 2 3; 1 3; 1 4; 4 3], ...
        'ColumnName', {'From', 'To'}, ...
        'ColumnEditable', [true true], ...
        'CellEditCallback', @redraw_network);
    app.branchTable.Layout.Row = 2;
    app.branchTable.Layout.Column = [1 2];

    app.addBranchButton = uibutton(cg, 'Text', 'Add memristor', ...
        'ButtonPushedFcn', @add_branch);
    app.addBranchButton.Layout.Row = 3;
    app.addBranchButton.Layout.Column = 1;

    app.removeBranchButton = uibutton(cg, 'Text', 'Remove last', ...
        'ButtonPushedFcn', @remove_branch);
    app.removeBranchButton.Layout.Row = 3;
    app.removeBranchButton.Layout.Column = 2;

    add_labeled_numeric(cg, 4, 'Number of nodes', 4, 'numNodes');
    add_labeled_numeric(cg, 5, '+ port node', 1, 'portPos');
    add_labeled_numeric(cg, 6, '- port node', 3, 'portNeg');
    app.numNodes.ValueChangedFcn = @redraw_network;
    app.portPos.ValueChangedFcn = @redraw_network;
    app.portNeg.ValueChangedFcn = @redraw_network;

    add_labeled_edit(cg, 7, 'Encryption x0', '0.3 0.3 0.3 0.3 0.3', 'x0Enc');
    add_labeled_edit(cg, 8, 'Decryption x0', '0.3 0.3 0.3 0.3 0.3', 'x0Dec');

    waveLabel = uilabel(cg, 'Text', 'Waveform');
    waveLabel.Layout.Row = 9;
    waveLabel.Layout.Column = 1;
    app.waveDrop = uidropdown(cg, ...
        'Items', {'Sinusoidal', 'Triangle', 'Sawtooth', ...
        'Sum of sinusoids', 'Product of sinusoids'}, ...
        'Value', 'Sinusoidal');
    app.waveDrop.Layout.Row = 9;
    app.waveDrop.Layout.Column = 2;

    add_labeled_numeric(cg, 10, 'Amplitude [V]', 1.0, 'amp');
    add_labeled_numeric(cg, 11, 'Frequency [Hz]', 50, 'freq');
    add_labeled_numeric(cg, 12, 'Duration [s]', 0.2, 'duration');
    add_labeled_numeric(cg, 13, 'Samples', 4000, 'samples');

    add_labeled_numeric(cg, 14, 'Ron [ohm]', 100, 'Ron');
    add_labeled_numeric(cg, 15, 'Roff [ohm]', 30000, 'Roff');
    add_labeled_numeric(cg, 16, 'Mobility', 1.5e-12, 'mu');
    add_labeled_numeric(cg, 17, 'D [m]', 10e-9, 'Ddev');

    etaLabel = uilabel(cg, 'Text', 'Polarity eta');
    etaLabel.Layout.Row = 18;
    etaLabel.Layout.Column = 1;
    app.eta = uidropdown(cg, 'Items', {'-1', '1'}, 'Value', '-1');
    app.eta.Layout.Row = 18;
    app.eta.Layout.Column = 2;

    app.encryptButton = uibutton(cg, 'Text', 'Encrypt', ...
        'BackgroundColor', C.blue, ...
        'FontWeight', 'bold', ...
        'ButtonPushedFcn', @encrypt_signal);
    app.encryptButton.Layout.Row = 19;
    app.encryptButton.Layout.Column = [1 2];

    app.decryptButton = uibutton(cg, 'Text', 'Decrypt attempt', ...
        'BackgroundColor', C.green, ...
        'FontWeight', 'bold', ...
        'ButtonPushedFcn', @decrypt_signal);
    app.decryptButton.Layout.Row = 20;
    app.decryptButton.Layout.Column = [1 2];

    app.status = uitextarea(cg, ...
        'Editable', 'off', ...
        'Value', {'Ready. Defaults use the five-memristor bridge network.'});
    app.status.Layout.Row = [21 22];
    app.status.Layout.Column = [1 2];

    plots = uipanel(main, 'Title', 'Animated Encryption and Decryption');
    plots.Layout.Row = 1;
    plots.Layout.Column = 2;
    plots.BackgroundColor = [1 1 1];

    pg = uigridlayout(plots, [3 3]);
    pg.ColumnWidth = {260, '1x', '1x'};
    pg.RowHeight = {'1x', '1x', '1x'};
    pg.Padding = [10 10 10 10];
    pg.RowSpacing = 10;
    pg.ColumnSpacing = 10;

    app.axNetwork = uiaxes(pg);
    app.axNetwork.Layout.Row = [1 2];
    app.axNetwork.Layout.Column = 1;
    title(app.axNetwork, 'Network topology');
    app.axNetwork.XTick = [];
    app.axNetwork.YTick = [];
    app.axNetwork.Box = 'on';

    app.axInput = uiaxes(pg);
    app.axInput.Layout.Row = 1;
    app.axInput.Layout.Column = 2;
    title(app.axInput, 'Input waveform');
    xlabel(app.axInput, 'Time [s]');
    ylabel(app.axInput, 'V_{in} [V]');
    grid(app.axInput, 'on');

    app.axEncrypted = uiaxes(pg);
    app.axEncrypted.Layout.Row = 1;
    app.axEncrypted.Layout.Column = 3;
    title(app.axEncrypted, 'Encrypted terminal current');
    xlabel(app.axEncrypted, 'Time [s]');
    ylabel(app.axEncrypted, 'I_{enc} [A]');
    grid(app.axEncrypted, 'on');

    app.axKey = uiaxes(pg);
    app.axKey.Layout.Row = 2;
    app.axKey.Layout.Column = 2;
    title(app.axKey, 'Network conductance key');
    xlabel(app.axKey, 'Time [s]');
    ylabel(app.axKey, 'G_{eq} [S]');
    grid(app.axKey, 'on');

    app.axDec = uiaxes(pg);
    app.axDec.Layout.Row = 2;
    app.axDec.Layout.Column = 3;
    title(app.axDec, 'Decryption attempt');
    xlabel(app.axDec, 'Time [s]');
    ylabel(app.axDec, 'Voltage [V]');
    grid(app.axDec, 'on');

    app.axErr = uiaxes(pg);
    app.axErr.Layout.Row = 3;
    app.axErr.Layout.Column = [1 3];
    title(app.axErr, 'Reconstruction error');
    xlabel(app.axErr, 'Time [s]');
    ylabel(app.axErr, 'V_{dec} - V_{in} [V]');
    grid(app.axErr, 'on');

    draw_network_from_controls();

    function add_labeled_numeric(parent, row, label, value, field)
        lbl = uilabel(parent, 'Text', label);
        lbl.Layout.Row = row;
        lbl.Layout.Column = 1;
        app.(field) = uieditfield(parent, 'numeric', 'Value', value);
        app.(field).Layout.Row = row;
        app.(field).Layout.Column = 2;
    end

    function add_labeled_edit(parent, row, label, value, field)
        lbl = uilabel(parent, 'Text', label);
        lbl.Layout.Row = row;
        lbl.Layout.Column = 1;
        app.(field) = uieditfield(parent, 'text', 'Value', value);
        app.(field).Layout.Row = row;
        app.(field).Layout.Column = 2;
    end

    function add_branch(~, ~)
        data = app.branchTable.Data;
        app.branchTable.Data = [data; 1 2];
        sync_x0_lengths();
        draw_network_from_controls();
    end

    function remove_branch(~, ~)
        data = app.branchTable.Data;
        if size(data,1) > 1
            app.branchTable.Data = data(1:end-1,:);
        end
        sync_x0_lengths();
        draw_network_from_controls();
    end

    function sync_x0_lengths()
        n = size(app.branchTable.Data,1);
        app.x0Enc.Value = vector_to_text(resize_x0(parse_vector(app.x0Enc.Value), n, 0.3));
        app.x0Dec.Value = vector_to_text(resize_x0(parse_vector(app.x0Dec.Value), n, 0.3));
    end

    function redraw_network(~, ~)
        draw_network_from_controls();
    end

    function draw_network_from_controls()
        try
            branches = round(app.branchTable.Data);
            branches = branches(all(~isnan(branches),2),:);
            draw_network_topology(app.axNetwork, branches, round(app.numNodes.Value), ...
                round(app.portPos.Value), round(app.portNeg.Value), C);
        catch
            cla(app.axNetwork);
            title(app.axNetwork, 'Network topology');
            text(app.axNetwork, 0.5, 0.5, 'Invalid network', ...
                'HorizontalAlignment', 'center');
            axis(app.axNetwork, 'off');
        end
    end

    function encrypt_signal(~, ~)
        try
            cfg = read_config(true);
            set_status({'Encrypting...', ...
                sprintf('Waveform: %s', cfg.waveform), ...
                sprintf('Memristors: %d', size(cfg.branches,1))});
            draw_network_topology(app.axNetwork, cfg.branches, cfg.num_nodes, ...
                cfg.port_pos, cfg.port_neg, C);

            net_out = simulate_arbitrary_HP_network( ...
                cfg.t, cfg.V, cfg.branches, cfg.num_nodes, ...
                cfg.port_pos, cfg.port_neg, cfg.params, cfg.x0_enc);

            app.encrypted.cfg = cfg;
            app.encrypted.net_out = net_out;
            app.encrypted.I_enc = net_out.I_port;
            app.encrypted.G_enc = net_out.G_eff;

            cla(app.axDec);
            cla(app.axErr);
            animate_encryption(cfg, app.encrypted.I_enc, app.encrypted.G_enc);

            set_status({'Encryption complete.', ...
                'Now change Decryption x0 and press Decrypt attempt.', ...
                'Correct decryption requires the same initial states.'});
        catch ME
            set_status({'Encryption failed:', ME.message});
        end
    end

    function decrypt_signal(~, ~)
        try
            if isempty(app.encrypted)
                set_status({'No encrypted signal yet.', 'Press Encrypt first.'});
                return;
            end

            cfg = read_config(false);
            enc_cfg = app.encrypted.cfg;

            if ~isequal(cfg.branches, enc_cfg.branches) || ...
                    cfg.num_nodes ~= enc_cfg.num_nodes || ...
                    cfg.port_pos ~= enc_cfg.port_pos || ...
                    cfg.port_neg ~= enc_cfg.port_neg
                set_status({'Network changed after encryption.', ...
                    'Use the same branch matrix and port nodes for this demo.'});
                return;
            end

            if numel(cfg.t) ~= numel(enc_cfg.t)
                set_status({'Timing changed after encryption.', ...
                    'Use the same duration and sample count for this demo.'});
                return;
            end

            set_status({'Decrypting...', ...
                'Trying to regenerate the conductance key from Decryption x0.'});

            key_out = simulate_arbitrary_HP_network( ...
                enc_cfg.t, enc_cfg.V, cfg.branches, cfg.num_nodes, ...
                cfg.port_pos, cfg.port_neg, cfg.params, cfg.x0_dec);

            I_enc = app.encrypted.I_enc;
            G_dec = key_out.G_eff;
            V_dec = zeros(size(I_enc));
            valid_key = abs(G_dec) > eps;
            V_dec(valid_key) = I_enc(valid_key) ./ G_dec(valid_key);

            err = V_dec - enc_cfg.V;
            max_abs_error = max(abs(err));
            rmse = sqrt(mean(err.^2));
            x0_error = max(abs(cfg.x0_dec(:) - enc_cfg.x0_enc(:)));

            animate_decryption(enc_cfg.t, enc_cfg.V, V_dec, err);

            if max_abs_error < 1e-8
                result = 'Decryption matched.';
            else
                result = 'Decryption mismatch.';
            end

            set_status({result, ...
                sprintf('max |x0_dec - x0_enc| = %.4g', x0_error), ...
                sprintf('max voltage error = %.4e V', max_abs_error), ...
                sprintf('RMSE = %.4e V', rmse)});
        catch ME
            set_status({'Decryption failed:', ME.message});
        end
    end

    function cfg = read_config(require_enc)
        branches = app.branchTable.Data;
        branches = branches(all(~isnan(branches),2),:);
        branches = round(branches);

        if size(branches,2) ~= 2 || isempty(branches)
            error('Branch matrix must have two columns and at least one row.');
        end

        num_nodes = round(app.numNodes.Value);
        port_pos = round(app.portPos.Value);
        port_neg = round(app.portNeg.Value);

        if num_nodes < 2
            error('Number of nodes must be at least 2.');
        end
        if any(branches(:) < 1) || any(branches(:) > num_nodes)
            error('Branch nodes must be between 1 and Number of nodes.');
        end
        if port_pos == port_neg
            error('Positive and negative port nodes must be different.');
        end
        if port_pos < 1 || port_pos > num_nodes || port_neg < 1 || port_neg > num_nodes
            error('Port nodes must be valid node numbers.');
        end

        n_mem = size(branches,1);
        x0_enc = resize_x0(parse_vector(app.x0Enc.Value), n_mem, 0.3);
        x0_dec = resize_x0(parse_vector(app.x0Dec.Value), n_mem, 0.3);

        if any(x0_enc < 0) || any(x0_enc > 1) || any(x0_dec < 0) || any(x0_dec > 1)
            error('Initial states must be between 0 and 1.');
        end

        if require_enc
            app.x0Enc.Value = vector_to_text(x0_enc);
        end
        app.x0Dec.Value = vector_to_text(x0_dec);

        T = app.duration.Value;
        N = round(app.samples.Value);
        if T <= 0 || N < 20
            error('Duration must be positive and Samples must be at least 20.');
        end

        t = linspace(0, T, N);
        V = make_waveform(t, app.amp.Value, app.freq.Value, app.waveDrop.Value);

        params.Ron = app.Ron.Value;
        params.Roff = app.Roff.Value;
        params.mu = app.mu.Value;
        params.Ddev = app.Ddev.Value;
        params.eta = str2double(app.eta.Value);

        if params.Ron <= 0 || params.Roff <= 0 || params.Ddev <= 0
            error('Ron, Roff, and D must be positive.');
        end

        cfg.branches = branches;
        cfg.num_nodes = num_nodes;
        cfg.port_pos = port_pos;
        cfg.port_neg = port_neg;
        cfg.x0_enc = x0_enc(:);
        cfg.x0_dec = x0_dec(:);
        cfg.t = t;
        cfg.V = V;
        cfg.params = params;
        cfg.waveform = app.waveDrop.Value;
    end

    function animate_encryption(cfg, I_enc, G_enc)
        cla(app.axInput);
        cla(app.axEncrypted);
        cla(app.axKey);

        setup_axis(app.axInput, cfg.t, cfg.V);
        setup_axis(app.axEncrypted, cfg.t, I_enc);
        setup_axis(app.axKey, cfg.t, G_enc);

        hV = animatedline(app.axInput, 'Color', C.pink, 'LineWidth', 1.8);
        hI = animatedline(app.axEncrypted, 'Color', C.blue, 'LineWidth', 1.8);
        hG = animatedline(app.axKey, 'Color', C.yellow, 'LineWidth', 1.8);

        step = animation_step(numel(cfg.t));
        for k = 1:step:numel(cfg.t)
            idx = k:min(k+step-1, numel(cfg.t));
            addpoints(hV, cfg.t(idx), cfg.V(idx));
            addpoints(hI, cfg.t(idx), I_enc(idx));
            addpoints(hG, cfg.t(idx), G_enc(idx));
            drawnow limitrate;
        end
    end

    function animate_decryption(t, V_in, V_dec, err)
        cla(app.axDec);
        cla(app.axErr);

        setup_axis(app.axDec, t, [V_in(:); V_dec(:)]);
        setup_axis(app.axErr, t, err);

        hIn = animatedline(app.axDec, 'Color', C.pink, 'LineWidth', 1.8, ...
            'DisplayName', 'Input');
        hDec = animatedline(app.axDec, 'Color', C.green, 'LineStyle', '--', ...
            'LineWidth', 1.8, 'DisplayName', 'Decrypted');
        hErr = animatedline(app.axErr, 'Color', C.lilac, 'LineWidth', 1.8);

        legend(app.axDec, 'Location', 'best');

        step = animation_step(numel(t));
        for k = 1:step:numel(t)
            idx = k:min(k+step-1, numel(t));
            addpoints(hIn, t(idx), V_in(idx));
            addpoints(hDec, t(idx), V_dec(idx));
            addpoints(hErr, t(idx), err(idx));
            drawnow limitrate;
        end
    end

    function setup_axis(ax, t, y)
        xlim(ax, [t(1), t(end)]);
        ymin = min(y);
        ymax = max(y);
        if ymin == ymax
            pad = max(1, abs(ymin))*0.1;
        else
            pad = 0.08*(ymax-ymin);
        end
        ylim(ax, [ymin-pad, ymax+pad]);
        grid(ax, 'on');
    end

    function n = animation_step(num_samples)
        n = max(1, floor(num_samples/220));
    end

    function set_status(lines)
        app.status.Value = lines;
        drawnow limitrate;
    end
end

function V = make_waveform(t, A, f, waveform)
    switch waveform
        case 'Sinusoidal'
            V = A*sin(2*pi*f*t);
        case 'Triangle'
            V = A*project_sawtooth(2*pi*f*t, 0.5);
        case 'Sawtooth'
            V = A*project_sawtooth(2*pi*f*t, 1.0);
        case 'Sum of sinusoids'
            V = 0.5*A*(sin(2*pi*f*t) + cos(2*pi*2*f*t));
        case 'Product of sinusoids'
            V = A*sin(2*pi*f*t).*cos(2*pi*2*f*t);
        otherwise
            error('Unknown waveform.');
    end
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

function x = parse_vector(txt)
    txt = strrep(txt, ',', ' ');
    txt = strrep(txt, ';', ' ');
    x = sscanf(txt, '%f').';
end

function x = resize_x0(x, n, default_value)
    if isempty(x)
        x = default_value * ones(1,n);
    elseif numel(x) < n
        x = [x(:).' default_value*ones(1,n-numel(x))];
    else
        x = x(1:n);
    end
end

function txt = vector_to_text(x)
    txt = strtrim(sprintf('%.4g ', x));
end

function C = local_palette()
    C.pink   = [0.89 0.47 0.64];
    C.blue   = [0.42 0.67 0.91];
    C.green  = [0.50 0.79 0.60];
    C.yellow = [0.93 0.78 0.36];
    C.lilac  = [0.70 0.60 0.90];
    C.peach  = [0.95 0.67 0.52];
    C.black  = [0.10 0.10 0.10];
end

function draw_network_topology(ax, branches, num_nodes, port_pos, port_neg, C)
    cla(ax);
    hold(ax, 'on');

    if isempty(branches) || size(branches,2) ~= 2 || num_nodes < 2
        text(ax, 0.5, 0.5, 'Invalid network', 'HorizontalAlignment', 'center');
        axis(ax, 'off');
        hold(ax, 'off');
        return;
    end

    if num_nodes == 4
        coords = [
            0 1;
            1 1;
            1 0;
            0 0
        ];
    else
        theta = linspace(0, 2*pi, num_nodes+1);
        theta(end) = [];
        coords = [cos(theta(:)), sin(theta(:))];
    end

    branch_pairs = sort(branches,2);

    for m = 1:size(branches,1)
        a = branches(m,1);
        b = branches(m,2);

        if a < 1 || b < 1 || a > num_nodes || b > num_nodes
            continue;
        end

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

        plot(ax, [xa_plot xb_plot], [ya_plot yb_plot], ...
            '-', 'Color', branch_color, 'LineWidth', 2.0);

        xm = (xa_plot + xb_plot)/2;
        ym = (ya_plot + yb_plot)/2;
        text(ax, xm, ym, sprintf('M%d',m), ...
            'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'middle', ...
            'BackgroundColor', 'w', ...
            'Margin', 2, ...
            'Color', C.black, ...
            'FontSize', 11);
    end

    scatter(ax, coords(:,1), coords(:,2), 95, ...
        'MarkerFaceColor', C.pink, ...
        'MarkerEdgeColor', C.black, ...
        'LineWidth', 1.1);

    for n = 1:num_nodes
        text(ax, coords(n,1), coords(n,2)+0.09, sprintf('%d',n), ...
            'HorizontalAlignment', 'center', ...
            'Color', C.black, ...
            'FontWeight', 'bold');
    end

    text(ax, coords(port_pos,1), coords(port_pos,2)+0.22, '+ port', ...
        'HorizontalAlignment', 'center', ...
        'Color', C.green, ...
        'FontWeight', 'bold');
    text(ax, coords(port_neg,1), coords(port_neg,2)-0.22, '- port', ...
        'HorizontalAlignment', 'center', ...
        'Color', C.pink, ...
        'FontWeight', 'bold');

    axis(ax, 'equal');
    axis(ax, 'off');
    title(ax, 'Network topology');
    hold(ax, 'off');
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
