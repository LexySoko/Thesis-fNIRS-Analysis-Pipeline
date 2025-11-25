# fNIRS / HD-DOT Dance Task Preprocessing Demo (MATLAB)

This repository provides a small, fully reproducible MATLAB pipeline that
mirrors the preprocessing and quality-control workflow from my honors
thesis on dance and AI-generated movement.

The code uses **simulated fNIRS/HD-DOT data** for a block-design
observation vs execution task (e.g., watching vs dancing movement
phrases). It is intended as a transparent example of how I work with
optical neuroimaging data, not as a replacement for any vendor or
toolbox-specific pipeline.

## Requirements

- MATLAB (R2021b or later recommended)
- [NeuroDOT toolbox](https://www.nitrc.org/projects/neurondot/) installed
  and on the MATLAB path for:
  - real fNIRS/HD-DOT datasets
  - cortical / 2D brain surface projections (dorsal, lateral views)
  - vendor-specific LUMO data loading and registration workflows

The **simulation + basic channel-based analysis and QC** in this repo
can run without NeuroDOT. However, reproducing a full analysis like in
my thesis (including cortical maps and subject-specific registration)
requires NeuroDOT.

## Pipeline overview

The demo follows these steps:

1. **Simulate fNIRS session**
   - Two wavelengths (735 nm, 850 nm)
   - Short- and long-separation channels
   - Block-design conditions (e.g., observation vs execution)
   - Cardiac oscillations, slow drift, task-locked hemodynamic responses
   - Motion artifacts injected into execution blocks

2. **Raw data quality & motion**
   - Light level and simple SNR summaries across channels
   - Global Variance of the Temporal Derivative (GVTD) time series
   - Raw time-trace visualization

3. **Preprocessing**
   - Convert intensity → optical density
   - Bandpass filter (0.01–0.5 Hz)
   - Short-channel regression to remove superficial physiology

4. **Quality control after preprocessing**
   - Post-processed time traces
   - Frequency spectra with visible cardiac peaks (~1 Hz)
   - Histogram of measurement variability across channels

5. **GLM and maps**
   - Build a block design matrix for each task condition
   - Run a per-channel GLM on the cleaned data
   - Generate simple 2D activation maps over the cap
   - Compute condition subtraction maps (e.g., Execution – Observation)

All data are synthetic and self-contained.