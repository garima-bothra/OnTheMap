//
//  ClientAPI.swift
//  OnTheMap
//
//  Created by Garima Bothra on 25/05/20.
//  Copyright © 2020 Garima Bothra. All rights reserved.
//

import Foundation

class ClientAPI {
    
    struct Auth {
        static var sessionId = ""
        static var userId = ""
        static var userFirstName = ""
        static var userLastName = ""
    }
    
    enum Endpoints {
        static let base = "https://onthemap-api.udacity.com/v1"
        
        case login
        case logout
        case getStudents(Int)
        case getPublicUserData
        case addLocation
        case updateLocation
        
        var stringValue: String {
            switch self {
            case .login, .logout:
                return Endpoints.base + "/session"
            //https://onthemap-api.udacity.com/v1/StudentLocation?limit=100
            case .getStudents(let limit):
                return Endpoints.base + "/StudentLocation?order=-updatedAt&limit=\(limit)"
            case .getPublicUserData:
                return Endpoints.base + "/users/\(Auth.userId)"
            case .addLocation:
                return Endpoints.base + "/StudentLocation"
            case .updateLocation:
                return Endpoints.base + "/StudentLocation/\(StudentModel.userObjectId!)"
            }            
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    class func taskForGETRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) -> URLSessionDataTask {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if error != nil {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            print(String(data: data, encoding: .utf8)!)

            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                do {
                    let errorResponse = try decoder.decode(ErrorResponse.self, from: data) as Error
                    DispatchQueue.main.async {
                        completion(nil, errorResponse)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
            }
        }
        task.resume()
        
        return task
    }
    
    class func taskForPOSTRequest<RequestType: Encodable, ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, body: RequestType, completion: @escaping (ResponseType?, Error?) -> Void) {
        taskForRequest(shouldFixResponseData: true, method: "POST", url: url, responseType: responseType, body: body, completion: completion)
    }
    
    class func taskForPUTRequest<RequestType: Encodable, ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, body: RequestType, completion: @escaping (ResponseType?, Error?) -> Void) {
        taskForRequest(shouldFixResponseData: true, method: "PUT", url: url, responseType: responseType, body: body, completion: completion)
    }
    
    class func taskForRequest<RequestType: Encodable, ResponseType: Decodable>(shouldFixResponseData: Bool, method: String, url: URL, responseType: ResponseType.Type, body: RequestType, completion: @escaping (ResponseType?, Error?) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = try! JSONEncoder().encode(body)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            
            guard var data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
         
            if shouldFixResponseData {
                data = fixResponseData(data: data)
            }
            print(String(data: data, encoding: .utf8) ?? "")

            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                do {
                    let errorResponse = try decoder.decode(ErrorResponse.self, from: data) as Error
                    DispatchQueue.main.async {
                        completion(nil, errorResponse)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
            }
        }
        task.resume()
    }
    
    class func fixResponseData(data: Data) -> Data {
        let range = 5..<data.count
        let newData = data.subdata(in: range) /* subset response data! */
        return newData
    }
    
    class func login(username: String, password: String, completion: @escaping (Bool, Error?) -> Void) {
        let body = LoginRequest(udacity: LoginRequest.Udacity(username: username, password: password))
        taskForPOSTRequest(url: Endpoints.login.url, responseType: SessionResponse.self, body: body) { response, error in
            if let response = response {
                Auth.sessionId = response.session.id
                Auth.userId = response.account.key
                completion(true, nil)
            } else {
                completion(false, error)
            }
        }
    }
    
    class func addLocation(userLocationRequest: AddLocationRequest, completion: @escaping (Bool, Error?) -> Void) {
    
        taskForRequest(shouldFixResponseData: false, method: "POST", url: Endpoints.addLocation.url, responseType: AddLocationResponse.self, body: userLocationRequest) { response, error in
            if let response = response {
                StudentModel.userObjectId = response.objectId
                completion(true, nil)
            } else {
                completion(false, error)
            }
        }
    }
    
    class func updateLocation(userLocationRequest: AddLocationRequest, completion: @escaping (Bool, Error?) -> Void) {
        
        taskForRequest(shouldFixResponseData: false, method: "PUT", url: Endpoints.updateLocation.url, responseType: UpdateLocationResponse.self, body: userLocationRequest) { response, error in
            if let response = response {
                if response.updatedAt != "" {
                    completion(true, nil)
                } else {
                    completion(false, ErrorResponse(status: -1, error: "Cound not update user location"))
                }
            } else {
                completion(false, error)
            }
        }
    }
    
    class func getStudents(completion: @escaping ([StudentInformation], Error?) -> Void) {
        _ = taskForGETRequest(url: Endpoints.getStudents(100).url, responseType: StudentResults.self) { response, error in
            if let response = response {
                completion(response.results, nil)
            } else {
                completion([], error)
            }
        }
    }
    
    class func logout(completion: @escaping (Bool, Error?) -> Void) {
        var request = URLRequest(url: Endpoints.logout.url)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil {
                DispatchQueue.main.async {
                    completion(false, error)
                }
                return
            }
            ClientAPI.Auth.sessionId = ""
            guard var data = data else {
                return
            }
            data = fixResponseData(data: data)
            print(String(data: data, encoding: .utf8) ?? "")
            DispatchQueue.main.async {
                completion(true, nil)
            }
        }
        task.resume()
    }
    
    class func getUserData(completion: @escaping (Bool, Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: Endpoints.getPublicUserData.url) { (data, response, error) in
            guard var data = data else {
                DispatchQueue.main.async {
                    completion(false, error)
                }
                return
            }
            data = fixResponseData(data: data)
            print(String(data: data, encoding: .utf8)!)
            let decoder = JSONDecoder()
            do {
                let response = try decoder.decode(StudentPublicInformation.self, from: data)
                Auth.userFirstName = response.firstName
                Auth.userLastName = response.lastName
                
                DispatchQueue.main.async {
                    completion(true, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(false, error)
                }
            }
        }
        task.resume()
    }
}
