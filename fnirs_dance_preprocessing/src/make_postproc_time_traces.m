function make_postproc_time_traces(od_raw, od_clean, sim, outDir)
% MAKE_POSTPROC_TIME_TRACES  Compare raw vs cleaned OD time traces.
%
%   MAKE_POSTPROC_TIME_TRACES(OD_RAW, OD_CLEAN, SIM, OUTDIR) overlays raw
%   and cleaned traces for a few example channels.

    lambdas = sim.wavelengths;
    [~, idx850] = min(abs(lambdas - 850));

    Yraw   = od_raw(:, :, idx850);
    Yclean = od_clean(:, :, idx850);
    t = sim.time;
    [T, Nchan] = size(Yraw); %#ok<ASGLU>

    nShow = min(4, Nchan);
    chans = 1:nShow;

    f = figure('Color', 'w');
    for i = 1:numel(chans)
        ch = chans(i);

        subplot(nShow,1,i);
        plot(t, Yraw(:, ch), 'Color', [0.7 0.7 0.7]);
        hold on;
        plot(t, Yclean(:, ch), 'b', 'LineWidth', 1.2);
        xlabel('Time (s)');
        ylabel('OD');
        title(sprintf('Channel %d: raw vs cleaned', ch));
        box off;
        legend({'Raw', 'Cleaned'}, 'Location', 'best');
    end

    saveas(f, fullfile(outDir, 'qc_postproc_time_traces.png'));
end

