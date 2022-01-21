using LinearAlgebra

mutable struct Node
    index::Int64
    centroid::Vector{Float64}
    iFaces::Vector{Int64}
    iCells::Vector{Int64}
    Node() = new(0, [], [], [])
end

mutable struct Face
    index::Int64
    iOwner::Int64
    iNeighbour::Int64
    iNodes::Vector{Int64}
    centroid::Vector{Float64}
    area::Float64
    sf::Vector{Float64}
    cn::Vector{Float64}
    t::Vector{Float64}
    geoDiff::Float64
    wallDist::Float64
    gf::Float64
    iOwnerNeighbourCoeff::Int64
    iNeighbourOwnerCoeff::Int64
    Face() = new(0, 0, 0, [], [], 0.0, [], [], [], 0.0, 0.0, 0.0, 0, 0)
end

mutable struct Cell
    index::Int64
    iNeighbours::Vector{Int64}
    iNodes::Vector{Int64}
    iFaces::Vector{Int64}
    volume::Float64
    centroid::Vector{Float64}
    faceSigns::Vector{Int64}
    nNeighbours::Int64
    Cell() = new(0, [], [], [], 0.0, [], [], 0)
end

mutable struct Boundary
    index::Int64
    name::String
    type::String
    startFace::Int64
    nFaces::Int64
    Boundary() = new(0, "", "", 0, 0)
end

mutable struct Mesh
    nodes::Vector{Node}
    faces::Vector{Face}
    cells::Vector{Cell}
    boundaries::Vector{Boundary}
    nNodes::Int64
    nFaces::Int64
    nInternalFaces::Int64
    nBoundaryFaces::Int64
    nCells::Int64
    nBoundaries::Int64
end

function nodeIndexToCoord(iNodes::Vector{Int64}, nodes::Vector{Vector{Float64}})
    nodeCoords = Vector{Float64}[]
    for iNode in iNodes
        push!(nodeCoords, nodes[iNode])
    end
    return nodeCoords
end

function faceIndexToSf(iFaces::Vector{Int64}, faceVec::Vector{Face})
    facesSf = Vector{Float64}[]
    for iFace in iFaces
        push!(facesSf, faceVec[iFace].sf)
    end
    return facesSf
end

function faceIndexToCentroid(iFaces::Vector{Int64}, faceVec::Vector{Face})
    facesCentroid = Vector{Float64}[]
    for iFace in iFaces
        push!(facesCentroid, faceVec[iFace].centroid)
    end
    return facesCentroid
end

function geometricCenter(points::Vector{Vector{Float64}})
    nPoints = size(points, 1)
    gc = [0, 0, 0]
    for point in points
        gc = gc .+ point
    end
    return gc / nPoints
end

function triangleSurfaceVec(points::Vector{Vector{Float64}})
    side1 = points[2] .- points[1]
    side2 = points[3] .- points[1]
    return cross(side1, side2) / 2
end

function polygonCentroidSurfaceVec(points::Vector{Vector{Float64}})
    nPoints = size(points, 1)
    gc = geometricCenter(points)

    centroid = [0.0, 0.0, 0.0]
    surfaceVec = [0.0, 0.0, 0.0]

    if nPoints < 3
        throw(ErrorException("Error calculating surface centroid: The number of points is less than 3"))
    elseif nPoints == 3
        centroid = gc
        surfaceVec = triangleSurfaceVec(points)
    else
        for iPoint in 1:nPoints
            if iPoint < nPoints
                subTriPoints = [gc, points[iPoint], points[iPoint + 1]]
            else
                subTriPoints = [gc, points[iPoint], points[1]]
            end

            subTrisurfaceVec = triangleSurfaceVec(subTriPoints)
            subTriCentroid = geometricCenter(subTriPoints)
            
            centroid = centroid .+ (subTriCentroid * norm(subTrisurfaceVec))
            surfaceVec = surfaceVec .+ subTrisurfaceVec

        end
        centroid /= norm(surfaceVec)
    end
    return centroid, surfaceVec
