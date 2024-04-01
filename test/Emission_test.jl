using GasChem, EarthSciData
using Test, Dates, ModelingToolkit, OrdinaryDiffEq, DifferentialEquations, EarthSciMLBase, Unitful

@testset "Nei2016extension" begin
    lon = -100.0
    lat = 30.0
    lev = 1.0
    @parameters Δz = 60 [unit = u"m"]
    @parameters t [unit = u"s"]
    emis = NEI2016MonthlyEmis{Float64}("mrggrid_withbeis_withrwc", t, lon, lat, lev, Δz)

    @parameters t
    ModelingToolkit.check_units(eqs...) = nothing
    composed_ode = SuperFast(t) + FastJX(t) + emis
    sys = structural_simplify(get_mtk(composed_ode))
    @test length(states(sys)) ≈ 18
    start = Dates.datetime2unix(Dates.DateTime(2016, 5, 1))
    tspan = (start, start+3600*24*3)
    sol = solve(ODEProblem(sys, [], tspan, []),AutoTsit5(Rosenbrock23()), saveat=10.0)
    @test sol[end][end] ≈ 1.3654736679144752
end