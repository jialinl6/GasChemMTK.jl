export SuperFast

struct SuperFastCoupler
    sys
end

"""
    SuperFast()

This atmospheric chemical system model is built based on the Super Fast Chemical Mechanism, which is one of the simplest representations of atmospheric chemistry. It can efficiently simulate background tropheric ozone chemistry and perform well for those species included in the mechanism. The chemical equations we used is included in the supporting table S2 of the paper:

"Evaluating simplified chemical mechanisms within present-day simulations of the Community Earth System Model version 1.2 with CAM4 (CESM1.2 CAM-chem):
MOZART-4 vs. Reduced Hydrocarbon vs. Super-Fast chemistry" (2018), Benjamin Brown-Steiner, Noelle E. Selin, Ronald G. Prinn, Simone Tilmes, Louisa Emmons, Jean-François Lamarque, and Philip Cameron-Smith.

The input of the function is Temperature, concentrations of all chemicals, and reaction rates of photolysis reactions 

If the keyword argument `rxn_sys` is set to `true`, the function will return a reaction system instead of an ODE system.

# Example
```
using GasChem, EarthSciMLBase, DifferentialEquations, Plots
rs = SuperFast()
sol = solve(ODEProblem(structural_simplify(rs), [], (0,360), [], combinatoric_ratelaws=false), Tsit5())
plot(sol)
```
"""
function SuperFast(;name=:SuperFast, rxn_sys=false)
    @constants A = 6.02e23 [unit = u"molec/mol", description = "Avogadro's number"]
    params = @parameters(
        jO31D = 4.0e-3, [unit = u"s^-1"],
        jH2O2 = 1.0097e-5, [unit = u"s^-1"],
        jNO2 = 0.0149, [unit = u"s^-1"],
        jCH2Oa = 0.00014, [unit = u"s^-1"],
        jCH2Ob = 0.00014, [unit = u"s^-1"],
        jCH3OOH = 8.9573e-6, [unit = u"s^-1"],
        k1 = 1.7e-12, [unit = u"cm^3/molec/s"], T1 = -940, [unit = u"K"],
        k2 = 1.0e-14, [unit = u"cm^3/molec/s"], T2 = -490, [unit = u"K"],
        k3 = 4.8e-11, [unit = u"cm^3/molec/s"], T3 = 250, [unit = u"K"],
        k4 = 3.0e-12, [unit = u"cm^3/molec/s"], T4 = -1500, [unit = u"K"],
        k5 = 3.5e-12, [unit = u"cm^3/molec/s"], T5 = 250, [unit = u"K"],
        k6 = 2.45e-12, [unit = u"cm^3/molec/s"], T6 = -1775, [unit = u"K"],
        k7 = 5.5e-12, [unit = u"cm^3/molec/s"], T7 = 125, [unit = u"K"],
        k8 = 4.1e-13, [unit = u"cm^3/molec/s"], T8 = 750, [unit = u"K"],
        k9 = 2.7e-12, [unit = u"cm^3/molec/s"], T9 = 200, [unit = u"K"],
        k11 = 2.8e-12, [unit = u"cm^3/molec/s"], T11 = 300, [unit = u"K"],
        k12 = 9.5e-14, [unit = u"cm^3/molec/s"], T12 = 390, [unit = u"K"],
        k13 = 1.1e-11, [unit = u"cm^3/molec/s"], T13 = -240, [unit = u"K"],
        k14 = 2.7e-11, [unit = u"cm^3/molec/s"], T14 = 390, [unit = u"K"],
        k15 = 2.7e-11, [unit = u"cm^3/molec/s"], T15 = 390, [unit = u"K"],
        k16 = 5.59e-15, [unit = u"cm^3/molec/s"], T16 = -1814, [unit = u"K"],
        k17 = 3.0e-13, [unit = u"cm^3/molec/s"], T17 = 460, [unit = u"K"], #HO2 + HO2 = H2O2 + O2
        k18 = 1.8e-12, [unit = u"cm^3/molec/s"],
        k19 = 1.5e-13, [unit = u"cm^3/molec/s"], #OH + CO = HO2
        k20 = 4.0e-24, [unit = u"cm^3/molec/s"], #H2O + NO2 = 0.500HNO3
        ko1d = 1.45e-10, [unit = u"cm^3/molec/s"], To1d = 89, [unit = u"K"],
        k_unit = 1, [unit = u"cm^3/molec/s"],
        T = 280.0, [unit = u"K", description = "Temperature"],
        P = 101325, [unit = u"Pa", description = "Pressure (not directly used)"],
        num_density_unit_inv = 1, [unit = u"cm^3/molec", description = "multiply by num_density to obtain the unitless value of num_density"],
        K_unit = 1, [unit = u"K", description = "unit of Temperature"],
        # O2 = 2.1e8, [isconstantspecies=true,unit = u"ppb"],
        # CH4 = 1700.0, [isconstantspecies=true, unit = u"ppb"],
        ppb_unit = 1e-9, [unit = u"ppb", description = "Convert from mol/mol_air to ppb"],
        ppb_inv = 1, [unit = u"ppb^-1"],
        hPa_P = 0.01, [unit = u"Pa^-1", description = "multiply by pressure with unit of Pa and obtain the unitless value in unit of hPa"],
    )

    species = @species(
        O3(t) = 10.0, [unit = u"ppb"],
        O1d(t) = 0.00001, [unit = u"ppb"],
        OH(t) = 10.0, [unit = u"ppb"],
        HO2(t) = 10.0, [unit = u"ppb"],
        H2O(t) = 450.0, [unit = u"ppb"],
        NO(t) = 0.0, [unit = u"ppb"],
        NO2(t) = 10.0, [unit = u"ppb"],
        CH3O2(t) = 0.01, [unit = u"ppb"],
        CH2O(t) = 0.15, [unit = u"ppb"],
        CO(t) = 275.0, [unit = u"ppb"],
        CH3OOH(t) = 1.6, [unit = u"ppb"],
        DMS(t) = 50, [unit = u"ppb"],
        SO2(t) = 2.0, [unit = u"ppb"],
        ISOP(t) = 0.15, [unit = u"ppb"],
        H2O2(t) = 2.34, [unit = u"ppb"],
        HNO3(t) = 10, [unit = u"ppb"],
        O2(t) = 2.1e8, [unit = u"ppb"],
        CH4(t) = 1700.0, [unit = u"ppb"],
    )

    @constants R = 8.314e6 [unit = u"(Pa*cm^3)/(K*mol)", description = "universal gas constant"]
    air_volume = R*T/P #unit in cm^3/mol
    num_density = A / air_volume # number density of air, unit in "molec/cm³"
    num_density_unitless = num_density*num_density_unit_inv
    c = A / air_volume * ppb_unit #Convert the second reaction rate value, which corresponds to species with units of molec/cm³, to ppb.
    rate2(k, Tc) = k * exp(Tc / T) * c

    # Used to calculate the 3 body reaction rate
    function arr3(a1, b1, c1, a2, b2, c2, fv)
        arr(a0,b0,c0) = a0 * exp(c0*K_unit / T) * (300*K_unit / T)^b0
        alow = arr(a1, b1, c1)
        ahigh = arr(a2, b2, c2)
        rlow = alow * num_density_unitless
        rhigh = ahigh
        xyrat = rlow / rhigh
        blog = log10(xyrat)
        fexp = 1.0 / (1.0 + (blog * blog))
        k = rlow * (fv^fexp) / (1.0 + xyrat)
        return k*k_unit*c
    end

    # Used to compute the rate for this reaction: HO2 + HO2 = H2O2 + O2, function "C_HO2NO3" in GEOS-CHEM
    function rate_HO2HO2(a0, b0, c0, a1, b1, c1)
        arr(a0,b0,c0) = a0 * exp(c0*K_unit / T) * (300*K_unit / T)^b0
        R0 = arr(a0, b0, c0)
        R1 = arr(a1, b1, c1)
        
        cH2O = H2O*ppb_inv*1e-9*num_density_unitless # concentration of H2O in unit of molec/cm3, but here is unitless
        result = (R0 + R1 * num_density_unitless) * (1.0 + 1.4e-21 * cH2O * exp(2200.0*K_unit / T))
        return result*k_unit*c
    end

    # Used to compute the rate for this reaction: OH + CO = HO2, function "GC_OHCO" in GEOS-CHEM
    function rate_OHCO(a,b,c)
        arr(a0,b0,c0) = a0 * exp(c0*K_unit / T) * (300*K_unit / T)^b0
        R0 = arr(a,b,c)*(1.0 + 0.6 * 9.871e7 * P*hPa_P)
        
        # New OH+CO rate from JPL2006
        KLO1 = 5.9e-33 * (300*K_unit / T)^1.0
        KHI1 = 1.1e-12 * (300*K_unit / T)^(-1.3)
        XYRAT1 = KLO1 * num_density_unitless / KHI1
        BLOG1 = log10(XYRAT1)
        FEXP1 = 1.0 / (1.0 + BLOG1^2)
        KCO1 = KLO1 * num_density_unitless * 0.6^FEXP1 / (1.0 + XYRAT1)
        
        KLO2 = 1.5e-13 * (300*K_unit / T)^0.0
        KHI2 = 2.1e9 * (300*K_unit / T)^(-6.1)
        XYRAT2 = KLO2 * num_density_unitless / KHI2
        BLOG2 = log10(XYRAT2)
        FEXP2 = 1.0 / (1.0 + BLOG2^2)
        KCO2 = KLO2 * 0.6^FEXP2 / (1.0 + XYRAT2)
        
        KCO = KCO1 + KCO2
        return KCO*k_unit*c
    end

    # Create reaction system, ignoring aqueous chemistry.
    rxs = [
        #O3 + OH --> HO2 + O2
        Reaction(rate2(k1, T1), [O3, OH], [HO2, O2], [1, 1], [1, 1])
        #HO2 + O3 --> 2O2 + OH
        Reaction(rate2(k2, T2), [HO2, O3], [O2, OH], [1, 1], [2, 1])
        #HO2 + OH --> H2O + O2
        Reaction(rate2(k3, T3), [HO2, OH], [HO2, O2], [1, 1], [1, 1])
        #HO2 + HO2 = H2O2 + O2
        Reaction(rate_HO2HO2(3e-13, 0.0, 460.0, 2.1e-33, 0.0, 920.0), [HO2], [H2O2, O2], [2], [1, 1])
        #OH + H2O2 = H2O + HO2
        Reaction(k18* A / air_volume * ppb_unit, [OH, H2O2], [H2O, HO2], [1, 1], [1, 1])
        #OH + CO = HO2
        Reaction(rate_OHCO(1.5e-13, 0.0, 0.0), [OH, CO], [HO2], [1, 1], [1])
        #NO + O3 --> NO2 + O2
        Reaction(rate2(k4, T4), [NO, O3], [NO2, O2], [1, 1], [1, 1])
        #NO2 + OH {+M} --> HNO3 {+M}
        Reaction(arr3(1.8e30, 3.0, 0.0, 2.8e-11, 0.0, 0.0, 0.6), [NO2, OH], [HNO3])
        #H2O + NO2 --> 0.5HNO3
        Reaction(k20*c, [H2O, NO2], [HNO3], [1, 1.0], [0.5])
        #HO2 + NO --> NO2 + OH 
        Reaction(rate2(k5, T5), [HO2, NO], [NO2, OH], [1, 1], [1, 1])
        #CH4 + OH --> CH3O2 + H2O
        Reaction(rate2(k6, T6), [CH4, OH], [CH3O2, H2O], [1, 1], [1, 1])
        #CH2O + OH --> CO + H2O + HO2
        Reaction(rate2(k7, T7), [CH2O, OH], [CO, H2O, HO2], [1, 1], [1, 1, 1])
        #CH3O2 + HO2 --> CH3OOH + O2
        Reaction(rate2(k8, T8), [CH3O2, HO2], [CH3OOH, O2], [1, 1], [1, 1])
        #CH3OOH + OH --> CH3O2 + H2O
        Reaction(rate2(k9, T9), [CH3OOH, OH], [CH3O2, H2O], [1, 1], [1, 1])
        #CH3O2 + NO --> CH2O + HO2 + NO2    
        Reaction(rate2(k11, T11), [CH3O2, NO], [CH2O, HO2, NO2], [1, 1], [1, 1, 1])
        #CH3O2 + CH3O2 --> 2CH2O + 0.8HO2
        Reaction(rate2(k12, T12), [CH3O2], [CH2O, H2O], [2], [2, 0.8])
        #DMS + OH --> SO2
        Reaction(rate2(k13, T13), [DMS, OH], [SO2], [1, 1], [1])
        #ISOP +OH --> 2CH3O2
        Reaction(rate2(k14, T14), [ISOP, OH], [CH3O2], [1, 1], [2])
        #ISOP + OH --> ISOP
        Reaction(rate2(k14, T14), [ISOP, OH], [ISOP])
        #ISOP + OH --> ISOP + 0.5OH
        Reaction(rate2(k15, T15), [ISOP, OH], [ISOP, OH], [1, 1.0], [1, 0.5])
        #ISOP + O3 --> 0.87CH2O + 1.86CH3O2 + 0.06HO2 + 0.05CO
        Reaction(rate2(k16, T16), [ISOP, O3], [CH2O, CH3O2, HO2, CO], [1, 1.0], [0.87, 1.86, 0.06, 0.05])
        #O3 -> O2 + O(1D)
        Reaction(jO31D * 1e-21, [O3], [O1d, O2], [1], [1, 1]) # TODO(JL): Is 10^(-20) a reasonable value?
        #O(1D) + H2O -> 2OH
        Reaction(rate2(ko1d, To1d), [O1d, H2O], [OH], [1, 1], [2]) 
        #H2O2 --> 2OH
        Reaction(jH2O2, [H2O2], [OH], [1], [2])
        #NO2 --> NO + O3
        Reaction(jNO2, [NO2], [NO, O3], [1], [1, 1])
        #CH2O --> CO + 2HO2
        Reaction(jCH2Oa, [CH2O], [CO, HO2], [1], [1, 2])
        #CH2O --> CO
        Reaction(jCH2Ob, [CH2O], [CO], [1], [1])
        #CH3OOH --> CH2O + HO2 + OH
        Reaction(jCH3OOH, [CH3OOH], [CH2O, HO2, OH], [1], [1, 1, 1])
    ]
    # We set `combinatoric_ratelaws=false` because we are modeling macroscopic rather than microscopic behavior. 
    # See [here](https://docs.juliahub.com/ModelingToolkit/Qmdqu/3.14.0/systems/ReactionSystem/#ModelingToolkit.oderatelaw) 
    # and [here](https://github.com/SciML/Catalyst.jl/issues/311).
    rxns = ReactionSystem(rxs, t, species, params; combinatoric_ratelaws=false, name=name)
    if rxn_sys
        return rxns
    end
    convert(ODESystem, complete(rxns); metadata=Dict(:coupletype => SuperFastCoupler))
end
