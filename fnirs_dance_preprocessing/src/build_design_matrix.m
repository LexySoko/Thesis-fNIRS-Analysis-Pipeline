function X = build_design_matrix(sim)
% BUILD_DESIGN_MATRIX  Build block design regressors for each condition.
%
%   X = BUILD_DESIGN_MATRIX(SIM) returns a [T x K] design matrix, where
%   T = length(sim.time) and K = number of task conditions (one regressor
%   per condition). A constant intercept term is *not* included here.

    t = sim.time;
    fs = sim.fs;
    T = numel(t);

    cond_names = sim.condition_names;
    n_cond = numel(cond_names);

    X = zeros(T, n_cond);

    % Canonical HRF-like kernel (same as in simulation)
    t_hrf = (0:1/fs:20)';
    k = gampdf(t_hrf, 6, 1) - 0.5 * gampdf(t_hrf, 12, 1);
    k = k - min(k);
    k = k / max(k);

    for c = 1:n_cond
        name = cond_names{c};
        info = sim.conditions.(name);

        box = zeros(T, 1);
        for i = 1:numel(info.onsets)
            onset = info.onsets(i);
            dur   = info.durations(i);
            box = box + double(t >= onset & t < onset + dur);
        end

        conv_sig = conv(box, k, 'full');
        conv_sig = conv_sig(1:T);
        X(:, c) = conv_sig;
    end
end
