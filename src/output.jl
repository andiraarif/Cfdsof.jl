using WriteVTK

function writeVtu(mesh, fileName, fields...)
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

    for iFace in (mesh.nCells + 1):length(fields[1].cellValues)
        face = mesh.faces[mesh.nInternalFaces + (iFace - mesh.nCells)]
        lines = []
        for i in 1:length(face.iNodes)
            iStart = face.iNodes[i]
            iEnd = i < length(face.iNodes) ? face.iNodes[i + 1] : face.iNodes[1]
            push!(lines, [iStart, iEnd, iEnd, iStart])
        end 
        polyFace = VTKPolyhedron(face.iNodes, lines...)
        push!(cells, polyFace)
    end

    vtu = vtk_grid(fileName, nodes, cells)
    for field in fields
        if field.type == "scalar"
            vtu["$(field.name)"] = field.cellValues #[1:mesh.nCells]
        elseif field.type == "vector"
            vtu["$(field.name)"] = transpose(mapreduce(permutedims, vcat, field.cellValues)) #[1:mesh.nCells]))
        end
    end
    vtk_save(vtu)
end


function writeVtuBoundary(mesh, fileName, fields...)
    x = [mesh.nodes[i].centroid[1] for i in 1:length(mesh.nodes)]
    y = [mesh.nodes[i].centroid[2] for i in 1:length(mesh.nodes)]
    z = [mesh.nodes[i].centroid[3] for i in 1:length(mesh.nodes)]
    nodes = transpose(hcat(x, y, z))
    
    cells = VTKPolyhedron[]    
    for iFace in 1:mesh.nBoundaryFaces
        face = mesh.faces[mesh.nInternalFaces + iFace]
        #println(face.iNodes)
        lines = []
        for i in 1:length(face.iNodes)
            iStart = face.iNodes[i]
            iEnd = i < length(face.iNodes) ? face.iNodes[i + 1] : face.iNodes[1]
            push!(lines, [iEnd, iStart, iStart, iEnd])
        end
        polyFace = VTKPolyhedron(face.iNodes, lines...)
        push!(cells, polyFace)
    end

    vtu = vtk_grid("$(fileName)_boundary", nodes, cells)
    for field in fields
        if field.type == "scalar"
            vtu["$(field.name)"] = field.cellValues[mesh.nCells + 1:end]
        elseif field.type == "vector"
            vtu["$(field.name)"] = transpose(mapreduce(permutedims, vcat, field.cellValues[mesh.nCells + 1:end]))
        end
    end
    vtk_save(vtu)
end