module Cfdsof

# Write your package code here.
using BenchmarkTools

include("io.jl")
include("readOpenFoamMesh.jl")
include("writeOpenFoamMesh.jl")

caseName = "motorBike"
meshPath = "src/testCases/$caseName/constant/polyMesh"

mesh = readOpenFoamMesh(meshPath)
printMesh(mesh)
writeOpenFoamMesh(mesh)

end
