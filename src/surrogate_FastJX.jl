export FastJX_surrogate

begin
    relu(x) = max(x, zero(x))
	pow2(x) = x^2
	pow3(x) = x^3
	sqrt_safe(x) = sqrt(abs(x)) * sign(x)
	lt(x, y) = x < y ? one(x) : zero(x)

    @register_symbolic lt(x, y)
    y_max = 1.391000027136e12

    # f_frontier_1(x1) = relu(relu((((sqrt_safe(sqrt_safe(sqrt_safe((x1 + x1) + -0.186499174049665) + 0.6621915992603807)) * 1.0607248539895426) + (sqrt_safe(sqrt_safe(sqrt_safe(x1 + x1) + 0.2874994333046278)) + 0.35047649558455163)) + sqrt_safe(x1)) * 1.8866236499091045))
    # surrogate_f_1(x1, x2) = relu(-0.00046878870266649675 - sqrt_safe(x2)) + pow3(pow2(pow3(sqrt_safe(-0.06087366953280214) * relu((f_frontier_1(x1) - x2) - sqrt_safe(pow2(pow3(-0.16237281811768559 * f_frontier_1(relu((3.187962748996749 * x1) - x2)))))))))
end

begin
    f_frontier_1(x1) = relu(relu((sqrt(abs(x1)) * sign(x1)) + ((x1 * -0.9499541493175183) - (sqrt(abs((sqrt(abs(x1 - -0.05837948915603982)) * sign(x1 - -0.05837948915603982)) * -8.592813174122051)) * sign((sqrt(abs(x1 - -0.05837948915603982)) * sign(x1 - -0.05837948915603982)) * -8.592813174122051)))))
    f_frontier_2(x1) = relu(((sqrt(abs((sqrt(abs(x1)) * sign(x1)) + 0.29023888155283445)) * sign((sqrt(abs(x1)) * sign(x1)) + 0.29023888155283445)) / 0.3513159712062025) + 0.8161439295376195)
    f_frontier_3(x1) = relu(((exp(sqrt(abs(sqrt(abs((x1 + 0.110999775909838) * 0.22629003454381663)) * sign((x1 + 0.110999775909838) * 0.22629003454381663))) * sign(sqrt(abs((x1 + 0.110999775909838) * 0.22629003454381663)) * sign((x1 + 0.110999775909838) * 0.22629003454381663))) * -1.042360885936462) ^ 2) - (sqrt(abs(((x1 + -1.3547776192307146) ^ 3) * ((sqrt(abs(x1)) * sign(x1)) + 0.2538848806290005))) * sign(((x1 + -1.3547776192307146) ^ 3) * ((sqrt(abs(x1)) * sign(x1)) + 0.2538848806290005))))
    f_frontier_4(x1) = relu((5.204620758415682 - (x1 * (x1 * (((x1 ^ 2) + -1.4453496561571682) - -0.08355964246525811)))) - (exp(x1 / -0.08355964246525811) + 0.6213428890655005))
    f_frontier_5(x1) = relu((((0.7896825240393239 / ((x1 + 0.2994872393356283) ^ 2)) - (x1 + -1.8394767762796569)) * x1) + 3.6717959630990418)
    f_frontier_6(x1) = relu((((x1 - 1.0512408825452995) ^ 3) ^ 3) + 4.997751939161557)
    f_frontier_7(x1) = relu((exp(1.005469373955424 - ((x1 * -0.03779129875211432) + ((-1.0501319032877097 - (x1 ^ 3)) * -0.019857582942996044))) ^ 2) - ((exp(x1 * -3.879093913931822) ^ 3) + 2.4354506339044892))
    f_frontier_8(x1) = relu((sqrt(abs(x1 + 0.047210366101363255)) * sign(x1 + 0.047210366101363255)) + (((x1 - (-0.3749484628803542 + relu(x1 * 1.6851106475101187))) + (sqrt(abs(x1 + 0.11098500555202585)) * sign(x1 + 0.11098500555202585))) * 5.2705425173938965))
    f_frontier_9(x1) = relu(5.325999325793277 + (-0.6840572647918038 - relu((x1 * -6.700767440157269) - -0.06031427020058291))^3)
    f_frontier_10(x1) = relu(relu(-1.2624155190907935 + (-(relu((x1 * -4.825367880271816) - 0.2098442689322133)^3) + lt(-0.21360268481378059, x1)^3) / exp(-1.8348640430863472 + relu((x1 * -4.971081011185537) - -0.3352421823304754)^3)))
    f_frontier_11(x1) = exp(1.6106297245518268 + (((((x1 + -0.8804776255666364) ^ 3) ^ 3) ^ 3) - relu(x1 * -1.8058091189922516)))
    f_frontier_12(x1) = relu(5.007264827669065 - (relu(x1 * -14.569423053669226)^2))
    f_frontier_13(x1) = relu(-10.026075105810067 + exp(2.710108214555155cos(relu(-0.035657004320672085 - (x1 * 3.703863046975125)))))
    f_frontier_14(x1) = (((x1 ^ 2) * (exp(x1) ^ 2)) + 10.565636089654483) * ((1.2663529192404486 - (sqrt(abs(x1)) * sign(x1))) * relu(sqrt(abs(x1 + 0.1353368610341767)) * sign(x1 + 0.1353368610341767)))
    f_frontier_15(x1) = (2.117904132025208 + relu(x1 / -0.07039992178850187))*relu(2.3638023050576695 - relu(x1 / -0.0657245960011023))
    f_frontier_16(x1) = 15.809143368416496relu(-0.6833523911338631 + cos(relu((x1 - -0.0043906536696337334) / -0.18624606180011472)))
    f_frontier_17(x1) = relu((x1 / ((sqrt(abs(exp(x1 / 0.008153536228293378) + exp(sqrt(abs(x1 / 0.0020643525205746023)) * sign(x1 / 0.0020643525205746023)))) * sign(exp(x1 / 0.008153536228293378) + exp(sqrt(abs(x1 / 0.0020643525205746023)) * sign(x1 / 0.0020643525205746023)))) + 0.018585261475714602)) + 5.00320910201871)
    f_frontier_18(x1) = relu((log(((sqrt(abs((x1 + 0.04221554946534485) - relu(x1))) * sign((x1 + 0.04221554946534485) - relu(x1))) + 0.7673621886924685) ^ 2) ^ 3) - -5.0026816440106625)
