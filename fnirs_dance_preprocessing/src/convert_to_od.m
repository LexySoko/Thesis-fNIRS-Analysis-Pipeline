
function od = convert_to_od(sim)
% CONVERT_TO_OD  Convert intensity to optical density.
%
%   OD = CONVERT_TO_OD(SIM) converts SIM.intensity (T x Nchan x Nlambda)
%   to relative optical density using OD = -log10(I / I0), where I0 is
%   taken as the median intensity over time for each channel/wavelength.

    I = sim.intensity;
    [T, Nchan, Nlambda] = size(I);

    od = zeros(size(I));
    for ch = 1:Nchan
        for lam = 1:Nlambda
            sig = I(:, ch, lam);
            I0  = median(sig);
            od(:, ch, lam) = -log10(sig / I0);
        end
    end
end

