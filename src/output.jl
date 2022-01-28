using WriteVTK

function writeVtu(mesh, fileName, fields...)
    println("Writing output in vtu format")
    x = [mesh.nodes[i].centroid[1] for i in 1:length(mesh.nodes)]
    y = [mesh.nodes[i].centroid[2] for i in 1:length(mesh.nodes)]
    z = [mesh.nodes[i].centroid[3] for i in 1:length(mesh.nodes)]
    nodes = transpose(hcat(x, y, z))
    
    cells = VTKPolyhedron[]    
    for iCell in 1:mesh.nCells
        cell = mesh.cells[iCell]
        faces = []
        for iFace in cell.iFaces
            push!(faces, mesh.faces[iFace].iNodes)
        end
        polyCell = VTKPolyhedron(cell.iNodes, faces...)
        push!(cells, polyCell)
    end

    for iFace in 1:mesh.nBoundaryFaces
        face = mesh.faces[mesh.nInternalFaces + iFace]
        lines = []
        for i in 1:length(face.iNodes)
            iStart = face.iNodes[i]
            iEnd = i < length(face.iNodes) ? face.iNodes[i + 1] : face.iNodes[1]
            push!(lines, [iEnd, iStart, iStart, iEnd])
        end
        polyFace = VTKPolyhedron(face.iNodes, lines...)
        push!(cells, polyFace)
    end

    vtu = vtk_grid(fileName, nodes, cells)
    for field in fields
        if field.type == "scalar"
            vtu["$(field.name)"] = field.cellValues
        elseif field.type == "vector"
            vtu["$(field.name)"] = transpose(mapreduce(permutedims, vcat, field.cellValues))
        end
    end
    vtk_save(vtu)
end
