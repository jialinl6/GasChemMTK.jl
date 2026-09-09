# First-principles scattering precompute for the Fast-JX interpolation table

Goal: regenerate `src/tropospheric_interpolation_data.bson` from a ported
Cloud-J multiple-scattering solver over this package's fixed climatological
column, replacing the direct-beam-only (Beer-Lambert) precompute. This is the
first-principles alternative to the empirical GEOS-Chem-fitted table of
upstream PR EarthSciML/GasChem.jl#240: no screened channels, no unconstrained
band 18, and every atmospheric assumption explicit.

## Reference source (pinned to GEOS-Chem Classic 14.7.1)

Cloned under `~/geoschem-refs/` at the exact submodule commits of
`geoschem/GCClassic` tag `14.7.1`:

| Repo | Commit | Role |
|---|---|---|
| geoschem/cloud-j | `16d18b07ebc7f6ab3f8eb4c2ddcfdae8f12d9a23` | scattering solver |
| geoschem/geos-chem | `b9f570e2c7a98b308004cd07e2985a12a47b6f5c` | caller/interface reference |

The solver chain lives in `cloud-j/src/Core/cldj_fjx_sub_mod.F90`:

| Routine | Lines | Purpose |
|---|---|---|
| `OPMIE` | ~799-1207 | driver: builds the scattering tau-grid (doubled layers + JXTRA insertion), assembles per-layer OD and phase function, calls MIESCT, maps mean intensity back to CTM mid-layers -> `FJACT` |
| `MIESCT` | ~1209-1260 | loop over the 4 Gauss angles / bands; calls BLKSLV |
| `LEGND0` | ~1262-1287 | Legendre polynomial evaluation (8-term expansion) |
| `BLKSLV` | ~1289-1582 | block-tridiagonal solve of the Feautrier system (4 Gauss pts x 8-term phase expansion) |
| `GEN_ID` | ~1584-1851 | builds the tridiagonal blocks (lower/main/upper) incl. surface-albedo boundary condition |
| `SPHERE1R/N/F` | ~2397-2796 | spherical air-mass factor matrix `AMF` (partially ported already as `sphere2*` in `src/direct_flux.jl`) |
| `EXTRAL1` | ~2798-2866 | JXTRA sub-layer insertion for optically thick (cloud) layers - clear-sky Rayleigh needs JXTRA ~= 0, port last or stub |

Key interface (OPMIE): inputs `DTAUX(L1,W)` layer optical depth,
`POMEGAX(8,L1,W)` = single-scattering albedo x 8-term Legendre phase moments,
`U0` = cosSZA, `RFL` = Lambertian surface albedo, `AMF` air-mass matrix;
output `FJACT(L,W)` = **mean actinic flux at CTM mid-layers** - exactly the
quantity stored per band in `tropospheric_interpolation_data.bson`.

## Fixed atmosphere (all explicit; matches/extends src/direct_flux.jl)

| Parameter | Value | Source |
|---|---|---|
| Pressure grid | GEOS 72-layer hybrid at Psurf = 101325 Pa (`P_levels`) | existing |
| Temperature | climatological `T_profile` / `T_profile_top` | existing |
| O3 profile | `mean_o3_profile`, integrates to **313.4 DU** (peak 8.14 ppm @ ~6 hPa, surface 24 ppb, trop. partial column 46 DU) | existing (verified midlatitude-mean reasonable) |
| Rayleigh | sigma_Raylay per band (Cloud-J v8.0 bins 17-18); ssalb = 1; phase moments (1, 0, 0.5, 0, ...) | existing sigma + analytic phase fn |
| O2/O3 absorption | sigma_O2_interp / sigma_O3_interp at climatological T | existing |
| Aerosol | **AOD = 0** (clear-sky, aerosol-free baseline - deliberate, documented) | fixed choice |
| Surface albedo | **0.10** Lambertian, spectrally flat | fixed choice |
| TOA flux | `top_flux` (Cloud-J v8.0 bins 17-18) | existing |
| SOLFX | divided out (re-applied at runtime by solar_flux_factor) | matches #224/#240 convention |

