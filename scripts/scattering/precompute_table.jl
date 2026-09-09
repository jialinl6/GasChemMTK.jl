# Regenerate src/tropospheric_interpolation_data.bson with multiple scattering
# from the ported Cloud-J Feautrier solver (see cloudj_solver.jl / README.md).
#
# Axes are taken from the EXISTING table so the result is a drop-in
# replacement: 18 bands x (tropospheric_P x cosSZA_vals), absolute actinic
# flux (top_flux-scaled). Writes to this directory; copy to src/ after review.
#
# Run: julia --project=. scripts/scattering/precompute_table.jl

include(joinpath(@__DIR__, "cloudj_solver.jl"))
using BSON
using Interpolations: interpolate, Gridded, Linear, extrapolate, Flat

const ALBEDO = 0.10

# --- axes from the existing table ------------------------------------------
BSON.@load joinpath(@__DIR__, "..", "..", "src", "tropospheric_interpolation_data.bson") Z_all tropospheric_P cosSZA_vals
const Z_old = Z_all
const P_nodes = collect(tropospheric_P)      # Pa, ascending 1000..100000
const U0_nodes = collect(cosSZA_vals)        # -0.2 .. 1.0

# Edge pressures of the solver column (Pa): edge 1 = surface .. 74 = TOA
# (the 74th edge is the ZZHT top-of-atmosphere pad; assign it P = 0).
const P_edges = vcat(collect(GasChem.P_levels), 0.0)

println("Precomputing $(length(U0_nodes)) SZA nodes x 18 bands x ",
    length(P_nodes), " pressure nodes (albedo = $ALBEDO, AOD = 0) ...")

Z_new = [zeros(length(P_nodes), length(U0_nodes)) for _ in 1:18]

t0 = time()
for (ju, u0) in enumerate(U0_nodes)
    ftau_all = solar_beam_edges_allbands(u0)
    for band in 1:18
        J_edges, _ = solve_band(u0, band; albedo = ALBEDO,
            ftau = ftau_all[:, band])
        # absolute flux at the solver's edge pressures
        Fabs = J_edges .* GasChem.top_flux[band]
        # interpolate onto the table's pressure axis (P_edges is descending
        # in index? P_edges[1]=101325 .. P_edges[74]~small -> reverse for
        # Gridded which needs ascending knots)
        itp = extrapolate(
            interpolate((reverse(P_edges),), reverse(Fabs), Gridded(Linear())),
            Flat())
        for (jp, P) in enumerate(P_nodes)
            Z_new[band][jp, ju] = itp(P)
        end
    end
end
println("done in ", round(time() - t0, digits = 1), " s")

# --- summary vs the old (direct-beam) table --------------------------------
println("\nband | surface enh (u0=1) | 500 hPa enh (u0=0.5) | max ratio")
for band in 1:18
    iP_s = length(P_nodes)               # 100000 Pa
    iP_m = findfirst(==(50500.0), P_nodes)
    iU_1 = length(U0_nodes)              # u0 = 1.0
    iU_h = findfirst(==(0.5), U0_nodes)
    olds = Z_old[band][iP_s, iU_1]
    news = Z_new[band][iP_s, iU_1]
    oldm = Z_old[band][iP_m, iU_h]
    newm = Z_new[band][iP_m, iU_h]
    r = filter(isfinite, vec(Z_new[band] ./ max.(Z_old[band], 1e-30)))
    println(rpad(band, 5), "| ",
        rpad(olds > 0 ? round(news / olds, digits = 3) : "-", 19), "| ",
        rpad(oldm > 0 ? round(newm / oldm, digits = 3) : "-", 21), "| ",
        round(maximum(r[vec(Z_old[band]) .> 1e-30 * maximum(Z_old[band])];
            init = 0.0), digits = 2))
end

# --- write -----------------------------------------------------------------
Z_all = Z_new
provenance = Dict(
    "generator" => "scripts/scattering/precompute_table.jl",
    "solver" => "Cloud-J OPMIE/MIESCT/BLKSLV port (geoschem/cloud-j@16d18b07, GEOS-Chem 14.7.1 pin)",
    "atmosphere" => "fixed climatological column: Rayleigh + O2/O3 absorption, 313.4 DU O3, T_profile clim.",
    "albedo" => ALBEDO,
    "aerosol_od" => 0.0,
    "solf" => "not included (applied at runtime by solar_flux_factor)",
)
out = joinpath(@__DIR__, "tropospheric_interpolation_data_scattering.bson")
BSON.@save out Z_all tropospheric_P cosSZA_vals provenance
println("\nwrote ", out)
