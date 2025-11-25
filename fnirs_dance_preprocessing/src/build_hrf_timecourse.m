function h = build_hrf_timecourse(t, cond)
% BUILD_HRF_TIMECOURSE  Build a simple block-based hemodynamic response.
%
%   H = BUILD_HRF_TIMECOURSE(T, COND) returns a timecourse H (same length
%   as T) constructed by convolving a boxcar for each block with a simple
%   gamma-like HRF kernel.
%
%   Inputs
%   ------
%   t    : [T x 1] time vector (seconds)
%   cond : struct with fields:
%          - onsets    : [nBlocks x 1] onset times (seconds)
%          - durations : [nBlocks x 1] block durations (seconds)
%
%   Output
%   ------
%   h    : [T x 1] hemodynamic response timecourse

    h = zeros(size(t));
    onsets = cond.onsets;
    durs   = cond.durations;

    if isempty(onsets)
        return;
    end

    % Simple gamma-like kernel (peaks around ~5 s, length ~20 s)
    t_hrf = (0:0.5:20)';  % coarse time grid for HRF
    k = gampdf(t_hrf, 6, 1) - 0.5 * gampdf(t_hrf, 12, 1);
    k = k - min(k);
    k = k / max(k);

    for i = 1:numel(onsets)
        onset = onsets(i);
        dur   = durs(i);

        % Boxcar for this block
        box = double(t >= onset & t < onset + dur);

        % Convolve and trim to length(t)
        conv_sig = conv(box, k, 'full');
        conv_sig = conv_sig(1:numel(t));

        h = h + conv_sig;
    end
end