using WriteVTK

function writeVtuMesh(mesh, fileName, fields...)
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

    vtu = vtk_grid(fileName, nodes, cells)
    for field in fields
        if field.type == "scalar"
            vtu["$(field.name)"] = field.cellValues[1:mesh.nCells]
        elseif field.type == "vector"
            vtu["$(field.name)"] = transpose(mapreduce(permutedims, vcat, field.cellValues[1:mesh.nCells]))
        end
    end
    vtk_save(vtu)
end