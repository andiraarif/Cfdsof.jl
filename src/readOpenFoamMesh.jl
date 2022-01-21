include("mesh.jl")

function findPolyMeshNData(fileLines)
    lineCounter = 1
    nData = 0
    startLine = 0
    for line in fileLines
        if isNumber(strip(line))
            nData = parse(Int64, line)
            startLine = lineCounter + 2
            break
        end
        lineCounter += 1
    end
    return nData, startLine
end

function isNumber(str)
    re = r"^[+-]?([0-9]+([.][0-9]*)?|[.][0-9]+)$"
    return occursin(re, str)
end

function findInLines(str, lines, startLine)
    nLines = size(lines, 1)
    for i in startLine:nLines
        if occursin(str, lines[i])
            return i
        end
    end
    return -1
end

function readPolyMeshPoints(filePath)
    f = open(filePath, "r")
    fileLines = readlines(f)
    nPoints, startLine = findPolyMeshNData(fileLines)

    points = Vector{Float64}[]
    for iLine in startLine:startLine + nPoints - 1
        noWhiteSpace = strip(fileLines[iLine])
        coordLine = split(noWhiteSpace[2:end - 1])
        coord = Float64[]
        for i in 1:3
            push!(coord, parse(Float64, coordLine[i]))
        end
        push!(points, coord)
    end
    return points
end

function readPolyMeshFaces(filePath)
    f = open(filePath, "r")
    fileLines = readlines(f)
    nFaces, startLine = findPolyMeshNData(fileLines)

    faces = Vector{Int64}[]
    for iLine in startLine:startLine + nFaces - 1
        noWhiteSpace = strip(fileLines[iLine])
        faceLine = split(noWhiteSpace[3:end - 1])
        facePoints = Int64[]
        for iPoint in 1:length(faceLine)
            push!(facePoints, parse(Int64, faceLine[iPoint]) + 1)
        end
        push!(faces, facePoints)
    end
    return faces
end

function readPolyMeshOwner(filePath)
    f = open(filePath, "r")
    fileLines = readlines(f)
    nOwner, startLine = findPolyMeshNData(fileLines)

    owner = Int64[]
    for iLine in startLine:startLine + nOwner - 1
        noWhiteSpace = strip(fileLines[iLine])
        ownerLine = noWhiteSpace
        push!(owner, parse(Int64, ownerLine) + 1)
    end
    return owner
end

function readPolyMeshNeighbour(filePath)
    f = open(filePath, "r")
    fileLines = readlines(f)
    nNeighbour, startLine = findPolyMeshNData(fileLines)

    neighbour = Int64[]
    for iLine in startLine:startLine + nNeighbour - 1
        noWhiteSpace = strip(fileLines[iLine])
        neighbourLine = noWhiteSpace
        push!(neighbour, parse(Int64, neighbourLine) + 1)
    end
    return neighbour
end

function readPolyMeshBoundary(filePath)
    f = open(filePath, "r")
    fileLines = readlines(f)
    nBoundaries, startLine = findPolyMeshNData(fileLines)

    boundaries = Dict[]
    for iBoundary in 1:nBoundaries
        boundaryDict = Dict{String, Any}("name" => "", "type" => "", "nFaces" => 0, "startFace" => 0)

        nameLine = findInLines("{", fileLines, startLine) - 1
        boundaryDict["name"] = strip(fileLines[nameLine])

        typeLine = findInLines("type", fileLines, startLine)
        boundaryDict["type"] = split(strip(fileLines[typeLine]))[2][1:end - 1]

        nFacesLine = findInLines("nFaces", fileLines, startLine)
        boundaryDict["nFaces"] = parse(Int64, split(strip(fileLines[nFacesLine]))[2][1:end - 1])

        startFaceLine = findInLines("startFace", fileLines, startLine)
        boundaryDict["startFace"] = parse(Int64, split(strip(fileLines[startFaceLine]))[2][1:end - 1]) + 1

        push!(boundaries, boundaryDict)

        startLine = findInLines("}", fileLines, startLine) + 1
    end
    return boundaries
end

function readOpenFoamMesh(polyMeshPath)
    println("Reading OpenFOAM mesh in $polyMeshPath")
    points = readPolyMeshPoints("$polyMeshPath/points")
    faces = readPolyMeshFaces("$polyMeshPath/faces")
    owner = readPolyMeshOwner("$polyMeshPath/owner")
    neighbour = readPolyMeshNeighbour("$polyMeshPath/neighbour")
    boundary= readPolyMeshBoundary("$polyMeshPath/boundary")

    return processOpenFoamMesh(points, faces, owner, neighbour, boundary)
end
