using WriteVTK

function writeSimplestOutput(mesh, field)
    xCells = [mesh.cells[i].centroid[1] for i in 1:mesh.nCells]
    yCells = [mesh.cells[i].centroid[2] for i in 1:mesh.nCells]
    zCells = [mesh.cells[i].centroid[3] for i in 1:mesh.nCells]

    iBoundaryStart = mesh.boundaries[1].startFace
    iBoundaryEnd = iBoundaryStart + mesh.nBoundaryFaces - 1

    xBoundaries = [mesh.faces[i].centroid[1] for i in iBoundaryStart:iBoundaryEnd]
    yBoundaries = [mesh.faces[i].centroid[2] for i in iBoundaryStart:iBoundaryEnd]
    zBoundaries = [mesh.faces[i].centroid[3] for i in iBoundaryStart:iBoundaryEnd]

    x = [mesh.nodes[i].centroid[1] for i in 1:length(mesh.nodes)]
    y = [mesh.nodes[i].centroid[2] for i in 1:length(mesh.nodes)]
    z = [mesh.nodes[i].centroid[3] for i in 1:length(mesh.nodes)]
    cells = MeshCell[]

    for iCell in 1:mesh.nCells
        #println(mesh.cells[iCell].iNodes)
        cell = MeshCell(VTKCellTypes.VTK_HEXAHEDRON, mesh.cells[iCell].iNodes)
        push!(cells, cell)
    end

    vtk = vtk_grid("airFoil", hcat(x, y, z), cells)
    vtk_save(vtk)

    #=
    points = rand(3, 5)  # 5 points in three dimensions
    cells = [MeshCell(VTKCellTypes.VTK_TRIANGLE, [1, 4, 2]),
    MeshCell(VTKCellTypes.VTK_QUAD,     [2, 4, 3, 5])]
   

    vtk = vtk_grid("filename", points, cells)
    vtk_save(vtk)
     =#
end