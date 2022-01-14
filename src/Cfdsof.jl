module Cfdsof

# Write your package code here.
using BenchmarkTools

include("io.jl")
include("readOpenFoamMesh.jl")
include("writeOpenFoamMesh.jl")

caseName = "elbow"
meshPath = "src/testCases/$caseName/constant/polyMesh"

mesh = readOpenFoamMesh(meshPath)
printMesh(mesh)
printNode(mesh.nodes[1])
printFace(mesh.faces[3])
printCell(mesh.cells[20])
printCell(mesh.cells[300])
printFace(mesh.faces[1301])
writeOpenFoamMesh(mesh)

end
