module Cfdsof

# Write your package code here

include("readOpenFoamMesh.jl")
include("writeOpenFoamMesh.jl")
include("fields.jl")
include("boundaryConditions.jl")
include("gradient.jl")
include("interpolation.jl")
include("output.jl")

# Case general information
caseName = "conduction1D"

# Mesh
meshPath = "src/testCases/$caseName/constant/polyMesh"
mesh = readOpenFoamMesh(meshPath)

# Setup fields
k = setupScalarField("k", "0", 1000)
T = setupScalarField("T", "0")

# Boundary conditions
assignFixedValueBC("leftWall", T, 100)
assignFixedValueBC("rightWall", T, 500)

# Interpolate field values at cell faces
interpolateCellsToFaces(k, "harmonicMean")
gradT = computeGradientGauss(T)
println(gradT)

# Write outputs
writeVtu("src/testCases/vtu/$caseName", T, k)

end