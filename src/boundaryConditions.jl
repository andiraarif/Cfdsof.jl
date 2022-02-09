function findBoundaryIndex(boundaries, name)
    for boundary in boundaries
        boundary.name == name && return boundary.index
    end
end

function assignBC(boundaryName, field, type, value=0)
    iBoundary = findBoundaryIndex(mesh.boundaries, boundaryName)
    boundary = mesh.boundaries[iBoundary]
    boundary.bcType = type
    
    iCellStart = mesh.nCells + boundary.startFace - mesh.nInternalFaces
    iCellEnd = iCellStart + boundary.nFaces - 1

    iFaceStart = boundary.startFace
    iFaceEnd = iFaceStart + boundary.nFaces - 1

    if type == "fixedValue"    
        field.cellValues[iCellStart:iCellEnd] = [value for _ in 1:boundary.nFaces]
    elseif type == "zeroGradient"
        owners = [mesh.faces[iFace].iOwner for iFace in iFaceStart:iFaceEnd]
        field.cellValues[iCellStart:iCellEnd] = [field.cellValues[iOwner] for iOwner in owners]
    end
    field.faceValues[iFaceStart:iFaceEnd] = field.cellValues[iCellStart:iCellEnd]
end