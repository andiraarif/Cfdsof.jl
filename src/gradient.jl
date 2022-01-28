function computeGradientGauss(field)
    interpolateCellsToFaces(field, "linear")
    
    gradPhi = [[0.0, 0.0, 0.0] for _ in 1:mesh.nCells]

    for iFace in 1:mesh.nInternalFaces
        iOwner = mesh.faces[iFace].iOwner
        iNeighbour = mesh.faces[iFace].iNeighbour

        gradPhi[iOwner] += field.faceValues[iFace] * mesh.faces[iFace].Sf
        gradPhi[iNeighbour] += field.faceValues[iFace] * mesh.faces[iFace].Sf
    end

    for iFace in mesh.nInternalFaces + 1:mesh.nFaces
        iOwnerB = mesh.faces[iFace].iOwner
        gradPhi[iOwnerB] += field.faceValues[iFace] * mesh.faces[iFace].Sf
    end

    return gradPhi
end