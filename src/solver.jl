include("boundaryConditions.jl")
include("gradient.jl")
include("interpolation.jl")
include("diffusion.jl")
include("matrix.jl")

function solveLaplacian(gamma, phi)
    interpolateCellsToFaces(gamma, "harmonicMean")

    gradPhi = computeGradientGauss(phi)
    interpolateCellsToFaces(gradPhi, "linear")

    A, B = assembleDiffusionMatrix(gamma, phi, gradPhi)

    println("Solving the diffusion matrix")
    T.cellValues[1:mesh.nCells] = A \ B

    for boundary in mesh.boundaries
        if boundary.bcType == "zeroGradient"
            assignBC(boundary.name, phi, "zeroGradient")
        end
    end
end