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

function setupScalarField(name, time, value=0.0)
    cellValues = [value for _ in 1:(mesh.nCells + mesh.nBoundaryFaces)]
    faceValues = [value for _ in 1:mesh.nFaces]
    return ScalarField(name, "scalar", time, cellValues, faceValues)
end

function setupVectorField(name, time, value=[0.0, 0.0, 0.0])
    cellValues = [value for _ in 1:(mesh.nCells + mesh.nBoundaryFaces)]
    faceValues = [value for _ in 1:mesh.nFaces]
    return VectorField(name, "vector", time, cellValues, faceValues)
end
