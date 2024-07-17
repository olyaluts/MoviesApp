//
//  NetworkClient.swift
//  MoviesApp
//
//  Created by Olya Lutsyk on 14.07.2024.
//

import Foundation
import Alamofire

//protocol AlamofireNetworkProtocol: AnyObject {
//    var session: Session { get }
//    func getPopularMovies(completion: @escaping (Result<[Movie], Error>) -> Void)
//}
//
//final class NetworkClient: AlamofireNetworkProtocol {
//    static let shared = NetworkClient()
//    
//    private let apiKey = "3e94646835c0f74e064bbb359641e9d6"
//    private let accessToken = "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIzZTk0NjQ2ODM1YzBmNzRlMDY0YmJiMzU5NjQxZTlkNiIsIm5iZiI6MTcyMDk1NzYxOC4yMzM1NDUsInN1YiI6IjY2OTI5ZTcwMzdkZGVmYmIyZGY3YjA3ZCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.dk0WqQAsbKUt6__-9Gm7xGwplDp7DDE2_VoSThGF-no"
//    
//    private let baseUrl = "https://api.themoviedb.org/3/movie"
//    
//    private(set) lazy var session: Session = {
//           let configuration = URLSessionConfiguration.default
//           return Session(configuration: configuration)
//       }()
//    
//    func getPopularMovies(completion: @escaping (Result<[Movie], Error>) -> Void) {
//            let url = "\(baseUrl)/popular"
//            let headers: HTTPHeaders = [
//                "Authorization": "Bearer \(accessToken)",
//                "Content-Type": "application/json;charset=utf-8"
//            ]
//            let parameters: Parameters = ["api_key": apiKey]
//            
//            session.request(url, method: .get, parameters: parameters, headers: headers).responseDecodable(of: MoviesResponse.self) { response in
//                switch response.result {
//                case .success(let moviesResponse):
//                    completion(.success(moviesResponse.results))
//                case .failure(let error):
//                    completion(.failure(error))
//                }
//            }
//        }
//}

protocol NetworkProtocol {
    func request<T: Decodable>(_ url: String, 
                               method: HTTPMethod,
                               parameters: Parameters?,
                               headers: HTTPHeaders?,
                               completion: @escaping (Result<T, Error>) -> Void)
}

final class NetworkClient: NetworkProtocol {
    
    private let apiKey: String
    private let accessToken: String
    
    private(set) lazy var session: Session = {
        let configuration = URLSessionConfiguration.default
        return Session(configuration: configuration)
    }()
    
    init() {
        self.apiKey = "3e94646835c0f74e064bbb359641e9d6"
        self.accessToken = "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIzZTk0NjQ2ODM1YzBmNzRlMDY0YmJiMzU5NjQxZTlkNiIsIm5iZiI6MTcyMDk1NzYxOC4yMzM1NDUsInN1YiI6IjY2OTI5ZTcwMzdkZGVmYmIyZGY3YjA3ZCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.dk0WqQAsbKUt6__-9Gm7xGwplDp7DDE2_VoSThGF-no"
    }
    
    func request<T: Decodable>(_ url: String, method: HTTPMethod, parameters: Parameters?, headers: HTTPHeaders?, completion: @escaping (Result<T, Error>) -> Void) {
        var allHeaders = headers ?? HTTPHeaders()
        allHeaders.add(name: "Authorization", value: "Bearer \(accessToken)")
        allHeaders.add(name: "Content-Type", value: "application/json;charset=utf-8")
        
        var allParameters = parameters ?? Parameters()
        allParameters["api_key"] = apiKey
        
        session.request(url, method: method, parameters: allParameters, headers: allHeaders).responseDecodable(of: T.self) { response in
            switch response.result {
            case .success(let result):
                completion(.success(result))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

struct MoviesResponse: Decodable {
    let results: [Movie]
}