end

begin
    surrogate_f_1(x1,x2) = relu((relu(relu((sqrt(abs(x1)) * sign(x1)) + ((x1 * -0.9499541493175183) - (sqrt(abs((sqrt(abs(x1 - -0.05837948915603982)) * sign(x1 - -0.05837948915603982)) * -8.592813174122051)) * sign((sqrt(abs(x1 - -0.05837948915603982)) * sign(x1 - -0.05837948915603982)) * -8.592813174122051))))) - (((0.6670885573104532 + lt(x1, -0.033714798904699333))^2) * x2)) * 0.5046971025314417)^18
    surrogate_f_2(x1,x2) = sqrt(abs(relu(-1.4207015384826722 * x2)))*sign(relu(-1.4207015384826722 * x2)) + 8.490134130826437e-15(sqrt(abs(relu(relu(((sqrt(abs((sqrt(abs(x1)) * sign(x1)) + 0.29023888155283445)) * sign((sqrt(abs(x1)) * sign(x1)) + 0.29023888155283445)) / 0.3513159712062025) + 0.8161439295376195) + (-0.4435390297086485 * x2))))^36)*(sign(relu(relu(((sqrt(abs((sqrt(abs(x1)) * sign(x1)) + 0.29023888155283445)) * sign((sqrt(abs(x1)) * sign(x1)) + 0.29023888155283445)) / 0.3513159712062025) + 0.8161439295376195) + (-0.4435390297086485 * x2)))^36)*(relu(((sqrt(abs((sqrt(abs(x2)) * sign(x2)) + 0.29023888155283445)) * sign((sqrt(abs(x2)) * sign(x2)) + 0.29023888155283445)) / 0.3513159712062025) + 0.8161439295376195)^12)
    surrogate_f_3(x1,x2) = relu(relu((((x2 / -1.8803865275563452) + relu(((exp(sqrt(abs(sqrt(abs((x1 + 0.110999775909838) * 0.22629003454381663)) * sign((x1 + 0.110999775909838) * 0.22629003454381663))) * sign(sqrt(abs((x1 + 0.110999775909838) * 0.22629003454381663)) * sign((x1 + 0.110999775909838) * 0.22629003454381663))) * -1.042360885936462) ^ 2) - (sqrt(abs(((x1 + -1.3547776192307146) ^ 3) * ((sqrt(abs(x1)) * sign(x1)) + 0.2538848806290005))) * sign(((x1 + -1.3547776192307146) ^ 3) * ((sqrt(abs(x1)) * sign(x1)) + 0.2538848806290005))))) ^ 3) * 0.03270231716796285) + relu(0.07899374001873764 * ((relu(((exp(sqrt(abs(sqrt(abs((x1 + 0.110999775909838) * 0.22629003454381663)) * sign((x1 + 0.110999775909838) * 0.22629003454381663))) * sign(sqrt(abs((x1 + 0.110999775909838) * 0.22629003454381663)) * sign((x1 + 0.110999775909838) * 0.22629003454381663))) * -1.042360885936462) ^ 2) - (sqrt(abs(((x1 + -1.3547776192307146) ^ 3) * ((sqrt(abs(x1)) * sign(x1)) + 0.2538848806290005))) * sign(((x1 + -1.3547776192307146) ^ 3) * ((sqrt(abs(x1)) * sign(x1)) + 0.2538848806290005)))) + (x2 / -2.299269627954734)) * x2))^24)
    surrogate_f_4(x1,x2) = (((x2 + -0.3954537770270761) ^ 2) * relu((((((2.2425121619298904relu((5.204620758415682 - ((x1 * lt(-0.3610142601586242, x2 + x2)) * ((x1 * lt(-0.3610142601586242, x2 + x2)) * ((((x1 * lt(-0.3610142601586242, x2 + x2)) ^ 2) + -1.4453496561571682) - -0.08355964246525811)))) - (exp((x1 * lt(-0.3610142601586242, x2 + x2)) / -0.08355964246525811) + 0.6213428890655005))) - (-0.4433946197034156 * x1)) - x2) * 0.13528525189728163) ^ 3) ^ 3)) ^ 2
    surrogate_f_5(x1,x2) = (relu(x2 * -1.2144877883383363) - 0.14488947782234443(relu(-0.4173983624005615relu(x2) + relu((((0.7896825240393239 / ((((-0.03268428218421921 + x1) / (x1 + 1.3677082920842039)) + 0.2994872393356283) ^ 2)) - (((-0.03268428218421921 + x1) / (x1 + 1.3677082920842039)) + -1.8394767762796569)) * ((-0.03268428218421921 + x1) / (x1 + 1.3677082920842039))) + 3.6717959630990418))^2))^6
    surrogate_f_6(x1,x2) = (-relu(relu((((x1 - 1.0512408825452995) ^ 3) ^ 3) + 4.997751939161557) - x2) + relu(((((((2relu((((x1 - 1.0512408825452995) ^ 3) ^ 3) + 4.997751939161557)) + x1) - (x2 - 1.0176650368684033)) * 33.91280940070591) / 310.0361577572059) ^ 3) * x2)^3)^2
    surrogate_f_7(x1,x2) = 2.959377835610945e-6(relu((relu((exp(1.005469373955424 - (((x1 * 0.988043045753337) * -0.03779129875211432) + ((-1.0501319032877097 - ((x1 * 0.988043045753337) ^ 3)) * -0.019857582942996044))) ^ 2) - ((exp((x1 * 0.988043045753337) * -3.879093913931822) ^ 3) + 2.4354506339044892)) * (3.729725081918163 - (sqrt(abs((x2 + 16.79984442077766) / (sqrt(abs((x1 * 1.370328569143082) - -8.519523829910618)) * sign((x1 * 1.370328569143082) - -8.519523829910618)))) * sign((x2 + 16.79984442077766) / (sqrt(abs((x1 * 1.370328569143082) - -8.519523829910618)) * sign((x1 * 1.370328569143082) - -8.519523829910618)))))) - (sqrt(abs(x2)) * sign(x2)))^12)
    surrogate_f_8(x1,x2) = lt(x2 - relu(x1), (sign(relu((sqrt(abs(x1 + 0.047210366101363255)) * sign(x1 + 0.047210366101363255)) + (((x1 - (-0.3749484628803542 + relu(x1 * 1.6851106475101187))) + (sqrt(abs(x1 + 0.11098500555202585)) * sign(x1 + 0.11098500555202585))) * 5.2705425173938965)))^3)*(sqrt(abs(relu((sqrt(abs(x1 + 0.047210366101363255)) * sign(x1 + 0.047210366101363255)) + (((x1 - (-0.3749484628803542 + relu(x1 * 1.6851106475101187))) + (sqrt(abs(x1 + 0.11098500555202585)) * sign(x1 + 0.11098500555202585))) * 5.2705425173938965))))^3)) / exp((relu(((x2 * 0.05147684184061986) ^ 2) * x2) - (x1 ^ 3)) ^ 3)
    surrogate_f_9(x1,x2) = ((relu(x1)^4) + (lt(x2 * 0.4726936555765092, relu(relu(5.325999325793277 + (-0.6840572647918038 - relu((x1 * -6.700767440157269) - -0.06031427020058291))^3))) * (x1 + 0.12075092662028099))) ^ 2
    surrogate_f_10(x1,x2) = ((sqrt(abs(((exp(-0.24924107354340058 / x1) * relu(x1)) ^ 3) - (lt(0.4640457959536339 * x2, relu(relu(-1.2624155190907935 + (lt(-0.21360268481378059, x1 * 1.0448866140062218)^3 - (relu(((x1 * 1.0448866140062218) * -4.825367880271816) - 0.2098442689322133)^3)) / exp(-1.8348640430863472 + relu(((x1 * 1.0448866140062218) * -4.971081011185537) - -0.3352421823304754)^3)))) * (x1 + 0.12895461634205616)))) * sign(((exp(-0.24924107354340058 / x1) * relu(x1)) ^ 3) - (lt(0.4640457959536339 * x2, relu(relu(-1.2624155190907935 + (lt(-0.21360268481378059, x1 * 1.0448866140062218)^3 - (relu(((x1 * 1.0448866140062218) * -4.825367880271816) - 0.2098442689322133)^3)) / exp(-1.8348640430863472 + relu(((x1 * 1.0448866140062218) * -4.971081011185537) - -0.3352421823304754)^3)))) * (x1 + 0.12895461634205616)))) ^ 2) ^ 2
    surrogate_f_11(x1,x2) = lt(0.446573868879446 * (0.6143392678119863 + x2), exp(1.6106297245518268 + (((((x1 + -0.8804776255666364) ^ 3) ^ 3) ^ 3) - relu(x1 * -1.8058091189922516)))) + relu(x1)^9
    surrogate_f_12(x1,x2) = relu((((0.23840910170643076 - (0.3662934476653297 + x1)) * (lt(x2, relu(sign(-relu(5.007264827669065 - (relu((x1 / 1.098249146072024) * -14.569423053669226)^2)) + relu(5.007264827669065 - (relu((x1 / 1.098249146072024) * -14.569423053669226)^2))^3)*sqrt(abs(-relu(5.007264827669065 - (relu((x1 / 1.098249146072024) * -14.569423053669226)^2)) + relu(5.007264827669065 - (relu((x1 / 1.098249146072024) * -14.569423053669226)^2))^3))))^2)) - (relu(0.000832457693781088 + x1)^2)) ^ 2)
    surrogate_f_13(x1,x2) = 6.444425691664475(sign(relu(((sqrt(abs(relu(-10.026075105810067 + exp(2.710108214555155cos(relu(-0.035657004320672085 - ((cos(-4.543598701641045(lt(x2, x1 * exp(x2))^2)) * x1) * 3.703863046975125))))) / exp(sqrt(abs(x2)) * sign(x2)))) * sign(relu(-10.026075105810067 + exp(2.710108214555155cos(relu(-0.035657004320672085 - ((cos(-4.543598701641045(lt(x2, x1 * exp(x2))^2)) * x1) * 3.703863046975125))))) / exp(sqrt(abs(x2)) * sign(x2)))) + x1) - 0.3991628688064801)^3)^3)*(sqrt(abs(relu(((sqrt(abs(relu(-10.026075105810067 + exp(2.710108214555155cos(relu(-0.035657004320672085 - ((cos(-4.543598701641045(lt(x2, x1 * exp(x2))^2)) * x1) * 3.703863046975125))))) / exp(sqrt(abs(x2)) * sign(x2)))) * sign(relu(-10.026075105810067 + exp(2.710108214555155cos(relu(-0.035657004320672085 - ((cos(-4.543598701641045(lt(x2, x1 * exp(x2))^2)) * x1) * 3.703863046975125))))) / exp(sqrt(abs(x2)) * sign(x2)))) + x1) - 0.3991628688064801)^3))^3)
    surrogate_f_14(x1,x2) = relu(((((((((((x1 ^ 2) * (exp(x1) ^ 2)) + 10.565636089654483) * ((1.2663529192404486 - (sqrt(abs(x1)) * sign(x1))) * relu(sqrt(abs(x1 + 0.1353368610341767)) * sign(x1 + 0.1353368610341767)))) + ((x2 / -2.3001775176999715) / exp(x1))) / exp(relu(x1))) * 0.3201884402114485) ^ 3) + relu(x1)) ^ 3) + relu(x2 / -0.8838841009878564))
    surrogate_f_15(x1,x2) = ((0.00010382756995788228(relu(2.3638023050576695 - relu(((((-0.055529218229864924 * x2) + exp(0.09070525059603735 - 3.6827094653650114lt(x2, -0.03248872074548165))) * x1) + (-0.013375303303307844 * (x2 + -0.5059548287152843))) / -0.0657245960011023))^6)*((2.117904132025208 + relu(((((-0.055529218229864924 * x2) + exp(0.09070525059603735 - 3.6827094653650114lt(x2, -0.03248872074548165))) * x1) + (-0.013375303303307844 * (x2 + -0.5059548287152843))) / -0.07039992178850187))^6)) / exp(sqrt(abs(x1)) * sign(x1))) ^ 2
    surrogate_f_16(x1,x2) = lt(0.012980320694719199, 0.3612753939990885 * ((x2 - (29.18008756768632relu(-0.6833523911338631 + cos(relu((x1 - -0.0043906536696337334) / -0.18624606180011472))))) * -0.08711254716115147)) + (relu(x1) - (relu((x2 - (36.37007488697987relu(-0.6833523911338631 + cos(relu((x1 - -0.0043906536696337334) / -0.18624606180011472))))) * -0.08107548501137593)^4))^2
    surrogate_f_17(x1,x2) = lt((x2 / 2.339183880184318) - -0.07942019582672197, relu((0.679603703789921 * x1) + relu((x1 / ((sqrt(abs(exp(x1 / 0.008153536228293378) + exp(sqrt(abs(x1 / 0.0020643525205746023)) * sign(x1 / 0.0020643525205746023)))) * sign(exp(x1 / 0.008153536228293378) + exp(sqrt(abs(x1 / 0.0020643525205746023)) * sign(x1 / 0.0020643525205746023)))) + 0.018585261475714602)) + 5.00320910201871))) * ((x1 + (((((0.679603703789921 * x1) ^ 3) - cos(x2 / -9.428939850291082)) ^ 2) ^ 2)) ^ 2)
    surrogate_f_18(x1,x2) = lt(0.4338572156604836 * x2, relu((log(((sqrt(abs((x1 + 0.04221554946534485) - relu(x1))) * sign((x1 + 0.04221554946534485) - relu(x1))) + 0.7673621886924685) ^ 2) ^ 3) - -5.0026816440106625))
