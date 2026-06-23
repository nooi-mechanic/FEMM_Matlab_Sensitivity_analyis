# FEMM Matlab/Octave Sensitivity Analysis

This repository contains a small starting point for running parameter sweeps and sensitivity studies on FEMM models from GNU Octave or MATLAB-compatible workflows.

The current scaffold is intentionally simple:

- `octave/run_femm_sensitivity_template.m`: a reusable Octave script that opens a FEMM model, sweeps selected parameters, solves each case, and writes a CSV summary.

## What This Project Is For

Typical use cases include:

- checking how force, flux linkage, inductance, or field values change with geometry
- comparing sensitivity to current, air gap, or material property changes
- automating repetitive FEMM studies instead of editing models by hand

## Requirements

- [FEMM](https://www.femm.info/wiki/HomePage) installed
- GNU Octave
- a valid `.fem` model file prepared in FEMM

Notes:

- The script assumes a FEMM automation workflow compatible with `openfemm`.
- In practice, FEMM automation is most commonly used on Windows.
- You will usually need to adapt the circuit name, block labels, and result extraction logic to match your model.

## Quick Start

1. Create or prepare a base FEMM model, for example `models/actuator_base.fem`.
2. Open `octave/run_femm_sensitivity_template.m`.
3. Update the configuration section:
   - set `base_model_path`
   - set `output_csv_path`
   - set the circuit name used in your model
   - customize geometry editing in `apply_case_to_model`
   - customize result extraction in `extract_case_result`
4. Run the script from Octave.

Example:

```octave
run("octave/run_femm_sensitivity_template.m")
```

## Output

The template writes a CSV file with one row per simulation case. By default, it stores:

- case index
- coil current
- air gap
- circuit current returned by FEMM
- circuit voltage/flux term returned by FEMM
- a simple derived sensitivity value relative to the first case

You can replace these outputs with force, torque, inductance, or any other metric available in your FEMM model.

## Suggested Next Steps

- add a baseline `.fem` file under `models/`
- add plots for sensitivity curves
- split common FEMM helper functions into separate `.m` files
- add MATLAB-specific wrappers if you want both Octave and MATLAB entry points

## Repository Layout

```text
.
├── README.md
└── octave
    └── run_femm_sensitivity_template.m
```
