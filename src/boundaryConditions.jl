function findBoundaryIndex(boundaries, name)
    for boundary in boundaries
        boundary.name == name && return boundary.index
    end
end


function assignFixedValueBC(boundaryName, field, value)
    iBoundary = findBoundaryIndex(mesh.boundaries, boundaryName)
    boundary = mesh.boundaries[iBoundary]
    
    iCellStart = mesh.nCells + boundary.startFace - mesh.nInternalFaces
    iCellEnd = iCellStart + boundary.nFaces - 1

    iFaceStart = boundary.startFace
    iFaceEnd = iFaceStart + boundary.nFaces - 1
    
    field.cellValues[iCellStart:iCellEnd, :] = [value for _ in 1:boundary.nFaces]
    field.faceValues[iFaceStart:iFaceEnd, :] = [value for _ in 1:boundary.nFaces]
end