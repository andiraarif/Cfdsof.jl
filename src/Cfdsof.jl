module Cfdsof

# Write your package code here.
using BenchmarkTools

include("io.jl")
include("readOpenFoamMesh.jl")
include("writeOpenFoamMesh.jl")
include("fields.jl")
include("boundaryConditions.jl")

caseName = "cavity"
meshPath = "src/testCases/$caseName/constant/polyMesh"

mesh = readOpenFoamMesh(meshPath)

U = setupVolVectorField("U", mesh, "0")
p = setupVolScalarField("p", mesh, "0")

Uf = setupSurfaceVectorField("Uf", mesh, "0")
pf = setupSurfaceScalarField("pf", mesh, "0")

assignFixedValueBC(mesh, "movingWall", U, [2.0, 2.0, 0.0])

end