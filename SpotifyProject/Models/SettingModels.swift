//
//  SettingModels.swift
//  SpotifyProject
//
//  Created by gvladislav-52 on 22.07.2024.
//

import Foundation

struct Section {
    let title: String
    let options: [Option]
}

struct Option {
    let title: String
    let handler: () -> Void
}
