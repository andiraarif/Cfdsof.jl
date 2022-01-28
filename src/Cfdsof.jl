module Cfdsof

# Write your package code here

include("readOpenFoamMesh.jl")
include("writeOpenFoamMesh.jl")
include("fields.jl")
include("boundaryConditions.jl")
include("output.jl")

# Case general information
caseName = "conduction1D"

# Mesh
meshPath = "src/testCases/$caseName/constant/polyMesh"
mesh = readOpenFoamMesh(meshPath)

# Setup fields
T = setupScalarField(mesh, "T", "0")

# Boundary conditions
assignFixedValueBC(mesh, "leftWall", T, 100)
assignFixedValueBC(mesh, "rightWall", T, 500)

# Write outputs
writeVtu(mesh, "src/testCases/vtu/$caseName", T)

for face in mesh.faces
    println("Face number $(face.index) - Sf : ($(face.sf[1]) $(face.sf[2]) $(face.sf[3]))")
end

end