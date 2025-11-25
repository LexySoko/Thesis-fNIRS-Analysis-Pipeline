function make_frequency_qc(od_clean, sim, outDir)
% MAKE_FREQUENCY_QC  Plot frequency spectra for a few channels.
%
%   MAKE_FREQUENCY_QC(OD_CLEAN, SIM, OUTDIR) computes power spectra for a
%   subset of channels and shows the cardiac peak around 1 Hz.

    lambdas = sim.wavelengths;
    [~, idx850] = min(abs(lambdas - 850));
    Y = od_clean(:, :, idx850);   % [T x Nchan]
    [T, Nchan] = size(Y);
    fs = sim.fs;

    nShow = min(4, Nchan);
    chans = 1:nShow;

    f = figure('Color', 'w');
    hold on;

    for i = 1:numel(chans)
        ch = chans(i);
        y = Y(:, ch) - mean(Y(:, ch));
        NFFT = 2^nextpow2(T);
        Yf = fft(y, NFFT);
        P = abs(Yf / T).^2;
        freq = fs*(0:(NFFT/2))/NFFT;
        P1 = P(1:NFFT/2+1);

        plot(freq, P1);
    end

    xlim([0 2]);
    xlabel('Frequency (Hz)');
    ylabel('Power');
    title('Frequency spectra (example channels, cleaned)');
    box off;

    saveas(f, fullfile(outDir, 'qc_frequency_spectra.png'));
end