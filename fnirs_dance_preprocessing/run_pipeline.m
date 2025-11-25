function run_pipeline()
% RUN_PIPELINE  Demo fNIRS/HD-DOT preprocessing + GLM pipeline.
%
%   RUN_PIPELINE simulates an fNIRS session for an observation vs
%   execution dance task, performs preprocessing (GVTD, OD conversion,
%   filtering, short-channel regression), runs some QC, fits a per-channel
%   GLM, and generates activation + subtraction maps.
%
%   All output figures are written into the ./figures directory.

    % Add src folder to path
    thisDir = fileparts(mfilename('fullpath'));
    addpath(fullfile(thisDir, 'src'));

    % Output directory
    figDir = fullfile(thisDir, 'figures');
    if ~exist(figDir, 'dir')
        mkdir(figDir);
    end

    %% 1) Simulate session
    cfg = struct();
    cfg.fs             = 9.1;     % sampling rate (Hz)
    cfg.duration       = 600;     % seconds
    cfg.n_long         = 48;      % long-separation channels
    cfg.n_short        = 16;      % short-separation channels
    cfg.block_length   = 20;      % seconds
    cfg.rest_length    = 10;      % seconds
    cfg.n_blocks_per_cond = 6;    % per condition
    cfg.condition_names = {'obs_human', 'exec_human', 'exec_ai'};

    sim = simulate_fnirs_session(cfg);

    %% 2) Raw QC: light levels + simple SNR
    qc_light_and_snr(sim, figDir);

    %% 3) Motion detection with GVTD
    gvtd = compute_gvtd(sim);
    plot_gvtd_and_traces(sim, gvtd, figDir);

    %% 4) Convert to optical density
    od = convert_to_od(sim);

    %% 5) Bandpass filtering
    od_filt = bandpass_filter_fnirs(od, [0.01 0.5]);

    %% 6) Short-channel regression
    od_clean = short_channel_regression(od_filt, sim);

    %% 7) Build design matrix and run GLM (using "oxy-like" 850 nm)
    X = build_design_matrix(sim);
    betas = run_glm_per_channel(od_clean, X, sim);

    %% 8) Activation maps and subtraction maps
    make_activation_map(betas, sim, 'exec_human', figDir);
    make_activation_map(betas, sim, 'obs_human', figDir);
    make_activation_map(betas, sim, 'exec_ai', figDir);

    make_subtraction_map(betas, sim, 'exec_human', 'obs_human', figDir);
    make_subtraction_map(betas, sim, 'exec_human', 'exec_ai', figDir);

    %% 9) Post-preprocessing QC
    make_frequency_qc(od_clean, sim, figDir);
    make_variability_hist(od_clean, sim, figDir);
    make_postproc_time_traces(od, od_clean, sim, figDir);

    fprintf('\nPipeline complete. Figures saved in: %s\n\n', figDir);
end