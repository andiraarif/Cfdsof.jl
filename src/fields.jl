mutable struct ScalarField
    name::String
    type::String
    time::String
    cellValues::Vector{Float64}
    faceValues::Vector{Float64}
end

mutable struct VectorField
    name::String
    type::String
    time::String
    cellValues::Vector{Vector{Float64}}
    faceValues::Vector{Vector{Float64}}
end

function setupScalarField(name, mesh, time)
    cellValues = [10.0 for _ in 1:(mesh.nCells + mesh.nBoundaryFaces)]
    faceValues = [0.0 for _ in 1:mesh.nFaces]
    return ScalarField(name, "scalar", time, cellValues, faceValues)
end

function setupVectorField(name, mesh, time)
    cellValues = [[0.0, 0.0, 0.0] for _ in 1:(mesh.nCells + mesh.nBoundaryFaces)]
    faceValues = [[0.0, 0.0, 0.0] for _ in 1:mesh.nFaces]
    return VectorField(name, "vector", time, cellValues, faceValues)
end
