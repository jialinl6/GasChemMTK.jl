export FastJX_interpolation

@load "src/interpolations.jld2" interpolations_18

function check_P(P)
    P_result = 101325
    if P > 101325
        P_result = 101325
    elseif P < 0.5
        P_result = 0.5
    else
        P_result = P
    end
    return P_result
end
@register_symbolic check_P(P)

# Create symbolic wrapper functions for each interpolation
flux_interp_1(log_P, csa) = interpolations_18[1](log_P, csa)
flux_interp_2(log_P, csa) = interpolations_18[2](log_P, csa)
flux_interp_3(log_P, csa) = interpolations_18[3](log_P, csa)
flux_interp_4(log_P, csa) = interpolations_18[4](log_P, csa)
flux_interp_5(log_P, csa) = interpolations_18[5](log_P, csa)
flux_interp_6(log_P, csa) = interpolations_18[6](log_P, csa)
flux_interp_7(log_P, csa) = interpolations_18[7](log_P, csa)
flux_interp_8(log_P, csa) = interpolations_18[8](log_P, csa)
flux_interp_9(log_P, csa) = interpolations_18[9](log_P, csa)
flux_interp_10(log_P, csa) = interpolations_18[10](log_P, csa)
flux_interp_11(log_P, csa) = interpolations_18[11](log_P, csa)
flux_interp_12(log_P, csa) = interpolations_18[12](log_P, csa)
flux_interp_13(log_P, csa) = interpolations_18[13](log_P, csa)
flux_interp_14(log_P, csa) = interpolations_18[14](log_P, csa)
flux_interp_15(log_P, csa) = interpolations_18[15](log_P, csa)
flux_interp_16(log_P, csa) = interpolations_18[16](log_P, csa)
flux_interp_17(log_P, csa) = interpolations_18[17](log_P, csa)
flux_interp_18(log_P, csa) = interpolations_18[18](log_P, csa)

@register_symbolic flux_interp_1(log_P, csa)
@register_symbolic flux_interp_2(log_P, csa)
@register_symbolic flux_interp_3(log_P, csa)
@register_symbolic flux_interp_4(log_P, csa)
@register_symbolic flux_interp_5(log_P, csa)
@register_symbolic flux_interp_6(log_P, csa)
@register_symbolic flux_interp_7(log_P, csa)
@register_symbolic flux_interp_8(log_P, csa)
@register_symbolic flux_interp_9(log_P, csa)
@register_symbolic flux_interp_10(log_P, csa)
@register_symbolic flux_interp_11(log_P, csa)
@register_symbolic flux_interp_12(log_P, csa)
@register_symbolic flux_interp_13(log_P, csa)
@register_symbolic flux_interp_14(log_P, csa)
@register_symbolic flux_interp_15(log_P, csa)
@register_symbolic flux_interp_16(log_P, csa)
@register_symbolic flux_interp_17(log_P, csa)
@register_symbolic flux_interp_18(log_P, csa)

# Symbolic equations for actinic flux
function flux_eqs_interpolation(csa, P)
    flux_vals = []
    flux_vars = []
    @constants c_flux = 1.0 [unit = u"s^-1", description = "Constant actinic flux (for unit conversion)"]

    interpolation_funcs = [flux_interp_1, flux_interp_2, flux_interp_3, flux_interp_4, flux_interp_5, flux_interp_6,
                          flux_interp_7, flux_interp_8, flux_interp_9, flux_interp_10, flux_interp_11, flux_interp_12,
                          flux_interp_13, flux_interp_14, flux_interp_15, flux_interp_16, flux_interp_17, flux_interp_18]

    for i in 1:18
        f = interpolation_funcs[i](log(check_P(P)), csa)
        wl = WL[i]
        n1 = Symbol("F_", Int(round(wl)))
        v1 = @variables $n1(t) [unit = u"s^-1", description = "Actinic flux at $wl nm"]
        push!(flux_vars, only(v1))
        push!(flux_vals, f)
    end

    flux_vars, (flux_vars .~ flux_vals .* c_flux)
end

"""
Description: This is a box model used to calculate the photolysis reaction rate constant using the Fast-JX scheme
(Neu, J. L., Prather, M. J., and Penner, J. E. (2007), Global atmospheric chemistry: Integrating over fractional cloud cover, J. Geophys. Res., 112, D11306, doi:10.1029/2006JD008007.)

# Example
Build Fast-JX model:
``` julia
    fj = FastJX()
```
"""
function FastJX_interpolation(; name=:FastJX_interpolation)
    @constants T_unit = 1.0 [unit = u"K", description = "Unit temperature (for unit conversion)"]
    @parameters T = 298.0 [unit = u"K", description = "Temperature"]
    @parameters lat = 40.0 [description = "Latitude (Degrees)"]
    @parameters long = -97.0 [description = "Longitude (Degrees)"]
    @parameters P = 101325 [unit = u"Pa", description = "Pressure"]
    @constants P_unit = 1.0 [unit = u"Pa", description = "Unit of pressure"]
    @parameters H2O = 450 [unit = u"ppb"]

    @variables j_h2o2(t) = 1.0097 * 10.0^-5 [unit = u"s^-1"]
    @variables j_CH2Oa(t) = 0.00014 [unit = u"s^-1"]
    @variables j_CH2Ob(t) = 0.00014 [unit = u"s^-1"]
    @variables j_o31D(t) = 4.0 * 10.0^-3 [unit = u"s^-1"]
    @variables j_o32OH(t) = 2.27e-4 [unit = u"s^-1"]
    @variables j_CH3OOH(t) = 8.9573 * 10.0^-6 [unit = u"s^-1"]
    @variables j_NO2(t) = 0.0149 [unit = u"s^-1"]
    @variables cosSZA(t) [description = "Cosine of the solar zenith angle"]

    flux_vars, fluxeqs = flux_eqs_interpolation(cosSZA, P/P_unit)

    eqs = [
        cosSZA ~ cos_solar_zenith_angle(t, lat, long);
        fluxeqs;
        j_h2o2 ~ j_mean_H2O2(T/T_unit, flux_vars)*0.0557; #0.0557 is a parameter to adjust the calculated H2O2 photolysis to appropriate magnitudes.
        j_CH2Oa ~ j_mean_CH2Oa(T/T_unit, flux_vars)*0.945; #0.945 is a parameter to adjust the calculated CH2Oa photolysis to appropriate magnitudes.
        j_CH2Ob ~ j_mean_CH2Ob(T/T_unit, flux_vars)*0.813; #0.813 is a parameter to adjust the calculated CH2Ob photolysis to appropriate magnitudes.
        j_o31D ~ j_mean_o31D(T/T_unit, flux_vars)*2.33e-21; #2.33e-21 is a parameter to adjust the calculated O(^3)1D photolysis to appropriate magnitudes.
        j_o32OH ~ j_o31D*adjust_j_o31D(T, P, H2O);
        j_CH3OOH ~ j_mean_CH3OOH(T/T_unit, flux_vars)*0.0931; #0.0931 is a parameter to adjust the calculated CH3OOH photolysis to appropriate magnitudes.
        j_NO2 ~ j_mean_NO2(T/T_unit, flux_vars)*0.444 #0.444 is a parameter to adjust the calculated NO2 photolysis to appropriate magnitudes.
    ]

    ODESystem(eqs, t, [j_h2o2, j_CH2Oa, j_CH2Ob, j_o32OH, j_o31D, j_CH3OOH, j_NO2, cosSZA, flux_vars...],
      [lat, long, T, P, H2O]; name=name, metadata=Dict(:coupletype => FastJXCoupler))
end
