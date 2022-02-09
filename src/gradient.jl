include("fields.jl")

function computeGradientGauss(field)
    interpolateCellsToFaces(field, "linear")
    
    gradPhi = setupVectorField("grad$(field.name)")

    for iFace in 1:mesh.nInternalFaces
        iOwner = mesh.faces[iFace].iOwner
        iNeighbour = mesh.faces[iFace].iNeighbour

        gradPhi.cellValues[iOwner] += field.faceValues[iFace] * mesh.faces[iFace].Sf
        gradPhi.cellValues[iNeighbour] += field.faceValues[iFace] * mesh.faces[iFace].Sf
    end

    for iFace in mesh.nInternalFaces + 1:mesh.nFaces
        iOwnerB = mesh.faces[iFace].iOwner
        gradPhi.cellValues[iOwnerB] += field.faceValues[iFace] * mesh.faces[iFace].Sf
    end

    for iCell in 1:mesh.nCells
        gradPhi.cellValues[iCell] = gradPhi.cellValues[iCell] / mesh.cells[iCell].volume
    end

    return gradPhi
end