end

surrogate_funcs = [surrogate_f_1, surrogate_f_2, surrogate_f_3, surrogate_f_4, surrogate_f_5, surrogate_f_6, surrogate_f_7, surrogate_f_8, surrogate_f_9, surrogate_f_10, surrogate_f_11, surrogate_f_12, surrogate_f_13, surrogate_f_14, surrogate_f_15, surrogate_f_16, surrogate_f_17, surrogate_f_18]

# Symbolic equations for actinic flux
function flux_eqs_surrogate(csa, P)
    flux_vals = []
    flux_vars = []
    @constants c_flux = 1.0 [unit = u"s^-1", description = "Constant actinic flux (for unit conversion)"]
    
    for i in 1:18
        f = surrogate_funcs[i](csa, P)*y_max
        wl = WL[i]
        n1 = Symbol("F_", Int(round(wl)))
        v1 = @variables $n1(t) [unit = u"s^-1", description = "Actinic flux at $wl nm"]
        push!(flux_vars, only(v1))
        push!(flux_vals, f)
    end

    # for i in 12:12
    #     wl = WL[i]
    #     n = Symbol("F_", Int(round(wl)))
    #     v = @variables $n(t) [unit = u"s^-1", description = "Actinic flux at $wl nm"]
    #     push!(flux_vars, only(v))
    #     push!(flux_vals, calc_direct_flux(csa, P, i))
    # end

    # for i in 13:18
    #     f = surrogate_funcs[i](csa, P)*y_max
    #     wl = WL[i]
    #     n1 = Symbol("F_", Int(round(wl)))
    #     v1 = @variables $n1(t) [unit = u"s^-1", description = "Actinic flux at $wl nm"]
    #     push!(flux_vars, only(v1))
    #     push!(flux_vals, f)
    # end

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
function FastJX_surrogate(; name=:FastJX_surrogate)
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

    flux_vars, fluxeqs = flux_eqs_surrogate(cosSZA, log(P/P_unit))

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
