export FastJX_interpolation_troposphere

# The table is read at module top level and baked into `interpolations_18_const` below, which is
# serialized into the precompile cache. Julia's staleness check only tracks files it has been
# told about, so without this declaration replacing the .bson leaves the stale table in the .ji
# and the new one is silently ignored — a fresh process would still serve the old values.
include_dependency("tropospheric_interpolation_data.bson")
BSON.@load joinpath(@__DIR__, "tropospheric_interpolation_data.bson") Z_all tropospheric_P cosSZA_vals
# Z_all is a vector of 18 matrices, each of which represents the actinic flux at different CSZA and Pressure.

interpolations_18_troposphere = []
for i in 1:18
    itp = interpolate(Z_all[i], BSpline(Linear()), OnGrid())
    f_in = Interpolations.scale(itp, tropospheric_P, cosSZA_vals)
    f_ext = extrapolate(f_in, Flat())
    push!(interpolations_18_troposphere, f_ext)
end

const interpolations_18_const = tuple(interpolations_18_troposphere...)

# Create symbolic wrapper functions for each interpolation
flux_interp_1(P, csa) = interpolations_18_const[1](ustrip(P), ustrip(csa))
flux_interp_2(P, csa) = interpolations_18_const[2](ustrip(P), ustrip(csa))
flux_interp_3(P, csa) = interpolations_18_const[3](ustrip(P), ustrip(csa))
flux_interp_4(P, csa) = interpolations_18_const[4](ustrip(P), ustrip(csa))
flux_interp_5(P, csa) = interpolations_18_const[5](ustrip(P), ustrip(csa))
flux_interp_6(P, csa) = interpolations_18_const[6](ustrip(P), ustrip(csa))
flux_interp_7(P, csa) = interpolations_18_const[7](ustrip(P), ustrip(csa))
flux_interp_8(P, csa) = interpolations_18_const[8](ustrip(P), ustrip(csa))
flux_interp_9(P, csa) = interpolations_18_const[9](ustrip(P), ustrip(csa))
flux_interp_10(P, csa) = interpolations_18_const[10](ustrip(P), ustrip(csa))
flux_interp_11(P, csa) = interpolations_18_const[11](ustrip(P), ustrip(csa))
flux_interp_12(P, csa) = interpolations_18_const[12](ustrip(P), ustrip(csa))
flux_interp_13(P, csa) = interpolations_18_const[13](ustrip(P), ustrip(csa))
flux_interp_14(P, csa) = interpolations_18_const[14](ustrip(P), ustrip(csa))
flux_interp_15(P, csa) = interpolations_18_const[15](ustrip(P), ustrip(csa))
flux_interp_16(P, csa) = interpolations_18_const[16](ustrip(P), ustrip(csa))
flux_interp_17(P, csa) = interpolations_18_const[17](ustrip(P), ustrip(csa))
flux_interp_18(P, csa) = interpolations_18_const[18](ustrip(P), ustrip(csa))

@register_symbolic flux_interp_1(P, csa)
@register_symbolic flux_interp_2(P, csa)
@register_symbolic flux_interp_3(P, csa)
@register_symbolic flux_interp_4(P, csa)
@register_symbolic flux_interp_5(P, csa)
@register_symbolic flux_interp_6(P, csa)
@register_symbolic flux_interp_7(P, csa)
@register_symbolic flux_interp_8(P, csa)
@register_symbolic flux_interp_9(P, csa)
@register_symbolic flux_interp_10(P, csa)
@register_symbolic flux_interp_11(P, csa)
@register_symbolic flux_interp_12(P, csa)
@register_symbolic flux_interp_13(P, csa)
@register_symbolic flux_interp_14(P, csa)
@register_symbolic flux_interp_15(P, csa)
@register_symbolic flux_interp_16(P, csa)
@register_symbolic flux_interp_17(P, csa)
@register_symbolic flux_interp_18(P, csa)

