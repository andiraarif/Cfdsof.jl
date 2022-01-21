module Cfdsof

# Write your package code here

include("readOpenFoamMesh.jl")
include("writeOpenFoamMesh.jl")
include("fields.jl")
include("boundaryConditions.jl")
include("output.jl")

# Case general information
caseName = "elbow"

# Mesh
meshPath = "src/testCases/$caseName/constant/polyMesh"
mesh = readOpenFoamMesh(meshPath)

# Setup fields
U = setupVolVectorField("U", mesh, "0")
p = setupVolScalarField("p", mesh, "0")

Uf = setupSurfaceVectorField("Uf", mesh, "0")
pf = setupSurfaceScalarField("pf", mesh, "0")

# Boundary conditions
#assignFixedValueBC(mesh, "movingWall", U, [1.0, 0.0, 0.0])

# Write outputs

end