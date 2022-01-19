function findBoundaryIndex(boundaries, name)
    for boundary in boundaries
        boundary.name == name && return boundary.index
    end
end


function assignFixedValueBC(mesh, boundaryName, var, value)
    iBoundary = findBoundaryIndex(mesh.boundaries, boundaryName)
    boundary = mesh.boundaries[iBoundary]
    iFaceStart = boundary.startFace
    iFaceEnd = iFaceStart + boundary.nFaces - 1
    var.field[iFaceStart:iFaceEnd, :] = [value for _ in 1:boundary.nFaces]
end