# Symbolic equations for actinic flux
function flux_eqs_interpolation(csa, P, solf)
    flux_vals = []
    flux_vars = []
    @constants c_flux = 1.0 [
        unit = u"s^-1", description = "Constant actinic flux (for unit conversion)",
    ]

    interpolation_funcs = [
        flux_interp_1, flux_interp_2, flux_interp_3,
        flux_interp_4, flux_interp_5, flux_interp_6,
        flux_interp_7, flux_interp_8, flux_interp_9, flux_interp_10, flux_interp_11, flux_interp_12,
        flux_interp_13, flux_interp_14, flux_interp_15, flux_interp_16, flux_interp_17, flux_interp_18,
    ]

    for i in 1:18
        f = interpolation_funcs[i](P, csa)
        wl = WL[i]
        n1 = Symbol("F_", Int(round(wl)))
        v1 = @variables $n1(t) [unit = u"s^-1", description = "Actinic flux at $wl nm"]
        push!(flux_vars, only(v1))
        push!(flux_vals, f)
    end

    return flux_vars, (flux_vars .~ collect(flux_vals) .* c_flux .* solf), c_flux # TODO(CT): remove "collect" when https://github.com/SciML/ModelingToolkit.jl/issues/3888 is fixed.
end

# ---- Diffuse-only scattering field, read online by `FastJX` ----------------
# The DIFFUSE flux (Rayleigh multiple scattering + surface reflection) cannot
# be computed locally by a box model - it is a whole-column boundary-value
# problem. For the fixed climatological column it is, however, a pure function
# of (P, cosSZA), precomputed by the Cloud-J Feautrier solver in
# scripts/scattering/precompute_table.jl. `FastJX` computes its own direct
# beam online (calc_direct_flux) and ADDS this field; `FastJX_interpolation*`
# instead reads the total table above (= calc_direct_flux + this field at the
# nodes, i.e. the offline precompute of the online FastJX).
include_dependency("diffuse_flux_data.bson")
const _diffuse_data = BSON.load(joinpath(@__DIR__, "diffuse_flux_data.bson"))
const diffuse_interp_const = tuple(
    [
        extrapolate(
            Interpolations.scale(
                interpolate(_diffuse_data[:Z_all][i], BSpline(Linear()), OnGrid()),
                _diffuse_data[:tropospheric_P], _diffuse_data[:cosSZA_vals]),
            Flat())
            for i in 1:18
    ]...
)

for i in 1:18
    fname = Symbol(:diffuse_interp_, i)
    @eval begin
        $fname(P, csa) = diffuse_interp_const[$i](ustrip(P), ustrip(csa))
        @register_symbolic $fname(P, csa)
    end
end
@eval const diffuse_funcs = tuple($([Symbol(:diffuse_interp_, i) for i in 1:18]...))

# Actinic-flux subsystem for the online `FastJX` (drop-in for `flux_sys`,
# same subsystem name and F_* variable names): the direct beam is COMPUTED
# online per evaluation (spherical Beer-Lambert, any pressure), and the
# precomputed diffuse field is added (valid 10-1000 hPa, held flat outside).
function flux_sys_scattering(csa, P, solf)
    @constants c_flux = 1.0 [
        unit = u"s^-1", description = "Constant actinic flux (for unit conversion)",
    ]
    flux_vals = []
    flux_vars = []
    for i in 1:18
        f = calc_direct_flux(csa, P, i) + diffuse_funcs[i](P, csa)
        wl = WL[i]
        n1 = Symbol("F_", Int(round(wl)))
        v1 = @variables $n1(t) [unit = u"s^-1", description = "Actinic flux at $wl nm"]
        push!(flux_vars, only(v1))
        push!(flux_vals, f)
    end
    eqs = flux_vars .~ collect(flux_vals) .* c_flux .* solf
    return System(eqs, t, flux_vars, [c_flux], name = :ActinicFlux)
end

