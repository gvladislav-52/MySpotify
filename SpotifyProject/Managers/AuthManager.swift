//
//  AuthManager.swift
//  SpotifyProject
//
//  Created by gvladislav-52 on 17.07.2024.
//

import Foundation

final class AuthManager {
    static let shared = AuthManager()
    
    struct Constants {
        static let clientID = "c5283aeb39f74f97aa174dd8b8da9c16"
        static let cleintSecret = "a6f684a3472947d6a4150aa752b3a2e6"
    }
    
    private init() {}
    
    public var signInURL: URL? {
        let scopes = "user-read-private"
        let redirectURI = "https://github.com/gvladislav-52"
        let base = "https://accounts.spotify.com/authorize"
        let string = "\(base)?response_type=code&client_id=\(Constants.clientID)&scope=\(scopes)&redirect_uri=\(redirectURI)&show_dialog=TRUE"
        return URL(string: string)
    }
    
    var isSignedIn: Bool {
        return false
    }
    
    private var accessToken: String? {
        return nil
    }
    
    private var refreshToken: String? {
        return nil
    }
    
    private var tokenExpirationDate: Date? {
        return nil
    }
    
    private var shouldRefreshToken: Bool {
        return false
    }
    
    public func exchangeCodeForToken(code: String, completion: @escaping ((Bool) -> Void)) {
        //GET TOKEN
    }
    
    public func cacheToken() {
        
    }
    
    public func refreshAccessToken() {
        
    }
}
