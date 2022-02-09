include("diffusion.jl")

function assembleDiffusionMatrix(gamma, phi, gradPhi)
    println("Assembling the diffusion matrix")
    fluxCf, fluxFf, fluxVf = assembleDiffusionTerm(gamma, phi, gradPhi)
    
    A = zeros(mesh.nCells, mesh.nCells)
    B = zeros(mesh.nCells)

    for iFace in 1:mesh.nFaces
        iOwner = mesh.faces[iFace].iOwner
        iNeighbour = mesh.faces[iFace].iNeighbour
        A[iOwner, iOwner] += fluxCf[iFace]
        B[iOwner] += -fluxVf[iFace]
        if iNeighbour != -1
            A[iNeighbour, iNeighbour] += fluxCf[iFace]
            A[iOwner, iNeighbour] += fluxFf[iFace] 
            A[iNeighbour, iOwner] += fluxFf[iFace]
        end
    end
    return A, B
end