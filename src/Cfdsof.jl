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
#U = setupVectorField("U", mesh, "0")
#p = setupScalarField("p", mesh, "0")
#T = setupScalarField("T", mesh, "0")

# Boundary conditions
#assignFixedValueBC(mesh, "hotFace", T, 300)
#assignFixedValueBC(mesh, "airfoil", p, 10)
#assignFixedValueBC(mesh, "empty", p, 20)
#assignFixedValueBC(mesh, "inlet", p, 30)
#assignFixedValueBC(mesh, "outlet", p, 40)

# Write outputs
#writeVtu(mesh, "src/testCases/vtu/$caseName", T)
#writeOpenFoamMesh(mesh)

printFace(mesh.faces[3])
printFace(mesh.faces[1301])

end