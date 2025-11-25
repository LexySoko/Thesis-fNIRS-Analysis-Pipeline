function sig_out = add_motion_artifacts(sig, t, cond)
% ADD_MOTION_ARTIFACTS  Inject simple motion spikes into a time series.
%
%   SIG_OUT = ADD_MOTION_ARTIFACTS(SIG, T, COND) adds abrupt spikes to the
%   signal SIG during the blocks specified in COND.
%
%   Inputs
%   ------
%   sig  : [T x 1] original signal
%   t    : [T x 1] time vector (seconds)
%   cond : struct with fields:
%          - onsets    : [nBlocks x 1] onset times (seconds)
%          - durations : [nBlocks x 1] block durations (seconds)
%
%   Output
%   ------
%   sig_out : [T x 1] signal with injected motion artifacts

    sig_out = sig;

    if isempty(cond.onsets)
        return;
    end

    for i = 1:numel(cond.onsets)
        onset = cond.onsets(i);
        dur   = cond.durations(i);

        mask = t >= onset & t < onset + dur;
        idx = find(mask);

        if numel(idx) < 5
            continue;
        end

        % Choose a few random spike locations within this block
        n_spikes = 3;
        spike_idx = idx(randi(numel(idx), n_spikes, 1));

        for s = 1:numel(spike_idx)
            k = spike_idx(s);
            sig_out(k) = sig_out(k) + 2.5 * randn; % abrupt jump
        end
    end
end