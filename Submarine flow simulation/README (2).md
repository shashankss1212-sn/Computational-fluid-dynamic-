# CFD Analysis — Drag Forces of a Submarine (USS Albacore)
**Tool:** StarCCM+ | **Institution:** Otto von Guericke Universität Magdeburg, LSS

---

## Overview

This project performs a steady-state RANS-based CFD simulation to compute the drag and lift coefficients of the USS Albacore submarine hull using StarCCM+. The drag coefficient is defined as:

$$C_D = \frac{F_x}{\frac{1}{2} \rho v^2 A}$$

where $F_x$ is the streamwise drag force, $\rho$ is the fluid density, $v$ is the free-stream velocity, and $A$ is the frontal projected area. By Galilean invariance, a stationary submarine with 1.5 m/s inflow is physically equivalent to a moving submarine in still water. A mesh sensitivity study is conducted across four base mesh sizes (2.0, 1.75, 1.5, 1.25 m) to assess convergence of the force coefficients.

---

## Geometry & Domain

| Parameter | Value |
|---|---|
| Geometry | USS Albacore (STL imported from grabcad.com) |
| Domain type | Rectangular block (virtual wind tunnel) |
| Domain Corner 1 | [−40, 0, −25] m |
| Domain Corner 2 | [100, 25, 25] m |
| Symmetry | Half-domain (symmetry plane at y = 0) |
| Frontal (projected) area | 30.25 m² |

The domain is sized to place the inlet 40 m upstream and the outlet 100 m downstream of the submarine, minimising boundary interference. A Surface Wrapper operation is used to produce a watertight, error-tolerant surface mesh prior to volume meshing.

---

## Flow Conditions

| Parameter | Value |
|---|---|
| Fluid | Water, ρ = 1000 kg/m³ |
| Inflow velocity | 1.5 m/s (x-direction) |
| Inlet BC | Velocity inlet |
| Outlet BC | Pressure outlet |
| Turbulence model | SST (Menter) k-ω |
| Wall treatment | All y+ |
| Solver | Steady, segregated, RANS |
| Initial condition | Uniform velocity [1.5, 0, 0] m/s |
| Stopping criterion | Continuity residual ≤ 4×10⁻⁵ |

The SST k-ω model is chosen for its good performance in adverse pressure gradient and near-wall flows, making it well suited to external hydrodynamic applications. The All y+ wall treatment allows flexibility across the prism layer resolution (targeting 30 < y+ < 150), bridging viscous sublayer and log-law regions.

---

## Mesh Configuration

| Parameter | Value |
|---|---|
| Mesher | Polyhedral + Prism Layer + Surface Remesher |
| Surface Wrapper base size | 0.5 m |
| Submarine surface size | 10% of base → 0.05 m |
| Prism layers | 9 |
| Prism layer total thickness | 10% of base size |
| Target y⁺ | 30 – 150 |
| Max cell size | 100% of base size |
| Volume growth rate | 1.2 |

Polyhedral cells are used in the core domain for their improved accuracy-per-cell compared to tetrahedral meshes. Prism layers are grown from the submarine hull to capture the boundary layer. The volume growth rate of 1.2 ensures a smooth size transition between the refined near-wall region and the coarser far-field. The mesh sensitivity study varies the base size from 2.0 m down to 1.25 m, increasing cell count from ~95K to ~234K.

---

## Results — Mesh Sensitivity Study

> C_D and C_L values taken from the last iteration row of the StarCCM+ convergence output window.

| Base Size (m) | Mesh Cells | Final Iteration | C_D | C_L |
|:---:|---:|:---:|:---:|:---:|
| 2.00 | 95,236 | 137 | 8.5657×10⁻² | −9.3964×10⁻³ |
| 1.75 | 119,341 | 137 | 8.1164×10⁻² | −4.2406×10⁻³ |
| 1.50 | 164,486 | 148 | 7.6600×10⁻² | −5.9038×10⁻³ |
| 1.25 | 233,972 | 157 | 7.0848×10⁻² | −7.6326×10⁻³ |

### Discussion

**Drag coefficient (C_D):** C_D decreases monotonically as the base mesh size is reduced, dropping from 0.08566 at 2.0 m to 0.07085 at 1.25 m — a reduction of approximately 17% across the range. This trend indicates that coarser meshes overestimate drag, likely due to insufficient resolution of the boundary layer and near-hull flow separation. The reduction in C_D is steeper between 2.0 m and 1.5 m and begins to flatten slightly at 1.25 m, suggesting the solution is approaching mesh-independent behaviour. 

**Lift coefficient (C_L):** C_L remains small in magnitude across all cases (order 10⁻³), which is physically consistent with a symmetric hull at zero angle of attack producing negligible net lift. The non-monotonic variation of C_L with mesh size (ranging from −4.24×10⁻³ to −9.40×10⁻³) reflects the sensitivity of small force components to mesh resolution, particularly at the bow and stern where minor asymmetries in cell distribution can influence the result. All values are considered negligibly small relative to drag.

---

## Repository Structure

```
Simulation results/
├── With base size 2.0 m/
│   ├── Mesh details.jpeg
│   ├── Residual Plot.jpeg
│   ├── Drag Plot.jpeg
│   ├── Lift Plot.jpeg
│   ├── Convergance details.jpeg
│   ├── Velocity distribution.jpeg
│   ├── Pressure disribution.jpeg
│   ├── Scalar Feild.jpeg
│   └── Vector feild.jpeg
├── With base size 1.75 m/  (same structure)
├── With base size 1.5 m/   (same structure)
└── With base size 1.25 m/  (same structure)
Submarine_CFD_Manual.pdf
README.md
```

---

## Reference

Daróczy, L. & Janiga, G. — *CFD Hands-on: Drag forces of a submarine using StarCCM+*, LSS, OvGU Magdeburg, January 2025.
