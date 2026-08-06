@testitem "Base case" begin
    using GasChem, OrdinaryDiffEqRosenbrock, ModelingToolkit
    tspan = (0.0, 360.0)
    answer = 36.515318706326994

    rs = mtkcompile(SuperFast())
    sol = solve(
        ODEProblem(rs, [], tspan),
        Rosenbrock23(),
        saveat = 10.0,
        abstol = 1.0e-12,
        reltol = 1.0e-12
    )

    @test sol[rs.O3][end] ≈ answer
end

@testitem "ISOP sensitivity" begin
    using GasChem, OrdinaryDiffEqRosenbrock, ModelingToolkit
    tspan = (0.0, 360.0)
    u_isop = 0.06492257405177781

    rs1 = mtkcompile(SuperFast())
    o1 = solve(
        ODEProblem(rs1, [rs1.ISOP => 0.54], tspan),
        Rosenbrock23(),
        saveat = 10.0,
        abstol = 1.0e-12,
        reltol = 1.0e-12
    )
    rs2 = mtkcompile(SuperFast())
    o2 = solve(
        ODEProblem(rs2, [rs2.ISOP => 0.13], tspan),
        Rosenbrock23(),
        saveat = 10.0,
        abstol = 1.0e-12,
        reltol = 1.0e-12
    )
    test2 = o1[rs1.O3][end] - o2[rs2.O3][end]

    @test test2 ≈ u_isop
end

@testitem "NO2 sensitivity" begin
    using GasChem, OrdinaryDiffEqRosenbrock, ModelingToolkit
    tspan = (0.0, 360.0)
    u_no2 = 31.44429358563829

    rs1 = mtkcompile(SuperFast())
    o1 = solve(
        ODEProblem(rs1, [rs1.NO2 => 100.0], tspan),
        Rosenbrock23(),
        saveat = 10.0,
        abstol = 1.0e-12,
        reltol = 1.0e-12
    )
    rs2 = mtkcompile(SuperFast())
    o2 = solve(
        ODEProblem(rs2, [], tspan),
        Rosenbrock23(),
        saveat = 10.0,
        abstol = 1.0e-12,
        reltol = 1.0e-12
    )
    test3 = o1[rs1.O3][end] - o2[rs2.O3][end]

    @test test3 ≈ u_no2
end

@testitem "CO sensitivity" begin
    using GasChem, OrdinaryDiffEqRosenbrock, ModelingToolkit
    tspan = (0.0, 360.0)
    u_co = -0.2759355413868789

    rs1 = mtkcompile(SuperFast())
    o1 = solve(
        ODEProblem(rs1, [rs1.CO => 50.0], tspan),
        Rosenbrock23(),
        saveat = 10.0,
        abstol = 1.0e-12,
        reltol = 1.0e-12
    )
    rs2 = mtkcompile(SuperFast())
    o2 = solve(
        ODEProblem(rs2, [rs2.CO => 500.0], tspan),
        Rosenbrock23(),
        saveat = 10.0,
        abstol = 1.0e-12,
        reltol = 1.0e-12
    )
    test4 = o1[rs1.O3][end] - o2[rs2.O3][end]

    @test test4 ≈ u_co
end

@testitem "CH4 sensitivity" begin
    using GasChem, OrdinaryDiffEqRosenbrock, ModelingToolkit
    tspan = (0.0, 360.0)
    u_ch4 = 0.009530481509528954

    rs1 = mtkcompile(SuperFast())
    o1 = solve(
        ODEProblem(rs1, [rs1.CH4 => 1900.0], tspan),
        Rosenbrock23(),
        saveat = 10.0,
        abstol = 1.0e-12,
        reltol = 1.0e-12
    )
    rs2 = mtkcompile(SuperFast())
    o2 = solve(
        ODEProblem(rs2, [rs2.CH4 => 1600.0], tspan),
        Rosenbrock23(),
        saveat = 10.0,
        abstol = 1.0e-12,
        reltol = 1.0e-12
    )
    test5 = o1[rs1.O3][end] - o2[rs1.O3][end]

    @test test5 ≈ u_ch4
end
