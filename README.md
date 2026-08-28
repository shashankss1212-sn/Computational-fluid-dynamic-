# Computational Fluid Dynamics

A record of how I learned CFD, from writing the numerical methods by hand in MATLAB, through a handful of STAR-CCM+ validation cases, up to the project everything else was building toward: a wind study of the Brandenburg Gate.

Read the folders roughly in order. The MATLAB scripts and the smaller simulation cases are the stepping stones, each one covering a piece of how the software works and why it gives the answers it does. The Brandenburg Gate study is where all of that comes together.

**Software:** Siemens Simcenter STAR-CCM+ for the simulations, MATLAB for the hand-coded numerics.

---

## The main project — Brandenburg Gate wind study

**Folder:** `Final Project/FInal Project New/`

A steady-state RANS simulation of wind blowing around a scaled 3D model of the Brandenburg Gate, run in STAR-CCM+. The question behind it is a practical one: how hard does the wind push on the structure, and how fast does the air get moving right where tourists stand?

I ran it at two inlet speeds, 9 m/s and 18 m/s (roughly 32 and 65 km/h, a strong breeze and a near-gale), and from two wind directions. For each case I pulled the drag and lift forces and their coefficients, and the peak velocity a person near the gate would actually feel.

**Setup**

- Turbulence: SST (Menter) k-ω, All y+ wall treatment
- Solver: steady, segregated, RANS, constant density
- Air at STP: ρ = 1.225 kg/m³, μ = 1.825 × 10⁻⁵ Pa·s
- Domain: 4H to the inlet, sides and top; 8H–10H to the outlet downstream (H ≈ 26 m characteristic height)
- Mesh: surface wrapper for a watertight surface, then a polyhedral volume mesh with 10 prism layers on the gate and ground

**Grid independence first**

Before trusting any result, I ran the same case on four mesh sizes, from ~1.17 million cells up to ~2.83 million. The 10%-base-size mesh (~1.81 M cells) came within about 1.5% of the finest grid on both drag and lift while using 36% fewer cells, so that is the mesh the production runs use. The full table is in `Grid Independence study/`.

**Results**

| Wind direction | Inlet speed | Drag (N) | C_d | Lift (N) | C_l | Peak velocity near gate (m/s) |
|---|---:|---:|---:|---:|---:|---:|
| X (front-on) | 9 m/s | 6,217 | 0.680 | 4,861 | 0.133 | 11.6 |
| X (front-on) | 18 m/s | 24,314 | 0.665 | 19,683 | 0.135 | 23.0 |
| Z (side-on) | 9 m/s | 55,435 | 1.312 | 17,965 | 0.493 | 16.3 |
| Z (side-on) | 18 m/s | 221,414 | 1.310 | 70,039 | 0.481 | 32.1 |

A few things worth pointing out:

- **The drag coefficient barely moves with speed.** C_d holds near 0.68 front-on and near 1.31 side-on across both velocities. That is the expected signature of a bluff body at high Reynolds number, where drag is dominated by pressure and separation rather than viscosity, so the *coefficient* stays put even as the *force* roughly quadruples when you double the speed.
- **Direction matters more than speed.** Turning the wind side-on nearly doubles the drag coefficient, because the gate presents far more blocked area to the flow along that axis.
- **The wind speeds up around the gate.** In the worst case, an 18 m/s side-on wind accelerates to about 32 m/s in the gaps between the columns. That local speed-up is the number a pedestrian-comfort assessment actually cares about, and it is why the peak velocity is tracked separately from the free-stream.

There is also a nonlinear analysis on the side-on 9 m/s case (recurrence plot, determinism ≈ 61%, FFT) probing how ordered or chaotic the wake behind the gate is.

The CSV files under `X Direction Flow/` and `Y Direction Flow/` are the raw force and coefficient convergence histories, iteration by iteration. The slide deck `CFD_Brandenburg_Gate.pptx` walks through the whole study.

---

## The stepping stones

Each of these came before the final project and taught a specific piece of it.

### MATLAB — the numerics by hand

**Folder:** `Matlab/Trail Excersice/`

Before running a solver, it helps to have written one.

- `Temperture_distribution.m` — 1D steady heat conduction solved with the finite-volume method. It assembles the stiffness matrix term by term, applies the boundary conditions, and solves the linear system directly. This is the discretization a CFD code does for you, done in the open so you can see where every coefficient comes from.
- `Velocity_distibution_from_stream_function.m` — 2D flow from a stream function, solved three ways: Jacobi, Gauss-Seidel, and successive over-relaxation (ω = 1.8). It then differentiates the stream function to get the velocity field and checks that the inlet and outlet flow rates balance. This is the iterative-solver-and-convergence loop that every RANS run is quietly running underneath.

### Laminar Channel

**Folder:** `Laminar Channel/`

The first full pass through STAR-CCM+: import a mesh, set up laminar channel flow, solve, and post-process. The velocity profile develops toward the parabolic shape it should, and the pressure and energy fields are there to read. Simple case, whole workflow.

### Elbow

**Folder:** `Elbow/`

The classic elbow mixing case. Mesh a bend, run it, and read a scalar (temperature) mixing scene along with the residuals. Practice at meshing curved geometry and interpreting a scalar field.

### Backward-Facing Step (BFS)

**Folder:** `BFS/`

A validation exercise, and the reason the turbulence-model choice in the final project is not arbitrary. I ran the step with both k-ε and k-ω and compared the profiles against experimental data at x = 3 and x = 8, along with wall shear stress and the recirculation behind the step. Seeing where each model matches the measurements and where it does not is what justified reaching for SST k-ω later.

### Submarine flow simulation (USS Albacore)

**Folder:** `Submarine flow simulation/`

External flow over a submarine hull: drag and lift coefficients from a steady RANS run, with a four-level mesh sensitivity study (base sizes 2.0 down to 1.25 m). This is the closest rehearsal for the Brandenburg Gate problem — a body in an open flow, a virtual wind tunnel, a mesh study to earn trust in the numbers. It has its own detailed write-up in `Submarine flow simulation/README (2).md`.

---

## Repository map

```
.
├── Matlab/Trail Excersice/        # 1D heat conduction (FVM) + 2D stream function (Jacobi/GS/SOR)
├── Laminar Channel/               # developing laminar channel flow (StarCCM+)
├── Elbow/                         # elbow mixing tutorial
├── BFS/                           # backward-facing step, k-ε vs k-ω validation
├── Submarine flow simulation/     # USS Albacore drag study + mesh sensitivity (own README)
└── Final Project/FInal Project New/   # ★ Brandenburg Gate wind study
```

A note on file types: the `.sim` files are STAR-CCM+ simulation files (large and binary), `.msh` is a mesh, `.STL` is CAD geometry, and the `.PNG`/`.jpeg` files are exported scenes and plots.

---

## Author

Shashank Suresh Srinivasan — M.Sc. Chemical and Energy Engineering, Otto von Guericke University Magdeburg. The Brandenburg Gate study was submitted to Dr.-Ing. habil. Gabor Janiga.

---

## Author

Shashank Suresh Srinivasan — M.Sc. Chemical and Energy Engineering, Otto von Guericke University Magdeburg. The Brandenburg Gate study was submitted to Dr.-Ing. habil. Gabor Janiga.
