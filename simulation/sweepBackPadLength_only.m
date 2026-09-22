function sweepBackPadLength_only()
    % Sweeps back pad length (bottom electrode width) while holding front pad
    % constant at 10 cm. Outputs: JedgeMetric, Jheart, Reff, K, Itotal.
    % Fixed parameters
    rhoCenter = 20;
    d = 0.001;
    Vapp = 5;
    pad1X = 0.25;
    pad2X = 0.25;
    rhoRing = 200;
    ringW = 0.004;
    padWFront = 0.10;
    padWBackVals = [0.06 0.08 0.10 0.12 0.14 0.16 0.20 0.24];
    % Domain and tissue configuration
    cfg = struct();
    cfg.domainWidth = 0.50;
    cfg.domainThickness = 0.25;
    cfg.heartRadius = 0.09;
    cfg.heartCenter = struct('x', 0.25, 'z', 0.05 + 0.09);
    cfg.tissueConductivity = 0.3;
    cfg.heartConductivity = 0.7;
    cfg.meshMaxSize = 0.001;
    gridParams = struct();
    gridParams.xRange = [0 cfg.domainWidth];
    gridParams.zRange = [0 cfg.domainThickness];
    gridParams.resX = 220;
    gridParams.resZ = 120;
    % Metric parameters
    delta = 0.0005;
    edgePercentile = 95;
    heartWallThickness = 0.005;
    skinZBand = 0.002;
    edgeStripW = 0.003;
    % Storage
    nP = numel(padWBackVals);
    JedgeMetric = nan(nP,1);
    Jheart = nan(nP,1);
    Reff = nan(nP,1);
    Kvals = nan(nP,1);
    Itotal = nan(nP,1);
    zCenter = rhoCenter * d;
    zRing = rhoRing * d;
    if ringW >= padWFront/2
        error('Front pad fixed at %.1f mm but ringW >= padWFront/2 (ringW=%.2f mm).', ...
            padWFront*1e3, ringW*1e3);
    end
    fprintf('\nSweeping back pad width. Front pad held at %.1f mm, rhoRing=%g Ohm*m, ringW=%.2f mm\n\n', ...
        padWFront*1e3, rhoRing, ringW*1e3);
    for p = 1:nP
        padWBack = padWBackVals(p);
        if ringW >= padWBack/2
            warning('Skipping back padW=%.1f mm: ringW >= padWBack/2.', padWBack*1e3);
            continue;
        end
        rThresholdBack = padWBack/2 - ringW;
        rThresholdFront = padWFront/2 - ringW;
        impedanceBack = @(r) zCenter + (zRing - zCenter) .* 0.5 .* (1 + tanh((r - rThresholdBack) ./ delta));
        impedanceFront = @(r) zCenter + (zRing - zCenter) .* 0.5 .* (1 + tanh((r - rThresholdFront) ./ delta));
        % Bottom/back electrode (0 V, swept width)
        elec1 = struct();
        elec1.position = pad1X;
        elec1.width = padWBack;
        elec1.edge = 'bottom';
        elec1.voltage = 0;
        elec1.interfaceThickness = d;
        elec1.impedanceFunc = impedanceBack;
        % Top/front electrode (Vapp, fixed width)
        elec2 = struct();
        elec2.position = pad2X;
        elec2.width = padWFront;
        elec2.edge = 'top';
        elec2.voltage = Vapp;
        elec2.interfaceThickness = d;
        elec2.impedanceFunc = impedanceFront;
        cfg.electrode1 = elec1;
        cfg.electrode2 = elec2;
        [model, geom] = buildThoraxModelWithInterface(cfg);
        dirichletBoundaryConditions(model, geom);
        out = solveDirichletProblem(model, geom, gridParams);
        X = out.gridX;
        Z = out.gridZ;
        J = out.JGrid;
        JedgeMetric(p) = edgeHotspotFromGrid(X, Z, J, pad1X, pad2X, padWBack, padWFront, skinZBand, edgeStripW, edgePercentile);
        Jheart(p) = heartWallMeanFromGrid(X, Z, J, cfg.heartCenter.x, cfg.heartCenter.z, cfg.heartRadius, heartWallThickness);
        Itotal(p) = out.totalCurrent;
        Reff(p) = out.effectiveResistance;
        Kvals(p) = out.nonUniformityCoeff;
        fprintf('backPadW=%.1fmm: Jedge(p%d)=%.4g, Jheart=%.4g, Itotal=%.4g, Reff=%.4g, K=%.4g\n', ...
            padWBack*1e3, edgePercentile, JedgeMetric(p), Jheart(p), Itotal(p), Reff(p), Kvals(p));
    end
    % Plotting
    set(groot, 'defaultAxesFontName', 'Arial');
    set(groot, 'defaultAxesFontSize', 12);
    set(groot, 'defaultLineLineWidth', 2);
    set(groot, 'defaultFigureColor', 'w');
    xmm = padWBackVals * 1e3;
    ftitle = sprintf('(Front = %.0f mm)', padWFront*1e3);
    plotSweep(xmm, JedgeMetric, 'Back Pad Length (mm)', sprintf('Edge Hotspot |J| (p%d)', edgePercentile), ...
        ['Edge Hotspot vs Back Pad Length ' ftitle], [0 0.45 0.74]);
    plotSweep(xmm, Jheart, 'Back Pad Length (mm)', 'Mean |J| on Heart Wall', ...
        ['Heart Wall Mean Current Density ' ftitle], [0.85 0.33 0.1]);
    plotSweep(xmm, Itotal, 'Back Pad Length (mm)', 'Total Current (A)', ...
        ['Total Current vs Back Pad Length ' ftitle], [0.47 0.67 0.19]);
    plotSweep(xmm, Reff, 'Back Pad Length (mm)', 'Effective Resistance (Ohms)', ...
        ['Effective Resistance vs Back Pad Length ' ftitle], [0.49 0.18 0.56]);
    plotSweep(xmm, Kvals, 'Back Pad Length (mm)', 'Non-Uniformity Coefficient', ...
        ['Non-Uniformity vs Back Pad Length ' ftitle], [0.3 0.3 0.3]);
