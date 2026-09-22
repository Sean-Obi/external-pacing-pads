# Simulation

Three MATLAB scripts that model current flow under the pacing pads on a 2D sagittal thorax slice. They follow the finite-element approach of Krasteva & Papazov (2002) and solve −∇·(σ∇V) = 0 with the PDE Toolbox.

---

## Run

- **MATLAB:** set the working folder to `simulation/`, then run a script by name from the Command Window:
  ```matlab
  perforatedElectrodeNSGA2
  ringElectrodeSimulation
  sweepBackPadLength_only
  ```
- **Batch (command line):**
  ```bash
  matlab -batch "cd simulation; ringElectrodeSimulation"
  ```

Needs the **PDE**, **Global Optimization** and **Statistics and Machine Learning** toolboxes.

---

## Scripts

| Script | What it does | Output |
|---|---|---|
| `perforatedElectrodeNSGA2.m` | NSGA-II over hole radius, holes/side and r<sub>perf</sub>. Minimises K and peak tissue \|J\| | `nsga2_perforated_results.mat` + 6 figures |
| `ringElectrodeSimulation.m` | Eight-ring layout, 16 holes in the cross-section. Sweeps hole diameter 0.1–2.0 mm | `ring_electrode_results.mat` + 6 figures |
| `sweepBackPadLength_only.m` | Back pad 60–240 mm, front fixed at 100 mm. Uses a continuous impedance model instead of resolved holes | 5 figures |

---

## Parameters

| Constant | Value | Meaning |
|---|---|---|
| `domainWidth` × `domainHeight` | 0.50 × 0.25 m | Thorax slice |
| `heartRadius` / `heartZ` | 45 mm / 95 mm | Cardiac inclusion |
| `sigma_tissue` / `sigma_heart` | 0.2 / 0.5 S/m | Bulk tissue / heart |
| `padWidth` / `d` | 100 mm / 1 mm | Electrode width / thickness |
| `rho_metal` | 5 Ω | Ag/AgCl surface resistivity (σ = d/(ρd) = 0.2 S/m) |
| `sigma_hole` | 1e-8 S/m | Perforation (insulating) |
| `Vapp` | 10 V | Active electrode potential |
| `popSize` / `maxGen` | 60 / 40 | NSGA-II population / generations |
| Crossover / Pareto fraction | 0.80 / 0.35 | `gamultiobj` options |
| Coarse mesh | Hmax 2.0 mm, Hmin 0.5 mm | Used during optimisation |
| Fine mesh | Hmax 1.2 mm, Hmin 0.3 mm | Final re-solves and ring sweep |

### Design variables

| Variable | Range | Notes |
|---|---|---|
| Hole radius | 0.2–2.5 mm | Capped at 40% of the hole spacing to prevent overlap |
| Holes per side | 2–30 | Integer-constrained (`intcon = 2`) |
| r<sub>perf</sub> | 5–45 mm | Radius of the solid centre; holes run from here to the edge |

---

## Metrics

- **K = J<sub>max</sub>/J<sub>min</sub>** along a horizontal line 0.5 mm below the electrode–tissue interface, across the pad width.
- **Peak \|J\|:** maximum over bulk tissue, excluding the heart and both electrode layers.
- **Edge hotspot** (back-pad sweep only): 95th percentile of \|J\| within a 3 mm strip at each pad edge, near the skin.
- **Heart-wall \|J\|** (back-pad sweep only): mean over a 5 mm shell just inside the cardiac inclusion.

Failed or NaN evaluations return `[100, 100]`, and anything above 50 is filtered out before plotting.

---

## Known issues

These are in the code as submitted and are left unfixed so the code matches the report.

1. **The back-pad sweep can't run on its own.** It calls `buildThoraxModelWithInterface`, `dirichletBoundaryConditions` and `solveDirichletProblem`, which weren't in the report appendix. They need to be added here.
2. **The back-pad sweep uses different physics.** It has tissue σ = 0.3 S/m, heart σ = 0.7 S/m, a 90 mm heart radius centred 140 mm deep, and a 5 V drive. The Methods section states 0.2 / 0.5 S/m, 45 mm and 10 V. Its K values aren't comparable with the other scripts.
3. **Baselines differ between scripts.** Mesh resolution differs, so the solid-pad K is 2.56 in the optimisation and 2.82 in the ring sweep.
4. **Both pads are perforated in the model.** `condCoeff` applies the same `inHole()` test to the top and bottom electrodes, with hole positions centred on `pad1X`. This only lines up because both pads sit at the same x position.
5. **`JAtProbe` is computed but never used** in any objective or figure.
6. **The code was recovered from the PDF appendix.** It has been re-indented and checked for block balance, but hasn't been re-run since extraction.
