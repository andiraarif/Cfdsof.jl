using LinearAlgebra

function assembleDiffusionTerm(gamma, phi, gradPhi)
    fluxCf = [0.0 for _ in 1:mesh.nFaces]
    fluxFf = [0.0 for _ in 1:mesh.nFaces]
    fluxVf = [0.0 for _ in 1:mesh.nFaces]

    faces = [mesh.faces[iFace] for iFace in 1:mesh.nFaces]
    geoDiff = [faces[iFace].geoDiff for iFace in 1:mesh.nFaces]
    Tf = [faces[iFace].Tf for iFace in 1:mesh.nFaces]
    gammaFaces = gamma.faceValues
    phiFaces = phi.faceValues
    gradPhiFaces = gradPhi.faceValues

    # Assemble internal faces
    faceRange = 1:mesh.nInternalFaces

    fluxCf[faceRange] = gammaFaces[faceRange] .* geoDiff[faceRange]
    fluxFf[faceRange] = -fluxCf[faceRange]
    fluxVf[faceRange] = [dot(gammaFaces[iFace] * gradPhiFaces[iFace], Tf[iFace]) for iFace in faceRange]
    
    # Assemble boundary faces
    for boundary in mesh.boundaries
        faceRange = boundary.startFace:boundary.startFace + boundary.nFaces - 1

        if boundary.bcType == "fixedValue"
            fluxCf[faceRange] = gammaFaces[faceRange] .* geoDiff[faceRange]
            fluxFf[faceRange] .= 0.0
            fluxVf[faceRange] = -fluxCf[faceRange] .* phiFaces[faceRange] + 
                [dot(gammaFaces[iFace] * gradPhiFaces[iFace], Tf[iFace]) for iFace in faceRange]
        elseif boundary.bcType == "zeroGradient"
            fluxCf[faceRange] .= 0.0
            fluxFf[faceRange] .= 0.0
            fluxVf[faceRange] = [dot(gammaFaces[iFace] * gradPhiFaces[iFace], Tf[iFace]) for iFace in faceRange]
        end
    end

    return fluxCf, fluxFf, fluxVf
end
