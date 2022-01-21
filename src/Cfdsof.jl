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
U = setupVectorField("U", mesh, "0")
p = setupScalarField("p", mesh, "0")

# Boundary conditions
#assignFixedValueBC(mesh, "movingWall", U, [1.0, 0.0, 0.0])
assignFixedValueBC(mesh, "velocity-inlet-5", U, [10.0, 0.0, 0.0])
assignFixedValueBC(mesh, "velocity-inlet-6", U, [0.0, 5.0, 0.0])

# Write outputs
writeVtuBoundary(mesh, caseName, U, p)
writeOpenFoamMesh(mesh)

end