end

function plotSweep(x, y, xlab, ylab, ttl, color)
    figure('Color', 'w');
    plot(x, y, 'o-', 'MarkerSize', 6, 'MarkerFaceColor', color);
    box on; grid off;
    xlabel(xlab, 'FontWeight', 'bold');
    ylabel(ylab, 'FontWeight', 'bold');
    title(ttl, 'FontWeight', 'bold');
    set(gca, 'LineWidth', 1.2);
end

function Jm = edgeHotspotFromGrid(X, Z, J, pad1X, pad2X, padW1, padW2, skinZBand, edgeStripW, pctl)
    % Returns percentile edge hotspot |J| sampled near pad edges on skin boundaries.
    if isempty(X) || isempty(Z) || isempty(J)
        Jm = NaN;
        warning('Empty grid arrays for edge metric.');
        return;
    end
    Jmag = abs(J);
    zMin = min(Z(:));
    zMax = max(Z(:));
    onBottom = abs(Z - zMin) <= skinZBand;
    onTop = abs(Z - zMax) <= skinZBand;
    x1L = pad1X - padW1/2; x1R = pad1X + padW1/2;
    x2L = pad2X - padW2/2; x2R = pad2X + padW2/2;
    inPad1 = (X >= x1L) & (X <= x1R);
    inPad2 = (X >= x2L) & (X <= x2R);
    edge1 = (abs(X - x1L) <= edgeStripW) | (abs(X - x1R) <= edgeStripW);
    edge2 = (abs(X - x2L) <= edgeStripW) | (abs(X - x2R) <= edgeStripW);
    samples = [ Jmag(onBottom & inPad1 & edge1); ...
        Jmag(onTop & inPad2 & edge2) ];
    samples = samples(isfinite(samples));
    if isempty(samples)
        Jm = NaN;
        warning('No edge samples found. Try increasing skinZBand or edgeStripW.');
        return;
    end
    Jm = prctile(samples, pctl);
end

function Jh = heartWallMeanFromGrid(X, Z, J, hx, hz, R, t)
    % Returns mean |J| over the heart wall annulus: R-t <= r <= R.
    if isempty(X) || isempty(Z) || isempty(J)
        Jh = NaN;
        warning('Empty grid arrays for heart metric.');
        return;
    end
    r = sqrt((X - hx).^2 + (Z - hz).^2);
    vals = abs(J((r >= R - t) & (r <= R)));
    vals = vals(isfinite(vals));
    if isempty(vals)
        Jh = NaN;
        warning('No heart-wall samples found. Check heartCenter/heartRadius vs domain/grid.');
        return;
    end
    Jh = mean(vals);
end
