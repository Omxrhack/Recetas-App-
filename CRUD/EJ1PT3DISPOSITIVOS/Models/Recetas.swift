
// Recetas.swift
// EJ1PT3DISPOSITIVOS
//
// Created by Omar Bermejo Osuna on 14/09/25.
//

import Foundation

struct Recipe: Identifiable, Equatable {
    let id: Int
    var user: String
    var title: String
    var image: String
    var description: String
    var category: String
    var isPublic: Bool
    var isLiked: Bool = false
    var isSaved: Bool = false
    
  
}