"""
Fast-JX photolysis (Neu et al. 2007, doi:10.1029/2006JD008007) for the
`SuperFast`/`Pollu` species set, with all 18-band actinic fluxes read from
the precomputed (pressure, cosSZA) lookup table - the offline precompute of
the online [`FastJX`](@ref) calculation (direct beam + clear-sky diffuse
scattering; see scripts/scattering/). No radiation is computed at runtime,
which makes the right-hand side cheap for 3D simulations; the two
constructors agree up to interpolation error of the direct-beam part.
Table range: ~10-1000 hPa, cosSZA -0.2..1.0 (held flat outside).

Argument:

  - `t_ref`: Reference time for the model, can be a `DateTime` or a Unix timestamp (in seconds).

# Example

```julia
fj = FastJX_interpolation_troposphere(DateTime(2000, 1, 1))
```
"""
function FastJX_interpolation_troposphere(t_ref::AbstractFloat; name = :FastJX)
    @constants T_unit = 1.0 [
        unit = u"K",
        description = "Unit temperature (for unit conversion)",
    ]
    @parameters T = 298.0 [unit = u"K", description = "Temperature"]
    @parameters lat = 40.0 [description = "Latitude (Degrees)"]
    @parameters long = -97.0 [description = "Longitude (Degrees)"]
    @parameters P = 101325 [unit = u"Pa", description = "Pressure"]
    @constants P_unit = 1.0 [unit = u"Pa", description = "Unit pressure"]
    @parameters H2O = 450 [unit = u"ppb"]
    @parameters t_ref = t_ref [unit = u"s", description = "Reference Unix time"]

    @variables j_H2O2(t) [unit = u"s^-1"]
    @variables j_H2COa(t) [unit = u"s^-1"]
    @variables j_H2COb(t) [unit = u"s^-1"]
    @variables j_O31D(t) [unit = u"s^-1"]
    @variables j_o32OH(t) [unit = u"s^-1"]
    @variables j_CH3OOH(t) [unit = u"s^-1"]
    @variables j_NO2(t) [unit = u"s^-1"]
    @variables j_ActAld(t) [unit = u"s^-1"]
    @variables j_PAN(t) [unit = u"s^-1"]
    @variables j_NO3b(t) [unit = u"s^-1"]
    @variables j_NO3a(t) [unit = u"s^-1"]
    @variables j_N2O5(t) [unit = u"s^-1"]
    @variables j_O3(t) [unit = u"s^-1"]
    @variables cosSZA(t) [description = "Cosine of the solar zenith angle"]

    flux_vars, fluxeqs, c_flux = flux_eqs_interpolation(cosSZA, P / P_unit, solar_flux_factor(t + t_ref))
    j_o31D_adj = adjust_j_o31D(ParentScope(T), ParentScope(P), ParentScope(H2O))

    eqs = [
        cosSZA ~ cos_solar_zenith_angle(t + t_ref, lat, long);
        fluxeqs;
        j_ActAld ~ j_mean_ActAld(T / T_unit, flux_vars);
        j_PAN ~ j_mean_PAN(T / T_unit, flux_vars);
        j_O3 ~ j_mean_O3(T / T_unit, flux_vars);
        j_NO3b ~ j_mean_NO3b(T / T_unit, flux_vars);
        j_NO3a ~ j_mean_NO3a(T / T_unit, flux_vars);
        j_N2O5 ~ j_mean_N2O5(T / T_unit, flux_vars);
        j_H2O2 ~ j_mean_H2O2(T / T_unit, flux_vars);
        j_H2COa ~ j_mean_H2COa(T / T_unit, flux_vars);
        j_H2COb ~ j_mean_H2COb(T / T_unit, flux_vars);
        j_O31D ~ j_mean_O31D(T / T_unit, flux_vars);
        j_o32OH ~ j_O31D * j_o31D_adj.j_O31D_adj;
        j_CH3OOH ~ j_mean_CH3OOH(T / T_unit, flux_vars);
        j_NO2 ~ j_mean_NO2(T / T_unit, flux_vars)
    ]

    fjx = System(
        eqs,
        t,
        [j_H2O2, j_H2COa, j_H2COb, j_o32OH, j_O31D, j_CH3OOH, j_NO2, j_O3, j_NO3b, j_NO3a, j_N2O5, j_ActAld, j_PAN, cosSZA, flux_vars...],
        [lat, long, T, P, H2O, t_ref, c_flux, T_unit, P_unit];
        name = name,
        metadata = Dict(CoupleType => FastJXCoupler),
        systems = [j_o31D_adj]
    )
    return flatten(fjx) # Need to do flatten because otherwise coupling doesn't work correctly
end
function FastJX_interpolation_troposphere(t_ref::DateTime; kwargs...)
    return FastJX_interpolation_troposphere(datetime2unix(t_ref); kwargs...)
end

export FastJX_interpolation