Per-layer single-scattering albedo: omega0(L, band) = OD_ray / (OD_ray + OD_abs);
POMEGAX(:, L, band) = omega0 * [1, 0, 0.5, 0, 0, 0, 0, 0] (pure Rayleigh).

## Port order

1. `LEGND0` (trivial), `MIESCT`, `BLKSLV`, `GEN_ID` -> `cloudj_solver.jl`.
   Self-contained linear algebra: unit-testable on synthetic single-layer
   problems (conservation, isotropic limit, thick-atmosphere asymptotics).
2. `OPMIE` grid construction wired to the existing `OD_total` column and the
   existing spherical geometry (`sphere2J` / port `SPHERE1N` for the full AMF
   matrix).
3. `precompute_table.jl`: loop cosSZA nodes (incl. twilight, U0 < 0 handled by
   the spherical AMF), run OPMIE per node, assemble `Z_all` (18 matrices over
   `tropospheric_P` x `cosSZA_vals`), write the bson (same keys; add a
   `provenance` entry recording this file's parameter table).

## Status / results

All steps below are DONE; the generated table is installed as
`src/tropospheric_interpolation_data.bson` (regenerate with
`julia --project=. scripts/scattering/precompute_table.jl`, output lands in
this directory, then copy to `src/`).

- `test_solver.jl`: 78/78 - energy conservation (conservative column + mirror
  surface returns all incident flux, rtol 2%), zero-scattering limit exact,
  optically-thin limit, twilight finite/non-negative, direct component matches
  `calc_direct_flux` to 1e-10.
- vs upstream #240's GC-fitted table (lit tropospheric nodes, median
  ours/fit): band 17 **1.044**, band 16 1.089, band 15 1.098, band 13 1.157 -
  a few-15% high, the expected AOD=0 signature (the fit embeds April CONUS
  aerosol). Band 18 1.25 because #240 deliberately leaves band 18 unenhanced.
- End-to-end (surface, lat 40, summer noon), interpolated vs direct-beam:
  J_NO2 **1.053e-2 s^-1 (1.83x)** vs #240's quoted 1.03e-2; J_H2O2 2.72x,
  J_H2CO 2.6-2.8x, J_CH3OOH 2.49x, o3->2OH 3.04x.
- The pinned 24-h box-model test solutions (compose_fastjx_superfast_test.jl,
  pollu_test.jl) are insensitive to the table at their rtol=1e-4 and pass
  unchanged.
- Final architecture (two data files, both written by `precompute_table.jl`):
  * `src/diffuse_flux_data.bson` - the DIFFUSE-only field 4*FJ. The online
    `FastJX` (default `fluxes = :scattering`) COMPUTES its direct beam per
    evaluation (spherical Beer-Lambert, any pressure) and adds this field -
    computing what a box model can compute, reading only what it cannot
    (the diffuse flux is a whole-column boundary-value problem, but for the
    fixed column it is a pure function of (P, cosSZA)). `fluxes = :direct`
    drops the diffuse term (clear-beam baseline).
  * `src/tropospheric_interpolation_data.bson` - the TOTAL flux
    (calc_direct_flux + diffuse at each node), i.e. the offline precompute
    of the online `FastJX`. Read by `FastJX_interpolation*`, which compute
    no radiation at all. Verified: `FastJX` vs
    `FastJX_interpolation_troposphere` agree to ~1e-5 relative on all
    shared J's - the residual is interpolation error of the direct part,
    the correct definition of an offline surrogate.

## Validation plan

- Unit: BLKSLV against analytic two-stream limits; flux conservation
  (FJTOP + FJBOT + absorbed = incident) per band.
- Integration: compare a few (P, cosSZA) nodes against Cloud-J standalone
  (the cloned Fortran builds with cmake) run on the same fixed column.
- End-to-end: J_NO2/J_O1D/etc. vs the clear-sky GEOS-Chem numbers quoted in
  upstream #240 (expect: our table slightly ABOVE its fit for UV channels,
  since AOD = 0 here vs its baked-in April CONUS aerosol; that difference is
  the aerosol+albedo contribution and is worth reporting).
- Consistency: direct-beam component of the solver output must reproduce
  `calc_direct_flux` (the existing kernel) when scattering is disabled.
