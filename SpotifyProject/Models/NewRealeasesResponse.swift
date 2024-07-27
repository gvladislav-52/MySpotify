//
//  NewRealeasesResponses.swift
//  SpotifyProject
//
//  Created by gvladislav-52 on 22.07.2024.
//

import Foundation

struct NewRealeasesResponse: Codable {
    let albums: AlbumsResponse
}

struct AlbumsResponse: Codable {
    let items: [Album]
}

struct Album: Codable {
    let album_type: String
    let available_markets: [String]
    let id: String
    let images: [APIImage]
    let name: String
    let release_date: String
    let total_tracks: Int
    let artists: [Artist]
}