end

function polyhedralCentroidVol(points, surfaceVecs, surfaceCentroids)
    gc = geometricCenter(points)
    nFaces = size(surfaceVecs, 1)

    vol = 0.0
    centroid = [0.0, 0.0, 0.0]

    for i in 1:nFaces
        geometriCenterToFaceVec = gc .- surfaceCentroids[i]
        subPyrVol = abs(dot(geometriCenterToFaceVec, surfaceVecs[i]) / 3)
        centroidSubPyr = 0.75 * surfaceCentroids[i] + 0.25 * gc
        
        vol += subPyrVol
        centroid = centroid .+ (centroidSubPyr * subPyrVol)
    end
    centroid /= vol
    return centroid, vol
end

function processOpenFoamMesh(points, faces, owner, neighbour, boundary)
    nNodes = length(points)
    nFaces = length(faces)
    nInternalFaces = length(neighbour)
    nBoundaryFaces = nFaces - nInternalFaces
    nBoundaries = length(boundary)
    maximum(owner) > maximum(neighbour) ? nCells = maximum(owner) : nCells = maximum(neighbour)

    nodeVec = [Node() for _ in 1:nNodes]
    faceVec = [Face() for _ in 1:nFaces]
    cellVec = [Cell() for _ in 1:nCells]
    boundaryVec = [Boundary() for _ in 1:nBoundaries]

    for iFace in 1:nFaces
        faceVec[iFace].index = iFace
        faceVec[iFace].iNodes = faces[iFace]
        faceVec[iFace].iOwner = owner[iFace]

        faceNodesCoord = nodeIndexToCoord(faces[iFace], points)
        faceVec[iFace].centroid, faceVec[iFace].sf = polygonCentroidSurfaceVec(faceNodesCoord)
        faceVec[iFace].area = norm(faceVec[iFace].sf)

        cellVec[owner[iFace]].index = owner[iFace]
        push!(cellVec[owner[iFace]].iFaces, iFace)
        push!(cellVec[owner[iFace]].faceSigns, 1)

        for iNode in faceVec[iFace].iNodes
            nodeVec[iNode].index = iNode
            nodeVec[iNode].centroid = points[iNode]
            push!(nodeVec[iNode].iFaces, iFace)
            !(owner[iFace] in nodeVec[iNode].iCells) && push!(nodeVec[iNode].iCells, owner[iFace])
            !(iNode in cellVec[owner[iFace]].iNodes) && push!(cellVec[owner[iFace]].iNodes, iNode)

            if iFace <= nInternalFaces
                !(neighbour[iFace] in nodeVec[iNode].iCells) && push!(nodeVec[iNode].iCells, neighbour[iFace])
                !(iNode in cellVec[neighbour[iFace]].iNodes) && push!(cellVec[neighbour[iFace]].iNodes, iNode)
            end
        end

        if iFace <= nInternalFaces
            faceVec[iFace].iNeighbour = neighbour[iFace]

            push!(cellVec[neighbour[iFace]].iFaces, iFace)
            push!(cellVec[neighbour[iFace]].faceSigns, -1)

            push!(cellVec[owner[iFace]].iNeighbours, neighbour[iFace])
            cellVec[owner[iFace]].nNeighbours += 1
    
            push!(cellVec[neighbour[iFace]].iNeighbours, owner[iFace])        
            cellVec[neighbour[iFace]].nNeighbours += 1
        else
            faceVec[iFace].iNeighbour = -1
        end
    end

    for iCell in 1:nCells
        cellNodesCoord = nodeIndexToCoord(cellVec[iCell].iNodes, points)
        cellFacesSf = faceIndexToSf(cellVec[iCell].iFaces, faceVec)
        cellFacesCentroid = faceIndexToCentroid(cellVec[iCell].iFaces, faceVec)
        cellVec[iCell].centroid, cellVec[iCell].volume = polyhedralCentroidVol(cellNodesCoord, cellFacesSf, cellFacesCentroid)
    end

    for iBoundary in 1:nBoundaries
        boundaryVec[iBoundary].index = iBoundary
        boundaryVec[iBoundary].name = boundary[iBoundary]["name"]
        boundaryVec[iBoundary].type = boundary[iBoundary]["type"]
        boundaryVec[iBoundary].startFace = boundary[iBoundary]["startFace"]
        boundaryVec[iBoundary].nFaces = boundary[iBoundary]["nFaces"]
    end

    for face in faceVec
        face.cn = face.centroid - cellVec[face.iOwner].centroid

        ef = face.sf/(norm(face.sf))
        if face.iNeighbour != -1
            dfn = cellVec[face.iNeighbour].centroid - face.centroid

            face.gf = dot(face.cn, ef) / (dot(face.cn, ef) + dot(dfn, ef))
            face.t = dfn + face.cn
            face.wallDist = 0
            face.geoDiff = face.area / norm(cellVec[face.iOwner].centroid - cellVec[face.iNeighbour].centroid)
        else
            face.gf = 1
            face.t = face.cn
            face.wallDist = dot(face.cn, ef)
            face.geoDiff = face.area / face.wallDist
        end
    end

    return Mesh(nodeVec, faceVec, cellVec, boundaryVec, nNodes, 
        nFaces, nInternalFaces, nBoundaryFaces, nCells, nBoundaries)