"""
    FastJX_interpolation(t_ref; name=:FastJX)

Full-mechanism Fast-JX photolysis using **interpolated** actinic fluxes.

This constructor exposes the complete set of photolysis rate constants (the same
`j_*` species as [`FastJX`](@ref)), so it couples to the full GEOS-Chem
gas-phase mechanism (`GEOSChemGasPhase`) in addition to `SuperFast` and `Pollu`.

Unlike [`FastJX`](@ref) -- which computes its direct beam online per
evaluation and adds the precomputed diffuse-scattering field -- the 18-band
actinic fluxes here are read entirely from a precomputed lookup table
interpolated in pressure and the cosine of the solar zenith angle
(`flux_eqs_interpolation`). That table is the offline precompute of the
online [`FastJX`](@ref) calculation (direct beam + diffuse at each grid
node), so the two agree up to interpolation error of the direct part. The
temperature-dependent cross sections and quantum yields are applied
identically to [`FastJX`](@ref). This trades accuracy at the table edges for
a much cheaper right-hand-side evaluation, which is useful when Fast-JX is
embedded in a chemical transport model.

The shipped flux table spans a tropospheric pressure range (about 10-1000 hPa);
above the table top the flux is held constant (`Flat()` extrapolation), so this
constructor targets tropospheric / lower-stratospheric columns. For the reduced
(SuperFast-only) photolysis set, see [`FastJX_interpolation_troposphere`](@ref).

`t_ref` is the reference time (`DateTime` or Unix seconds). Passing a
`DomainInfo` uses its reference time, mirroring [`FastJX`](@ref).

# Example

```julia
fj = FastJX_interpolation(DateTime(2000, 1, 1))
```
"""
function FastJX_interpolation(t_ref::AbstractFloat; name = :FastJX)
    consts = @constants begin
        T_unit = 1.0, [unit = u"K", description = "Unit temperature (for unit conversion)"]
        P_unit = 1.0, [unit = u"Pa", description = "Unit pressure"]
    end
    params = @parameters begin
        T = 298.0, [unit = u"K", description = "Temperature"]
        lat = 40.0, [description = "Latitude (Degrees)"]
        long = -97.0, [description = "Longitude (Degrees)"]
        P = 101325, [unit = u"Pa", description = "Pressure"]
        H2O = 450, [unit = u"ppb"]
        t_ref = t_ref, [unit = u"s", description = "Reference Unix time"]
    end

    vars = @variables begin
        cosSZA(t), [description = "Cosine of the solar zenith angle"]

        j_o32OH(t), [unit = u"s^-1"]
        j_NO2(t), [unit = u"s^-1"]
        j_HOCl(t), [unit = u"s^-1"]
        j_H2COb(t), [unit = u"s^-1"]
        j_MeAcr(t), [unit = u"s^-1"]
        j_N2O5(t), [unit = u"s^-1"]
        j_H1301(t), [unit = u"s^-1"]
        j_CFCl3(t), [unit = u"s^-1"]
        j_NO(t), [unit = u"s^-1"]
        j_Glyxlc(t), [unit = u"s^-1"]
        j_F114(t), [unit = u"s^-1"]
        j_CH3NO3(t), [unit = u"s^-1"]
        j_CHBr3(t), [unit = u"s^-1"]
        j_F123(t), [unit = u"s^-1"]
        j_CHF2Cl(t), [unit = u"s^-1"]
        j_OClO(t), [unit = u"s^-1"]
        j_H1211(t), [unit = u"s^-1"]
        j_BrO(t), [unit = u"s^-1"]
        j_CH3Cl(t), [unit = u"s^-1"]
        j_MEKeto(t), [unit = u"s^-1"]
        j_PAN(t), [unit = u"s^-1"]
        j_H2402(t), [unit = u"s^-1"]
        j_PrAld(t), [unit = u"s^-1"]
        j_MeVKa(t), [unit = u"s^-1"]
        j_MeVKb(t), [unit = u"s^-1"]
        j_MeVKc(t), [unit = u"s^-1"]
        j_ClNO3b(t), [unit = u"s^-1"]
        j_F113(t), [unit = u"s^-1"]
        j_HNO4(t), [unit = u"s^-1"]
        j_ClO(t), [unit = u"s^-1"]
        j_H2O2(t), [unit = u"s^-1"]
        j_CH2Br2(t), [unit = u"s^-1"]
        j_OCS(t), [unit = u"s^-1"]
        j_F142b(t), [unit = u"s^-1"]
        j_F115(t), [unit = u"s^-1"]
        j_O31D(t), [unit = u"s^-1"]
        j_CF3I(t), [unit = u"s^-1"]
        j_Glyxla(t), [unit = u"s^-1"]
        j_CCl4(t), [unit = u"s^-1"]
        j_Cl2(t), [unit = u"s^-1"]
        j_CH3I(t), [unit = u"s^-1"]
        j_HNO2(t), [unit = u"s^-1"]
        j_Aceta(t), [unit = u"s^-1"]
        j_N2O(t), [unit = u"s^-1"]
        j_MeCCl3(t), [unit = u"s^-1"]
        j_Cl2O2(t), [unit = u"s^-1"]
        j_CH3Br(t), [unit = u"s^-1"]
        j_HNO3(t), [unit = u"s^-1"]
        j_CF2Cl2(t), [unit = u"s^-1"]
        j_Glyxlb(t), [unit = u"s^-1"]
        j_F141b(t), [unit = u"s^-1"]
        j_O3(t), [unit = u"s^-1"]
        j_ClNO3a(t), [unit = u"s^-1"]
        j_ActAld(t), [unit = u"s^-1"]
        j_CH2Cl2(t), [unit = u"s^-1"]
        j_O2(t), [unit = u"s^-1"]
        j_BrNO3(t), [unit = u"s^-1"]
        j_CH3OOH(t), [unit = u"s^-1"]
        j_GlyAld(t), [unit = u"s^-1"]
        j_H2COa(t), [unit = u"s^-1"]
        j_MGlyxl(t), [unit = u"s^-1"]
        j_HOBr(t), [unit = u"s^-1"]
        j_NO3a(t), [unit = u"s^-1"]
        j_NO3b(t), [unit = u"s^-1"]
        j_Acetb(t), [unit = u"s^-1"]
        j_BrCl(t), [unit = u"s^-1"]
    end

    # Actinic fluxes from the precomputed (pressure, cosSZA) interpolation table:
    # the offline precompute of the online `FastJX` (direct beam + diffuse field).
    flux_vars, fluxeqs, c_flux = flux_eqs_interpolation(cosSZA, P / P_unit, solar_flux_factor(t + t_ref))
    j_o31D_adj = adjust_j_o31D(ParentScope(T), ParentScope(P), ParentScope(H2O))

    eqs = [
        cosSZA ~ cos_solar_zenith_angle(t + t_ref, lat, long);
        fluxeqs;
        j_o32OH ~ j_O31D * j_o31D_adj.j_O31D_adj;
        j_CH3OOH ~ j_mean_CH3OOH(T / T_unit, flux_vars);
        j_NO2 ~ j_mean_NO2(T / T_unit, flux_vars);
        j_HOCl ~ j_mean_HOCl(T / T_unit, flux_vars);
        j_H2COb ~ j_mean_H2COb(T / T_unit, flux_vars);
        j_MeAcr ~ j_mean_MeAcr(T / T_unit, flux_vars);
        j_N2O5 ~ j_mean_N2O5(T / T_unit, flux_vars);
        j_H1301 ~ j_mean_H1301(T / T_unit, flux_vars);
        j_CFCl3 ~ j_mean_CFCl3(T / T_unit, flux_vars);
        j_NO ~ j_mean_NO(T / T_unit, flux_vars);
        j_Glyxlc ~ j_mean_Glyxlc(T / T_unit, flux_vars);
        j_F114 ~ j_mean_F114(T / T_unit, flux_vars);
        j_CH3NO3 ~ j_mean_CH3NO3(T / T_unit, flux_vars);
        j_CHBr3 ~ j_mean_CHBr3(T / T_unit, flux_vars);
        j_F123 ~ j_mean_F123(T / T_unit, flux_vars);
        j_CHF2Cl ~ j_mean_CHF2Cl(T / T_unit, flux_vars);
        j_OClO ~ j_mean_OClO(T / T_unit, flux_vars);
        j_H1211 ~ j_mean_H1211(T / T_unit, flux_vars);
        j_BrO ~ j_mean_BrO(T / T_unit, flux_vars);
        j_CH3Cl ~ j_mean_CH3Cl(T / T_unit, flux_vars);
        j_MEKeto ~ j_mean_MEKeto(T / T_unit, flux_vars);
        j_PAN ~ j_mean_PAN(T / T_unit, flux_vars);
        j_H2402 ~ j_mean_H2402(T / T_unit, flux_vars);
        j_PrAld ~ j_mean_PrAld(T / T_unit, flux_vars);
        j_MeVKa ~ j_mean_MeVKa(T / T_unit, flux_vars);
        j_MeVKb ~ j_mean_MeVKb(T / T_unit, flux_vars);
        j_MeVKc ~ j_mean_MeVKc(T / T_unit, flux_vars);
        j_ClNO3b ~ j_mean_ClNO3b(T / T_unit, flux_vars);
        j_F113 ~ j_mean_F113(T / T_unit, flux_vars);
        j_HNO4 ~ j_mean_HNO4(T / T_unit, flux_vars);
        j_ClO ~ j_mean_ClO(T / T_unit, flux_vars);
        j_H2O2 ~ j_mean_H2O2(T / T_unit, flux_vars);
        j_CH2Br2 ~ j_mean_CH2Br2(T / T_unit, flux_vars);
        j_OCS ~ j_mean_OCS(T / T_unit, flux_vars);
        j_F142b ~ j_mean_F142b(T / T_unit, flux_vars);
        j_F115 ~ j_mean_F115(T / T_unit, flux_vars);
        j_O31D ~ j_mean_O31D(T / T_unit, flux_vars);
        j_CF3I ~ j_mean_CF3I(T / T_unit, flux_vars);
        j_Glyxla ~ j_mean_Glyxla(T / T_unit, flux_vars);
        j_CCl4 ~ j_mean_CCl4(T / T_unit, flux_vars);
        j_Cl2 ~ j_mean_Cl2(T / T_unit, flux_vars);
        j_CH3I ~ j_mean_CH3I(T / T_unit, flux_vars);
        j_HNO2 ~ j_mean_HNO2(T / T_unit, flux_vars);
        j_Aceta ~ j_mean_Aceta(T / T_unit, flux_vars);
        j_MeCCl3 ~ j_mean_MeCCl3(T / T_unit, flux_vars);
        j_Cl2O2 ~ j_mean_Cl2O2(T / T_unit, flux_vars);
        j_CH3Br ~ j_mean_CH3Br(T / T_unit, flux_vars);
        j_HNO3 ~ j_mean_HNO3(T / T_unit, flux_vars);
        j_CF2Cl2 ~ j_mean_CF2Cl2(T / T_unit, flux_vars);
        j_Glyxlb ~ j_mean_Glyxlb(T / T_unit, flux_vars);
        j_F141b ~ j_mean_F141b(T / T_unit, flux_vars);
        j_O3 ~ j_mean_O3(T / T_unit, flux_vars);
        j_ClNO3a ~ j_mean_ClNO3a(T / T_unit, flux_vars);
        j_ActAld ~ j_mean_ActAld(T / T_unit, flux_vars);
        j_CH2Cl2 ~ j_mean_CH2Cl2(T / T_unit, flux_vars);
        j_O2 ~ j_mean_O2(T / T_unit, flux_vars);
        j_BrNO3 ~ j_mean_BrNO3(T / T_unit, flux_vars);
        j_GlyAld ~ j_mean_GlyAld(T / T_unit, flux_vars);
        j_H2COa ~ j_mean_H2COa(T / T_unit, flux_vars);
        j_MGlyxl ~ j_mean_MGlyxl(T / T_unit, flux_vars);
        j_HOBr ~ j_mean_HOBr(T / T_unit, flux_vars);
        j_NO3a ~ j_mean_NO3a(T / T_unit, flux_vars);
        j_NO3b ~ j_mean_NO3b(T / T_unit, flux_vars);
        j_Acetb ~ j_mean_Acetb(T / T_unit, flux_vars);
        j_BrCl ~ j_mean_BrCl(T / T_unit, flux_vars)
    ]

    fjx = System(
        eqs,
        t,
        [vars; flux_vars],
        [params; consts; c_flux];
        name = name,
        metadata = Dict(CoupleType => FastJXCoupler),
        systems = [j_o31D_adj]
    )
    return flatten(fjx) # Need to do flatten because otherwise coupling doesn't work correctly
end
function FastJX_interpolation(t_ref::DateTime; kwargs...)
    return FastJX_interpolation(datetime2unix(t_ref); kwargs...)
end
FastJX_interpolation(domain::DomainInfo; kwargs...) = FastJX_interpolation(get_tref(domain); kwargs...)
