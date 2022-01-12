module Cfdsof

# Write your package code here.
using BenchmarkTools

include("io.jl")
include("readOpenFoamMesh.jl")
include("writeOpenFoamMesh.jl")

meshPath = "src/testCases/motorBike/constant/polyMesh"

mesh = readOpenFoamMesh(meshPath)
printMesh(mesh)
@time writeOpenFoamMesh(mesh)

end
