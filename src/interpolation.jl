using LinearAlgebra

function interpolateCellsToFaces(field, method)
    if method == "harmonicMean"
        for iFace in 1:mesh.nInternalFaces
            face = mesh.faces[iFace]

            ownerValue = field.cellValues[face.iOwner]
            neighbourValue = field.cellValues[face.iNeighbour]
            
            field.faceValues[iFace] = 2 * ownerValue * neighbourValue / (ownerValue + neighbourValue)
        end
    elseif method == "linear"
        for iFace in 1:mesh.nInternalFaces
            face = mesh.faces[iFace]

            ownerValue = field.cellValues[face.iOwner]
            neighbourValue = field.cellValues[face.iNeighbour]

            field.faceValues[iFace] = (1 - face.gf) * ownerValue + face.gf * neighbourValue
        end
    end    
end