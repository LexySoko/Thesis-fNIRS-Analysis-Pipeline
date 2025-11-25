function make_variability_hist(od_clean, sim, outDir)
% MAKE_VARIABILITY_HIST  Histogram of measurement variability.
%
%   MAKE_VARIABILITY_HIST(OD_CLEAN, SIM, OUTDIR) computes a per-channel
%   standard deviation (relative to mean) and plots a histogram.

    lambdas = sim.wavelengths;
    [~, idx850] = min(abs(lambdas - 850));
    Y = od_clean(:, :, idx850);   % [T x Nchan]

    mu = mean(Y, 1);
    sd = std(Y, 0, 1);

    rel_sd = 100 * (sd ./ abs(mu));   % percent variability

    f = figure('Color', 'w');
    histogram(rel_sd, 20);
    xlabel('Relative SD (% of mean)');
    ylabel('Number of channels');
    title('Histogram of channel variability (cleaned)');
    box off;

    saveas(f, fullfile(outDir, 'qc_variability_hist.png'));
end
