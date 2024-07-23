//
//  NetworkClient.swift
//  MoviesApp
//
//  Created by Olya Lutsyk on 14.07.2024.
//

import Foundation
import Alamofire

protocol NetworkProtocol {
    func request<T: Decodable>(_ url: String, 
                               method: HTTPMethod,
                               parameters: Parameters?,
                               completion: @escaping (Result<T, Error>) -> Void)
}

final class NetworkClient: NetworkProtocol {
    private let apiKey: String?
    private let accessToken: String
    
    private(set) lazy var session: Session = {
        let configuration = URLSessionConfiguration.default
        return Session(configuration: configuration)
    }()
    
    init() {
        if let apiKey = Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String {
            self.apiKey = apiKey
        } else {
            self.apiKey = nil
        }
        // Access token  hardcoded here, with real request it will loaded from API and stored in keychain
        self.accessToken = "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIzZTk0NjQ2ODM1YzBmNzRlMDY0YmJiMzU5NjQxZTlkNiIsIm5iZiI6MTcyMDk1NzYxOC4yMzM1NDUsInN1YiI6IjY2OTI5ZTcwMzdkZGVmYmIyZGY3YjA3ZCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.dk0WqQAsbKUt6__-9Gm7xGwplDp7DDE2_VoSThGF-no"
    }
    
    private func buildRequest(
        url: String,
        method: HTTPMethod,
        parameters: Parameters?,
        headers: HTTPHeaders?)
    -> DataRequest {
        var allHeaders = HTTPHeaders()
        allHeaders.add(name: "Authorization", value: "Bearer \(accessToken)")
        allHeaders.add(name: "Content-Type", value: "application/json;charset=utf-8")
        
        var allParameters = parameters ?? Parameters()
        allParameters["api_key"] = apiKey
        
        return session.request(url, method: method, parameters: allParameters, headers: allHeaders)
    }
    
    func request<T: Decodable>(_ url: String,
                               method: HTTPMethod,
                               parameters: Parameters?,
                               completion: @escaping (Result<T, Error>) -> Void) {
          let request = buildRequest(url: url, method: method, parameters: parameters, headers: nil)
          request.responseDecodable(of: T.self) { response in
              switch response.result {
              case .success(let result):
                  completion(.success(result))
              case .failure(let error):
                  completion(.failure(error))
              }
          }
      }
}
