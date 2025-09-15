//
//  Utils.swift
//  EJ1PT3DISPOSITIVOS
//
//  Created by Omar Bermejo Osuna on 14/09/25.
//

import UIKit

func loadImageFromDocuments(filename: String) -> UIImage? {
    let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        .appendingPathComponent(filename)
    return UIImage(contentsOfFile: url.path)
}