end

function printNode(node)
    println("")
    println("Node $(node.index) = ")
    println("")
    println("                   index: ", node.index)
    println("                centroid: ", node.centroid)
    println("                  iFaces: ", node.iFaces)
    println("                  iCells: ", node.iCells)
end

function printFace(face)
    println("")
    println("Face $(face.index) = ")
    println("")
    println("                   index: ", face.index)
    println("                  iNodes: ", face.iNodes)
    println("                  iOwner: ", face.iOwner)
    println("              iNeighbour: ", face.iNeighbour)
    println("                centroid: ", face.centroid)
    println("                    area: ", face.area)
    println("                      Sf: ", face.sf)
    println("                      CN: ", face.cn)
    println("                 geodiff: ", face.geoDiff)
    println("                       T: ", face.t)
    println("                      gf: ", face.gf)
    println("                walldist: ", face.wallDist)
    println("    iOwnerNeighbourCoeff: ", face.iOwnerNeighbourCoeff)
    println("    iNeighbourOwnerCoeff: ", face.iNeighbourOwnerCoeff)
end

function printBoundary(boundary)
    println("")
    println("Boundary $(boundary.index) = ")
    println("")
    println("                   index: ", boundary.index)
    println("                    name: ", boundary.name)
    println("                    type: ", boundary.type)
    println("               startFace: ", boundary.startFace)
    println("          numberOfBFaces: ", boundary.nFaces)
end

function printCell(cell)
    println("")
    println("Cell $(cell.index) = ")
    println("")
    println("                   index: ", cell.index)
    println("                  iFaces: ", cell.iFaces)
    println("                  iNodes: ", cell.iNodes)
    println("             iNeighbours: ", cell.iNeighbours)
    println("      numberOfNeighbours: ", cell.nNeighbours)
    println("               faceSigns: ", cell.faceSigns)
    println("                  volume: ", cell.volume)
    println("                centroid: ", cell.centroid)
end

function printMesh(mesh)
    println("")
    println("Mesh = ")
    println("")
    println("                   nodes: ", typeof(mesh.nodes))
    println("           numberOfNodes: ", mesh.nNodes)
    println("                   faces: ", typeof(mesh.faces))
    println("           numberOfFaces: ", mesh.nFaces)
    println("                   cells: ", typeof(mesh.cells))
    println("           numberOfCells: ", mesh.nCells)
    println("              boundaries: ", typeof(mesh.boundaries))
    println("      numberOfBoundaries: ", mesh.nBoundaries)
    println("   numberOfInteriorFaces: ", mesh.nInternalFaces)
    println("   numberOfBoundaryFaces: ", mesh.nBoundaryFaces) 
end    
