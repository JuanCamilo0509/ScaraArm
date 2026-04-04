include("../src/scaraScript.jl")
@testset "Testing the functions" begin
  stm1008 = scaraScript.Material(190.0u"GPa", 7.872u"g/cm^3")
  arm = scaraScript.createProfile(50.0u"mm", 25.0u"mm", 1.5u"mm", 200.0u"mm", stm1008)
  secondArticulation = scaraScript.createProfile(50.0u"mm", 25.0u"mm", 1.5u"mm", 140.0u"mm", stm1008)

  loads = (0:1:100)u"N"
  d = 140u"mm"

  weightOfSecondArm = scaraScript.calculateWeightPerMeter(secondArticulation)*140u"mm"
  println(uconvert(u"N", weightOfSecondArm))

  deflexions_func(f_val) = ustrip(u"mm", scaraScript.totalDeflexion(arm, 4u"N" + weightOfSecondArm, ((f_val * u"N") * d) + (weightOfSecondArm * d/2)))

  # Ahora el buscador de raíces no se quejará
  intersection(x) = deflexions_func(x) - 0.03
  intersection_x = find_zero(intersection, (0, 200))

  x_values = ustrip.(uconvert.(u"N", loads))
  y_values = deflexions_func.(x_values)

  plot(x_values, y_values, xlabel="Load", ylabel="Displacement", label="", xticks=[0:10:200...])
  hline!([0.03], label="", linestyle=:dash)
  scatter!([intersection_x], [0.03], label="", color=:white)
  annotate!(intersection_x + 10, 0.03 + 0.005,
    text("$(round(intersection_x, digits=1)) N", 8))
  savefig("output.png")

  #=println(uconvert(u"mm", scaraScript.totalDeflexion(beam, 4u"N", externalLoad*d)))=#
end
