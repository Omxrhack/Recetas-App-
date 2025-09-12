//
//  OnboardingModel.swift
//  EJ1PT3DISPOSITIVOS
//
//  Created by Omar Bermejo Osuna on 11/09/25.
//

import Foundation


class OnboardingViewModel:ObservableObject  {
    @Published var courrentTab = 0
    @Published var OnboardingContent: [Onboarding] = [
        Onboarding(title: "Recetapp", image: "cocinando1", description: "Cocinar con amigos es más fácil que nunca"),
        Onboarding(title: "Imaginar es lo mismo que cocinar", image: "cocinando3", description: "¿Quieres saber cómo cocinar tu plato favorito?"),
        Onboarding(title: "Empieza a guardar tus recetas", image: "cocinando2", description: "Empieza a guardar tus recetas y descubre los secretos de los mejores cocineros del mundo."),
        
    ]
    func goToNextTab() {
        if courrentTab < OnboardingContent.count - 1 {
                courrentTab += 1
            }
        }

    

    }


