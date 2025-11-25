function od_filt = bandpass_filter_fnirs(od, passband)
% BANDPASS_FILTER_FNIRS  Simple bandpass filtering of OD.
%
%   OD_FILT = BANDPASS_FILTER_FNIRS(OD, [F_LO F_HI]) applies a 2nd-order
%   Butterworth bandpass filter (zero-phase) along the time dimension.

    if numel(passband) ~= 2
        error('passband must be [f_lo f_hi] in Hz.');
    end
    f_lo = passband(1);
    f_hi = passband(2);

    % Infer sampling rate from time dimension step if stored; otherwise
    % assume 9.1 Hz. For simplicity we expect the caller to know fs.
    % Here we hack: store fs in a persistent between calls if needed.
    % For this repo, we just set fs in run_pipeline and keep consistent.
    fs = 9.1;   % This should match cfg.fs in simulate_fnirs_session.

    [b, a] = butter(2, [f_lo f_hi] / (fs/2), 'bandpass');

    [T, Nchan, Nlambda] = size(od);
    od_filt = zeros(size(od));

    for ch = 1:Nchan
        for lam = 1:Nlambda
            sig = od(:, ch, lam);
            od_filt(:, ch, lam) = filtfilt(b, a, sig);
        end
    end
end
