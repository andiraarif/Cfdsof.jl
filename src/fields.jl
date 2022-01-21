mutable struct ScalarField
    name::String
    type::String
    time::String
    values::Vector{Float64}
end

mutable struct VectorField
    name::String
    type::String
    time::String
    values::Vector{Vector{Float64}}
end

function setupVolScalarField(name, mesh, time)
    field = [0.0 for _ in 1:(mesh.nCells + mesh.nBoundaryFaces)]
    return ScalarField(name, "scalar", time, field)
end

function setupVolVectorField(name, mesh, time)
    field = [[0.0, 0.0, 0.0] for _ in 1:(mesh.nCells + mesh.nBoundaryFaces)]
    return VectorField(name, "vector", time, field)
end

function setupSurfaceScalarField(name, mesh, time)
    field = [0.0 for _ in 1:mesh.nFaces]
    return ScalarField(name, "scalar", time, field)
end

function setupSurfaceVectorField(name, mesh, time)
    field = [[0.0, 0.0, 0.0] for _ in 1:mesh.nFaces]
    return VectorField(name, "vector", time, field)
end
