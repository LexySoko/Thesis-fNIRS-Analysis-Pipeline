function make_subtraction_map(betas, sim, condA, condB, outDir)
% MAKE_SUBTRACTION_MAP  Map of beta(condA) - beta(condB).
%
%   MAKE_SUBTRACTION_MAP(BETAS, SIM, CONDA, CONDB, OUTDIR) computes the
%   difference in beta weights between two conditions and plots the result.

    idxA = find(strcmp(betas.design_names, condA), 1);
    idxB = find(strcmp(betas.design_names, condB), 1);

    if isempty(idxA) || isempty(idxB)
        error('Conditions not found in betas.design_names.');
    end

    vals = betas.values(:, idxA) - betas.values(:, idxB);
    pos  = sim.sd_pos;

    f = figure('Color', 'w');
    scatter(pos(:,1), pos(:,2), 80, vals, 'filled');
    axis equal; box off;
    colorbar;
    title(sprintf('Subtraction map: %s - %s', condA, condB), ...
        'Interpreter', 'none');
    xlabel('x'); ylabel('y');

    fname = sprintf('subtraction_%s_minus_%s.png', condA, condB);
    fname = strrep(fname, ' ', '_');
    saveas(f, fullfile(outDir, fname));
end
