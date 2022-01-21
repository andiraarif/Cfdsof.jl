using WriteVTK

function writeVtuMesh(mesh, fileName, fields...)
    x = [mesh.nodes[i].centroid[1] for i in 1:length(mesh.nodes)]
    y = [mesh.nodes[i].centroid[2] for i in 1:length(mesh.nodes)]
    z = [mesh.nodes[i].centroid[3] for i in 1:length(mesh.nodes)]
    cells = VTKPolyhedron[]
    
    nodes = transpose(hcat(x, y, z))

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
    vtu["U"] = transpose(mapreduce(permutedims, vcat, fields[1].cellValues))
    vtu["p"] = fields[2].cellValues
    vtk_save(vtu)
end