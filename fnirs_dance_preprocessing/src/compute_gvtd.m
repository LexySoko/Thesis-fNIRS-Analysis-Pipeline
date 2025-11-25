function gvtd = compute_gvtd(sim)
% COMPUTE_GVTD  Global variance of the temporal derivative.
%
%   GVTD = COMPUTE_GVTD(SIM) computes the GVTD using all channels and
%   wavelengths. Output is a [T-1 x 1] vector corresponding to time
%   differences between consecutive samples.

    I = sim.intensity;       % [T x Nchan x Nlambda]
    [T, Nchan, Nlambda] = size(I); %#ok<ASGLU>

    % Flatten channels x wavelengths
    data = reshape(I, T, Nchan*Nlambda);

    % Temporal derivative
    d = diff(data, 1, 1);    % [T-1 x Nc]

    % Variance across measurements at each time step
    gvtd = sqrt(mean(d.^2, 2));    % [T-1 x 1]
end