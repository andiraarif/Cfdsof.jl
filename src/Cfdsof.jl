module Cfdsof

# Write your package code here

include("readOpenFoamMesh.jl")
include("writeOpenFoamMesh.jl")
include("fields.jl")
include("boundaryConditions.jl")
include("output.jl")

# Case general information
caseName = "cavity"

# Mesh
meshPath = "src/testCases/$caseName/constant/polyMesh"
mesh = readOpenFoamMesh(meshPath)

# Setup fields
U = setupVectorField("U", mesh, "0")
p = setupScalarField("p", mesh, "0")

# Boundary conditions
assignFixedValueBC(mesh, "movingWall", U, [1.0, 0.0, 0.0])
assignFixedValueBC(mesh, "movingWall", p, 10)

U.cellValues[2:4,:] = [[1,2,1], [1,1,1], [2,3,3]]

# Write outputs
writeVtuMesh(mesh, caseName, U, p)
end