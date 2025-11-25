function sim = simulate_fnirs_session(cfg)
% SIMULATE_FNIRS_SESSION  Simulate block-design fNIRS session.
%
%   SIM = SIMULATE_FNIRS_SESSION(CFG) creates a simple synthetic fNIRS /
%   HD-DOT dataset with long- and short-separation channels, cardiac and
%   low-frequency components, motion artifacts, and task-locked responses.
%
%   Required fields in CFG:
%       fs              - sampling rate (Hz)
%       duration        - total duration (s)
%       n_long          - number of long-separation channels
%       n_short         - number of short-separation channels
%       block_length    - block duration for each task (s)
%       rest_length     - rest duration between blocks (s)
%       n_blocks_per_cond - number of blocks per condition
%       condition_names - cell array of condition labels
%
%   Outputs in SIM:
%       intensity       - [T x Nchan x 2] intensity at 735 and 850 nm
%       fs, time        - sampling rate and time vector
%       wavelengths     - [735 850]
%       is_short        - [Nchan x 1] logical (true for short-sep)
%       sd_pos          - [Nchan x 2] positions for plotting
%       sd_distance     - [Nchan x 1] mm (simulated)
%       conditions      - struct with fields{cond}.onsets, .durations (sec)
%       condition_names - as in cfg

    rng(1); % reproducibility

    fs       = cfg.fs;
    duration = cfg.duration;
    t        = (0:1/fs:duration-1/fs)';
    T        = numel(t);

    n_long   = cfg.n_long;
    n_short  = cfg.n_short;
    n_chan   = n_long + n_short;

    wavelengths = [735 850];
    n_lambda    = numel(wavelengths);

    % Layout: arrange channels on a grid for plotting
    n_cols = ceil(sqrt(n_chan));
    n_rows = ceil(n_chan / n_cols);
    [xx, yy] = meshgrid(1:n_cols, 1:n_rows);
    pos = [xx(:), yy(:)];
    pos = pos(1:n_chan, :);

    % Mark last n_short channels as short-separation
    is_short = false(n_chan, 1);
    is_short(end-n_short+1:end) = true;

    % Assign crude source-detector distances
    sd_distance = 8 * ones(n_chan, 1);         % mm
    sd_distance(~is_short) = 30 + 10*rand(sum(~is_short), 1);

    %-------------------- Block design ---------------------%
    cond_names = cfg.condition_names;
    n_cond     = numel(cond_names);

    block_len  = cfg.block_length;
    rest_len   = cfg.rest_length;
    nBlocksPer = cfg.n_blocks_per_cond;

    conditions = struct();
    block_order = repelem(1:n_cond, nBlocksPer);
    block_order = block_order(randperm(numel(block_order))); % randomize

    t_cursor = 0;
    onset_list = cell(n_cond, 1);
    dur_list   = cell(n_cond, 1);

    for b = 1:numel(block_order)
        c = block_order(b);
        if t_cursor + block_len > duration
            break;
        end
        onset_list{c}(end+1,1) = t_cursor; %#ok<AGROW>
        dur_list{c}(end+1,1)   = block_len;
        t_cursor = t_cursor + block_len + rest_len;
    end

    for c = 1:n_cond
        conditions.(cond_names{c}).onsets    = onset_list{c};
        conditions.(cond_names{c}).durations = dur_list{c};
    end

    %-------------------- Intensity simulation ---------------------%
    intensity = zeros(T, n_chan, n_lambda);

    % Base intensities: long channels lower because more attenuation
    base_long  = 5 + randn(n_long, 1);
    base_short = 8 + randn(n_short, 1);
    base_all   = [base_long; base_short];

    % Basic components: drift + cardiac
    drift = 0.1 * sin(2*pi*0.005 * t);            % very slow drift
    cardiac = 0.2 * sin(2*pi*1.0 * t);            % ~1 Hz pulse

    % Condition-specific "hemodynamic" responses for a subset of channels
    active_channels = 1:round(n_long/3);  % pretend these are motor cortex

    hm = zeros(T, n_cond);
    for c = 1:n_cond
        hm(:, c) = build_hrf_timecourse(t, conditions.(cond_names{c}));
    end

    % We'll make execution blocks slightly stronger than observation
    exec_gain = 1.5;
    obs_gain  = 1.0;

    for ch = 1:n_chan
        for lamIdx = 1:n_lambda
            lam = wavelengths(lamIdx); %#ok<NASGU>

            sig = base_all(ch) + drift + cardiac;

            if ismember(ch, active_channels)
                % Add condition-specific activation
                obs = hm(:, strcmp(cond_names, 'obs_human')) * obs_gain;
                exH = hm(:, strcmp(cond_names, 'exec_human')) * exec_gain;
                exA = hm(:, strcmp(cond_names, 'exec_ai'))   * exec_gain*0.7;

                act = obs + exH + exA;
                sig = sig + 0.5*act;
            end

            % Add white noise
            sig = sig + 0.05 * randn(T, 1);

            % Inject motion artifacts into execution blocks for a subset
            if ~is_short(ch)
                sig = add_motion_artifacts(sig, t, conditions.exec_human);
            end

            % Ensure positive "intensity"
            sig = exp(sig/5);  % just to keep things >0, somewhat log-ish

            intensity(:, ch, lamIdx) = sig;
        end
    end

    % Package
    sim.intensity       = intensity;
    sim.fs              = fs;
    sim.time            = t;
    sim.wavelengths     = wavelengths;
    sim.is_short        = is_short;
    sim.sd_pos          = pos;
    sim.sd_distance     = sd_distance;
    sim.conditions      = conditions;
    sim.condition_names = cond_names;
end

