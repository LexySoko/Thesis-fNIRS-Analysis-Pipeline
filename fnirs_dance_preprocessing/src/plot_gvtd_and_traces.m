function plot_gvtd_and_traces(sim, gvtd, outDir)
% PLOT_GVTD_AND_TRACES  Plot GVTD and example raw traces.
%
%   PLOT_GVTD_AND_TRACES(SIM, GVTD, OUTDIR) creates a two-panel figure
%   with GVTD over time and a few raw intensity traces.

    t = sim.time;
    lambdas = sim.wavelengths;
    [~, idx850] = min(abs(lambdas - 850));

    I850 = sim.intensity(:, :, idx850);
    T = numel(t);

    f = figure('Color', 'w', 'Position', [100 100 800 600]);

    % GVTD
    subplot(2,1,1);
    plot(t(2:end), gvtd, 'LineWidth', 1.2);
    xlabel('Time (s)');
    ylabel('GVTD');
    title('Global variance of temporal derivative');
    box off;

    % Raw traces for a few channels
    subplot(2,1,2);
    hold on;
    nShow = min(8, size(I850, 2));
    offset = 0;
    for ch = 1:nShow
        plot(t, I850(:, ch) + offset, 'LineWidth', 1);
        offset = offset + 2;
    end
    xlabel('Time (s)');
    ylabel('Intensity (offset per channel)');
    title('Example raw intensity traces (850 nm)');
    box off;

    saveas(f, fullfile(outDir, 'gvtd_and_raw_traces.png'));
end