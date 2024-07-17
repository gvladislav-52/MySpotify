//
//  AuthManager.swift
//  SpotifyProject
//
//  Created by gvladislav-52 on 17.07.2024.
//

import Foundation

final class AuthManager {
    

    // Общий экземпляр AuthManager
    // что позволяет реализовать паттерн Singleton, чтобы был только один экземпляр этого класса.
    static let shared = AuthManager()
    
    // Константы, используемые в процессе аутентификации
    // clientID: ID клиента, который выдается приложению при регистрации в Spotify.
    // clientSecret: Секретный ключ клиента, который также выдается при регистрации.
    // tokenAPIURL: URL API для получения токена.
    struct Constants {
        static let clientID = "c5283aeb39f74f97aa174dd8b8da9c16"
        static let cleintSecret = "a6f684a3472947d6a4150aa752b3a2e6"
        static let tokenAPIURL = "https://accounts.spotify.com/api/token"
        // URI перенаправления, используемый в процессе OAuth
        // Это константа, которая хранит URL перенаправления, используемый в процессе OAuth для возвращения пользователя после успешного входа.
        static let redirectURI = "https://github.com/gvladislav-52"
        // scopes: Запрашиваемые разрешения (в данном случае доступ к личной информации пользователя).
        static let scopes = "user-read-private%20playlist-modify-public%20playlist-read-private%20playlist-modify-private%20user-follow-read%20user-library-modify%20user-library-read%20user-read-email"
    }
    
    // Приватный инициализатор для обеспечения паттерна синглтон
    private init() {}
    
    // Вычисляемое свойство для генерации URL для входа
    // Здесь объявляется вычисляемое свойство signInURL, которое будет возвращать URL для входа пользователя.
    // Сначала задаются параметры запроса:
    //      scopes: Запрашиваемые разрешения (в данном случае доступ к личной информации пользователя).
    //      base: Базовый URL для авторизации.
    public var signInURL: URL? {
        let base = "https://accounts.spotify.com/authorize"
        
        // Конструируем полный URL для страницы входа
        let string = "\(base)?response_type=code&client_id=\(Constants.clientID)&scope=\(Constants.scopes)&redirect_uri=\(Constants.redirectURI)&show_dialog=TRUE"
        return URL(string: string)
    }
    
    // Проверка, вошел ли пользователь в систему, проверяя наличие access token
    var isSignedIn: Bool {
        return accessToken != nil
    }
    
    // Access token, хранящийся в UserDefaults
    private var accessToken: String? {
        return  UserDefaults.standard.string(forKey: "access_token")
    }
    
    // Refresh token, хранящийся в UserDefaults
    private var refreshToken: String? {
        return  UserDefaults.standard.string(forKey: "refresh_token")
    }
    
    // Дата истечения токена, хранящаяся в UserDefaults
    private var tokenExpirationDate: Date? {
        return UserDefaults.standard.object(forKey: "expirationDate") as? Date
    }
    
    // Проверка, нужно ли обновлять токен (если он истекает в течение следующих 5 минут)
    // Этот метод проверяет, нужно ли обновлять токен, проверяя, истекает ли он в течение следующих 5 минут.
    // Если дата истечения доступна и текущая дата плюс пять минут больше или равна дате истечения, возвращается true.
    private var shouldRefreshToken: Bool {
        guard let expirationDate = tokenExpirationDate else { return false }
        let currentDate = Date()
        let fiveMinutes: TimeInterval = 300
        return currentDate.addingTimeInterval(fiveMinutes) >= expirationDate
    }
    
    // Обмен кода авторизации на access token
    // Объявляется публичный метод для обмена кода авторизации на access token. Он принимает код и замыкание для обработки результата.
    public func exchangeCodeForToken(code: String, completion: @escaping ((Bool) -> Void)) {
        // Получаем URL для токена
        guard let url = URL(string: Constants.tokenAPIURL) else { return }
        
        // Подготавливаем компоненты URL с необходимыми параметрами запроса
        // Создаем URLComponents и добавляем необходимые параметры запроса: grant_type (тип запроса), code (код авторизации) и redirect_uri (URI перенаправления).
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "grant_type", value: "authorization_code"),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI)
        ]
        
        // Создаем POST запрос для получения токена
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = components.query?.data(using: .utf8)
        
        // Создаем заголовок Basic authorization
        let basicToken = Constants.clientID + ":" + Constants.cleintSecret
        let data = basicToken.data(using: .utf8)
        guard let base64String = data?.base64EncodedString() else {
            print("Failure to get base64")
            completion(false)
            return
        }
         
        // Добавляем заголовок авторизации к запросу
        request.setValue("Basic \(base64String)", forHTTPHeaderField: "Authorization")
        
        // Выполняем запрос для обмена кода на токен
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            guard let data = data, error == nil else {
                completion(false)
                return
            }
            
            do {
                // Декодируем ответ в объект AuthResponse
                let result = try JSONDecoder().decode(AuthResponse.self, from: data)
                // Кэшируем данные токена
                self?.cacheToken(result: result)
                completion(true)
            } catch {
                print(error.localizedDescription)
                completion(false)
            }
        }
        task.resume()
    }
    
    // Кэшируем данные токена в UserDefaults
    public func cacheToken(result: AuthResponse) {
        UserDefaults.standard.setValue(result.access_token, forKey: "access_token")
        if let refresh_token = result.refresh_token {
            UserDefaults.standard.setValue(refresh_token, forKey: "refresh_token")
        }
        UserDefaults.standard.setValue(Date().addingTimeInterval(TimeInterval(result.expires_in)), forKey: "expirationDate")
    }
    
    // Функция для обновления access token (еще не реализована)
    public func refreshIfNeeded(completion: @escaping (Bool) -> Void) {
//        guard shouldRefreshToken else {
//            completion(true)
//            return
//        }
        
        guard let refreshToken = self.refreshToken else {
            return
        }
        
        // Refresh the token
        guard let url = URL(string: Constants.tokenAPIURL) else { return }
        
        // Подготавливаем компоненты URL с необходимыми параметрами запроса
        // Создаем URLComponents и добавляем необходимые параметры запроса: grant_type (тип запроса), code (код авторизации) и redirect_uri (URI перенаправления).
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "grant_type", value: "refresh_token"),
            URLQueryItem(name: "refresh_token", value: refreshToken)
        ]
        
        // Создаем POST запрос для получения токена
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = components.query?.data(using: .utf8)
        
        // Создаем заголовок Basic authorization
        let basicToken = Constants.clientID + ":" + Constants.cleintSecret
        let data = basicToken.data(using: .utf8)
        guard let base64String = data?.base64EncodedString() else {
            print("Failure to get base64")
            completion(false)
            return
        }
         
        // Добавляем заголовок авторизации к запросу
        request.setValue("Basic \(base64String)", forHTTPHeaderField: "Authorization")
        
        // Выполняем запрос для обмена кода на токен
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            guard let data = data, error == nil else {
                completion(false)
                return
            }
            
            do {
                // Декодируем ответ в объект AuthResponse
                let result = try JSONDecoder().decode(AuthResponse.self, from: data)
                print("Successfully refreshed")
                // Кэшируем данные токена
                self?.cacheToken(result: result)
                completion(true)
            } catch {
                print(error.localizedDescription)
                completion(false)
            }
        }
        task.resume()
    }
}
