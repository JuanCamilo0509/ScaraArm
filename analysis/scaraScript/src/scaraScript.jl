module scaraScript
using Unitful
using Plots
using Roots

const LengthUnit = Unitful.Quantity{T,Unitful.𝐋} where {T}
const PressureUnit = Unitful.Quantity{T,Unitful.𝐌 * Unitful.𝐋^-1 * Unitful.𝐓^-2} where {T}
const DensityUnit = Unitful.Quantity{T,Unitful.𝐌 * Unitful.𝐋^-3} where {T}
const InertiaUnit = Unitful.Quantity{T,Unitful.𝐋^4} where {T}

struct Material
  E::PressureUnit
  ρ::DensityUnit
end

mutable struct Profile
  base::LengthUnit
  height::LengthUnit
  thickness::LengthUnit
  length::LengthUnit
  material::Material
  I::InertiaUnit
end

function createProfile(base, height, thickness, length, material::Material)
  p = Profile(base, height, thickness, length, material, 0u"mm^4")
  calculateInertia!(p)
  return p
end

function calculateInertia!(p::Profile)
  p.I = (1 / 12) * ((p.base * p.height^3) - ((p.base - 2p.thickness) * (p.height - 2 * p.thickness)^3))
end

function maxDeformationForLoad(p::Profile, load)
  return (load * p.length^3) / (3p.I * p.material.E)
end

function maxDeformationForMoment(p::Profile, M)
  return (M * p.length^2) / (2p.material.E * p.I)
end

function calculateWeightPerMeter(p::Profile)
  g = 9.81u"m/s^2"
  sectionArea = (2p.thickness * (p.base + p.height - 2 * p.thickness))
  return p.material.ρ * sectionArea * g
end

function maxDeformationForWeight(p::Profile)
  return calculateWeightPerMeter(p) * p.length^4 / (8 * p.material.E * p.I)
end

function totalDeflexion(p::Profile, mL, M)
  return maxDeformationForWeight(p) + maxDeformationForLoad(p, mL) + maxDeformationForMoment(p, M)
end

end # module scaraScript
