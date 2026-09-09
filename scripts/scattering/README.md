# Clear-sky scattering for Fast-JX: first-principles precompute

Adds Rayleigh multiple scattering + surface reflection to this package's
Fast-JX photolysis from first principles: a Julia port of the Cloud-J
Feautrier radiative-transfer solver, run once over the package's fixed
climatological column. This is the self-contained alternative to the
empirical GEOS-Chem-fitted table of upstream EarthSciML/GasChem.jl#240 -
no GEOS-Chem output data is used, every atmospheric assumption is explicit,
and everything regenerates from this repo with one script.

## Architecture

The diffuse (scattered) flux is a whole-column boundary-value problem that a
box model cannot compute locally - but for a fixed column it is a pure
function of (P, cosSZA), so it can be precomputed. Two data files, both
written by `precompute_table.jl`:

| File | Contents | Consumed by |
|---|---|---|
| `src/diffuse_flux_data.bson` | diffuse-only field `4*FJ(P, cosSZA)` per band | `FastJX` (default `fluxes = :scattering`): **computes** its spherical Beer-Lambert direct beam per evaluation (any pressure) and **adds** this field. `fluxes = :direct` drops it (clear-beam baseline). |
| `src/tropospheric_interpolation_data.bson` | total flux = `calc_direct_flux` + diffuse at each grid node | `FastJX_interpolation*`: compute no radiation, read the offline precompute of the online `FastJX`. |

`diffuse + direct = total` holds exactly at the nodes, so
`FastJX` and `FastJX_interpolation_troposphere` agree to ~1e-5 relative on
all shared J's - the residual is interpolation error of the direct part,
the defining property of an offline surrogate. Diffuse field valid
10-1000 hPa (held flat outside); axes 23 P-nodes x 61 cosSZA-nodes
(-0.2..1.0, twilight included). SOLFX is excluded from both files and
applied at runtime by `solar_flux_factor` (#224 convention).

## Regenerating

```
julia --project=. scripts/scattering/precompute_table.jl   # ~2 s
cp scripts/scattering/diffuse_flux_data.bson src/
cp scripts/scattering/tropospheric_interpolation_data_scattering.bson \
   src/tropospheric_interpolation_data.bson
```

`include_dependency` on both files makes the swap take effect on the next
precompile. Generated copies in this directory are gitignored.

## Fixed atmosphere (all explicit)

| Parameter | Value |
|---|---|
| Pressure grid | GEOS 72-layer hybrid at Psurf = 101325 Pa (`P_levels`) |
| Temperature | climatological `T_profile` (attenuation only; species sigma-phi use local T at runtime) |
| O3 profile | `mean_o3_profile`: **313.4 DU** total, peak 8.14 ppm @ ~6 hPa, surface 24 ppb (verified midlatitude-mean reasonable) |
| Rayleigh | `sigma_Raylay` per band (Cloud-J v8.0 bins 17-18); ssalb = 1; phase moments (1, 0, 0.5, 0, ...) |
| O2/O3 absorption | `sigma_O2_interp` / `sigma_O3_interp` at climatological T |
| Aerosol | **AOD = 0** (deliberate aerosol-free baseline) |
| Surface albedo | **0.10** Lambertian, spectrally flat |

Per-layer single-scattering albedo: `omega0 = OD_ray / (OD_ray + OD_abs)`;
`POMEGA = omega0 * [1, 0, 0.5, 0, ...]` (pure Rayleigh).

## Solver provenance

`cloudj_solver.jl` is a port of `OPMIE`/`MIESCT`/`LEGND0`/`GEN_ID`/`BLKSLV`
(Feautrier method, 4 Gauss points x 8-term Legendre) from
`cloud-j/src/Core/cldj_fjx_sub_mod.F90` at geoschem/cloud-j commit
`16d18b07` - the Cloud-J pinned by GEOS-Chem Classic 14.7.1 (science
codebase `b9f570e2`); reference clones under `~/geoschem-refs/`.
Clear-sky simplifications (documented in-file): JXTRA = 0 (cloud sub-layer
insertion unneeded), AMG = 1 (plane-parallel scattering); the solar beam
keeps full spherical geometry via the package's `sphere2J`, so the direct
component matches `calc_direct_flux` by construction.

## Validation

- `test_solver.jl` (78 tests): energy conservation - a conservative column
  over a mirror surface returns all incident flux out the top (rtol 2%);
  zero-scattering limit exactly reproduces the direct beam; optically-thin
  limit; twilight finite and non-negative; direct component matches
  `calc_direct_flux` to 1e-10.
- vs #240's GC-fitted table (median ours/fit, lit tropospheric nodes
  u0 >= 0.2): band 17 **1.04**, band 16 1.08, band 15 1.09, band 13 1.14,
  bands 11/14 ~1.20 - a few-20% high, the expected AOD = 0 signature (the
  fit embeds April CONUS aerosol). Band 18 1.25 (#240 deliberately leaves
  band 18 unenhanced). Twilight (u0 < 0.05) band 17: 0.74 - the fit
  retains aerosol forward scattering near the terminator that pure
  Rayleigh lacks.
- End-to-end (surface, 40N, summer noon): J_NO2 **1.051e-2 s^-1** vs
  #240's quoted 1.03e-2 (2%); enhancement over the beam-only baseline
  1.83x (J_NO2), 2.5-3.0x (UV channels: H2O2, H2CO, CH3OOH, o3->2OH).
- Pinned 24-h box-model test solutions (compose_fastjx_superfast_test.jl,
  pollu_test.jl) are insensitive at their rtol = 1e-4 and pass unchanged.

Possible extensions: node-level check against Cloud-J standalone compiled
from the pinned clone; albedo (0.05/0.10/0.8-snow) and O3-column (+/-20%)
sensitivity tables.
