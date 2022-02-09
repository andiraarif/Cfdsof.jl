module Cfdsof

# Write your package code here

include("readOpenFoamMesh.jl")
include("writeOpenFoamMesh.jl")
include("fields.jl")
include("boundaryConditions.jl")
include("solver.jl")
include("output.jl")

# Case general information
caseName = "elbow"

# Mesh
meshPath = "src/testCases/$caseName/constant/polyMesh"
mesh = readOpenFoamMesh(meshPath)

# Setup fields
k = setupScalarField("k", 1000)
T = setupScalarField("T")

# Boundary conditions
assignBC("velocity-inlet-5", T, "fixedValue", 200)
assignBC("velocity-inlet-6", T, "fixedValue", 100)
assignBC("pressure-outlet-7", T, "fixedValue", 500)
assignBC("wall-4", T, "zeroGradient")
assignBC("wall-8", T, "zeroGradient")
assignBC("frontAndBackPlanes", T, "zeroGradient")

# Solve the equations
solveLaplacian(k, T)

# Write outputs
writeVtu("src/testCases/vtu/$caseName", T, k)

end