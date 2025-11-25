function make_activation_map(betas, sim, cond_name, outDir)
% MAKE_ACTIVATION_MAP  Scatter-plot activation map for one condition.
%
%   MAKE_ACTIVATION_MAP(BETAS, SIM, COND_NAME, OUTDIR) takes the GLM
%   BETAS struct, picks the column for COND_NAME, and plots it over the
%   channel layout.

    idx = find(strcmp(betas.design_names, cond_name), 1);
    if isempty(idx)
        error('Condition %s not found in betas.design_names.', cond_name);
    end

    vals = betas.values(:, idx);
    pos  = sim.sd_pos;

    f = figure('Color', 'w');
    scatter(pos(:,1), pos(:,2), 80, vals, 'filled');
    axis equal; box off;
    colorbar;
    title(sprintf('Activation map: %s (beta)', cond_name), 'Interpreter', 'none');
    xlabel('x'); ylabel('y');

    fname = sprintf('activation_%s.png', cond_name);
    saveas(f, fullfile(outDir, fname));
end