function qc_light_and_snr(sim, outDir)
% QC_LIGHT_AND_SNR  Simple light level and SNR-style summaries.
%
%   QC_LIGHT_AND_SNR(SIM, OUTDIR) plots mean intensity and a crude SNR
%   metric per channel and saves figures into OUTDIR.

    I = sim.intensity;              % [T x Nchan x Nlambda]
    t = sim.time;
    pos = sim.sd_pos;

    [T, Nchan, Nlambda] = size(I); %#ok<ASGLU>
    lambdas = sim.wavelengths;

    meanI = squeeze(mean(I, 1));    % [Nchan x Nlambda]
    stdI  = squeeze(std(I, 0, 1));  % [Nchan x Nlambda]
    snr   = meanI ./ stdI;          % crude SNR

    % Mean intensity map (use 850 nm)
    [~, idx850] = min(abs(lambdas - 850));
    mean850 = meanI(:, idx850);

    f1 = figure('Color', 'w');
    scatter(pos(:,1), pos(:,2), 80, mean850, 'filled');
    colorbar;
    title('Mean intensity (850 nm)');
    xlabel('x'); ylabel('y');
    axis equal; box off;
    saveas(f1, fullfile(outDir, 'qc_mean_intensity_850.png'));

    % SNR vs source-detector distance
    snr850 = snr(:, idx850);
    f2 = figure('Color', 'w');
    scatter(sim.sd_distance, snr850, 60, 'filled');
    xlabel('Source-detector distance (mm)');
    ylabel('Mean/STD (850 nm)');
    title('Crude SNR vs distance');
    box off;
    saveas(f2, fullfile(outDir, 'qc_snr_vs_distance.png'));

    % Example time trace for a few channels
    chans = 1:min(6, Nchan);
    f3 = figure('Color', 'w');
    offset = 0;
    hold on;
    for i = 1:numel(chans)
        ch = chans(i);
        plot(t, squeeze(I(:, ch, idx850)) + offset, 'LineWidth', 1);
        offset = offset + 2;
    end
    xlabel('Time (s)');
    ylabel('Intensity (offset per channel)');
    title('Example raw intensity traces (850 nm)');
    box off;
    saveas(f3, fullfile(outDir, 'qc_example_time_traces_raw.png'));
end
