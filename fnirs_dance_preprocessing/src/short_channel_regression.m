function od_clean = short_channel_regression(od, sim)
% SHORT_CHANNEL_REGRESSION  Regress out short-channel signal.
%
%   OD_CLEAN = SHORT_CHANNEL_REGRESSION(OD, SIM) uses each long-separation
%   channel's nearest short-separation channel as a regressor and removes
%   that component from the long channel. Short channels are left
%   unchanged.
%
%   OD is [T x Nchan x Nlambda].

    [T, Nchan, Nlambda] = size(od); %#ok<ASGLU>

    is_short = sim.is_short(:);
    pos = sim.sd_pos;

    long_idx  = find(~is_short);
    short_idx = find(is_short);

    od_clean = od;

    if isempty(short_idx)
        warning('No short channels found; returning original OD.');
        return;
    end

    % Precompute nearest short channel for each long channel
    nearest_short = zeros(numel(long_idx), 1);
    for i = 1:numel(long_idx)
        ch = long_idx(i);
        dists = sqrt(sum((pos(short_idx, :) - pos(ch, :)).^2, 2));
        [~, k] = min(dists);
        nearest_short(i) = short_idx(k);
    end

    for lam = 1:Nlambda
        sig = od(:, :, lam);  % [T x Nchan]

        for i = 1:numel(long_idx)
            ch_long  = long_idx(i);
            ch_short = nearest_short(i);

            y = sig(:, ch_long);
            x = sig(:, ch_short);

            % Add intercept
            X = [x, ones(T,1)];
            beta = X \ y;
            y_hat = X * beta;

            sig(:, ch_long) = y - y_hat;  % residual
        end

        od_clean(:, :, lam) = sig;
    end
end