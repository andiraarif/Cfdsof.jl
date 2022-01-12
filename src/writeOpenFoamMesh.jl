function writePolyMeshPoints(nodes)
    open("src/testCases/writeMesh/constant/polyMesh/points", "w") do f
    write(f, "FoamFile\n")
    write(f, "{\n")
    write(f, "    version     2.0;\n")
    write(f, "    format      ascii;\n")
    write(f, "    arch        \"LSB;label=32;scalar=64\";\n")
    write(f, "    class       vectorField;\n")
    write(f, "    location    \"constant/polyMesh\";\n")
    write(f, "    object      points;\n")
    write(f, "}\n")
    write(f, "$(length(nodes))\n")
    write(f, "(\n")
    for node in nodes
        write(f, "($(node.centroid[1]) $(node.centroid[2]) $(node.centroid[3]))\n")
    end
    write(f, ")\n")
    end
end

function writePolyMeshFaces(faces)
    open("src/testCases/writeMesh/constant/polyMesh/faces", "w") do f
    write(f, "FoamFile\n")
    write(f, "{\n")
    write(f, "    version     2.0;\n")
    write(f, "    format      ascii;\n")
    write(f, "    arch        \"LSB;label=32;scalar=64\";\n")
    write(f, "    class       faceList;\n")
    write(f, "    location    \"constant/polyMesh\";\n")
    write(f, "    object      faces;\n")
    write(f, "}\n")
    write(f, "$(length(faces))\n")
    write(f, "(\n")
    for face in faces
        write(f, "$(length(face.iNodes))")
        write(f, "(")
        for iNode in face.iNodes
            write(f, " $(iNode - 1)")
        end
        write(f, ")\n")
    end
    write(f, ")\n")
    end
end

function writePolyMeshOwner(faces)
    open("src/testCases/writeMesh/constant/polyMesh/owner", "w") do f
    write(f, "FoamFile\n")
    write(f, "{\n")
    write(f, "    version     2.0;\n")
    write(f, "    format      ascii;\n")
    write(f, "    arch        \"LSB;label=32;scalar=64\";\n")
    write(f, "    class       labelList;\n")
    write(f, "    location    \"constant/polyMesh\";\n")
    write(f, "    object      owner;\n")
    write(f, "}\n")
    write(f, "$(length(faces))\n")
    write(f, "(\n")
    for face in faces
        write(f, "$(face.iOwner - 1)\n")
    end
    write(f, ")\n")
    end
end

function writePolyMeshNeighbour(faces, boundaries)
    open("src/testCases/writeMesh/constant/polyMesh/neighbour", "w") do f
    write(f, "FoamFile\n")
    write(f, "{\n")
    write(f, "    version     2.0;\n")
    write(f, "    format      ascii;\n")
    write(f, "    arch        \"LSB;label=32;scalar=64\";\n")
    write(f, "    class       labelList;\n")
    write(f, "    location    \"constant/polyMesh\";\n")
    write(f, "    object      neighbour;\n")
    write(f, "}\n")
    write(f, "$(boundaries[1].startFace - 1)\n")
    write(f, "(\n")
    for iFace in 1:boundaries[1].startFace - 1
        write(f, "$(faces[iFace].iNeighbour - 1)\n")
    end
    write(f, ")\n")
    end
end

function writePolyMeshBoundaries(boundaries)
    open("src/testCases/writeMesh/constant/polyMesh/boundary", "w") do f
    write(f, "FoamFile\n")
    write(f, "{\n")
    write(f, "    version     2.0;\n")
    write(f, "    format      ascii;\n")
    write(f, "    arch        \"LSB;label=32;scalar=64\";\n")
    write(f, "    class       polyBoundaryMesh;\n")
    write(f, "    location    \"constant/polyMesh\";\n")
    write(f, "    object      boundary;\n")
    write(f, "}\n")
    write(f, "$(length(boundaries))\n")
    write(f, "(\n")
    for boundary in boundaries
        write(f, "$(boundary.name)\n")
        write(f, "{\n")
        write(f, "type       $(boundary.type);\n")
        write(f, "nFaces     $(boundary.nFaces);\n")
        write(f, "startFace  $(boundary.startFace - 1);\n")
        write(f, "}\n")
    end
    write(f, ")\n")
    end
end

function writeOpenFoamMesh(mesh)
    writePolyMeshPoints(mesh.nodes)
    writePolyMeshFaces(mesh.faces)
    writePolyMeshOwner(mesh.faces)
    writePolyMeshNeighbour(mesh.faces, mesh.boundaries)
    writePolyMeshBoundaries(mesh.boundaries)
end
