function betas = run_glm_per_channel(od_clean, X, sim)
% RUN_GLM_PER_CHANNEL  Fit GLM to each channel.
%
%   BETAS = RUN_GLM_PER_CHANNEL(OD_CLEAN, X, SIM) takes the cleaned
%   optical density, a design matrix X (T x K), and returns a struct:
%
%       betas.values   - [Nchan x K] beta weights (using 850 nm channel)
%       betas.design_names - cellstr of condition names
%
%   For simplicity, we treat the 850 nm channel as an "oxy-like" measure.

    lambdas = sim.wavelengths;
    [~, idx850] = min(abs(lambdas - 850));

    Y = od_clean(:, :, idx850);   % [T x Nchan]
    [T, Nchan] = size(Y);
    [T2, K] = size(X); %#ok<ASGLU>
    if T2 ~= T
        error('Time dimension mismatch between OD and design matrix.');
    end

    % Add intercept
    Xfull = [X, ones(T,1)];
    Kfull = size(Xfull, 2);

    beta_vals = zeros(Nchan, Kfull);

    for ch = 1:Nchan
        y = Y(:, ch);
        beta_vals(ch, :) = Xfull \ y;
    end

    betas.values = beta_vals(:, 1:K);
    betas.intercept = beta_vals(:, end);
    betas.design_names = sim.condition_names;
end