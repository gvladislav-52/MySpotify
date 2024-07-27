//
//  FeaturedPlaylistsResponse.swift
//  SpotifyProject
//
//  Created by gvladislav-52 on 27.07.2024.
//

import Foundation

struct FeaturedPlaylistsResponse: Codable {
    let playlists: PlaylistResponse
}

struct PlaylistResponse: Codable {
    let items: [Playlist]
}

struct User: Codable {
    let display_name: String
    let external_urls: [String: String]
    let id: String
}
