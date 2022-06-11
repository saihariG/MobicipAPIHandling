//
//  NetworkManager.swift
//  LoginAPI
//
//  Created by Sai Hari on 27/05/22.
//

import Foundation
import UIKit
import SystemConfiguration

class NetworkManager {
    
    static let shared = NetworkManager()
    let vc = ViewController.self
    
    let session = URLSession.shared
    var sessionToken : String?
    
    var latestLoginTime : Double = 0.0
    var isLoginApiActive : Bool = false
    
    var loginMail = ""
    var loginPass = ""
    
    var queuedCalls : [(@escaping (completionStatus) -> Void) -> Void] = []
    var completionCalls : [(completionStatus) -> Void] = []
    
    func generateHTTPRequest(shouldRefresh : Bool = false,mailId : String,password : String,completion : @escaping (completionStatus) -> () ) {
         
        guard let URL = URL(string: "https://webd.prgr.in/api/v2/login") else{
            return
        }
        
        loginMail = mailId
        loginPass = password
        
        var httpRequest = URLRequest(url: URL)
        httpRequest.httpMethod = "POST"
        httpRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
 
        let password =  vc.MD5(string: password)
        let sessionHash =  String(data: vc.generateProfileHash(), encoding: .utf8)
       
        let message: [String: Any] =
        [
            "Request": [
                "User": [
                    "email": mailId,
                    "password": password,
                ],
                "Client": [
                    "identity": "21V21B337GMX2",
                    "version": "2.0",
                    "session_hash": sessionHash
                ],
                "api": [
                    "app_version": "6.3",
                    "version": "1.0"
                ],
                "Session": [
                    "token": "NO-TOKEN"
                ]
            ]
        ]
    
        guard let encodedMessage = try? JSONSerialization.data(withJSONObject: message,options: .withoutEscapingSlashes) else {
                print("failed to encode!")
                return
        }
    
        let checkSum = vc.hmac(message: encodedMessage, token : "NO-TOKEN")

        let params =
        [
            "mwsRequest":
                [
                    "String": message,
                    "Checksum" : checkSum
                ]
            
        ] as [String : Any]

        guard let encodedParams = try? JSONSerialization.data(withJSONObject: params,options: []) else{
                print("failed to encode parameters!")
                return
        }

        httpRequest.httpBody = encodedParams
        
        let task = session.dataTask(with: httpRequest, completionHandler : { [self] data , response , error in
            
                  if let error = error {
                      print("unexpected error : \(error.localizedDescription)")
                      completion(.failure(code: "", message: error.localizedDescription))
                      return
                  }
                  
                  guard let data = data , let response = response as? HTTPURLResponse else {
                      print("data or response is nil!")
                      return
                  }
       
                  if (200...299).contains(response.statusCode) {
                  
                      if shouldRefresh {
                          handleData(shouldRefresh: true, data: data,completion : completion)
                      }
                      else {
                          handleData(data: data,completion: completion)
                      }
                  }
                  else {
                      completion(.failure(code: "", message: "unexpected error"))
                  }
                  
          })
           
          task.resume()
    }
    
  
    func handleData(shouldRefresh : Bool = false,data : Data,completion : (completionStatus) -> () ) {
        
        guard let jsonData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject] else{
            return
        }
        
        guard let mwsResponse = jsonData["mwsResponse"] as? [String: AnyObject] else{
            return
        }
        
        //print(mwsResponse)
        
        if let status = mwsResponse["status"] as? [String: AnyObject]{
            if let code = status["code"] as? String , let message = status["message"] as? String {
                //print("code is : \(code)")
                if code != "000" {
                    completion(.failure(code: code, message: message))
                    return
                }
                else {
                    completion(.success)
                }
                
            }
            else{
                return
            }
        }
        
        sessionToken = (mwsResponse["session"] as? [String: AnyObject])?["token"] as? String
        isLoginApiActive = false
        
        if let serverTime = (mwsResponse["session"] as?[String: AnyObject])?["server_time"] as? Double{
            latestLoginTime = serverTime
        }
        
        if shouldRefresh {
          
            if !queuedCalls.isEmpty {
                for _ in 0...queuedCalls.count - 1 {
                    queuedCalls[0](completionCalls[0])
                    completionCalls.remove(at: 0)
                    queuedCalls.remove(at: 0)
                }
            }
         
            return
        }
        
        CoreDataManager.shared.saveLoginApi(LoginMwsResponse: mwsResponse)
    }
    
    func generateCoParentHTTPRequest(completion : @escaping (completionStatus) -> Void)  {
        
        if !isSessionAlive() {
           
            completionCalls.append(completion)
            self.queuedCalls.append(generateCoParentHTTPRequest(completion:))
            if !isLoginApiActive {
                generateHTTPRequest(shouldRefresh : true, mailId: loginMail, password: loginPass) { _ in }
                isLoginApiActive = true
            }
            return
        }
        
        guard let URL = URL(string: "https://webd.prgr.in/api/v2/user/list") else {
            print("invalid url!")
            return
        }
        
        var httpRequest = URLRequest(url: URL)
        httpRequest.httpMethod = "POST"
        httpRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        let token = sessionToken!
        let sessionHash =  String(data: vc.generateProfileHash(), encoding: .utf8)
        
        let message: [String: Any] =
        [
            "Request": [
                "Client": [
                    "id": "21V21B337GMX2",
                    "version": "2.0",
                    "session_hash": sessionHash
                ],
                "api": [
                    "app_version": "6.3",
                    "version": "1.0"
                ],
                "Session": [
                    "token" : token
                ]
            ]
        ]
    
        guard let encodedMessage = try? JSONSerialization.data(withJSONObject: message,options: .withoutEscapingSlashes) else{
                print("failed to encode!")
                return
        }
        
        let checkSum = vc.hmac(message: encodedMessage, token : token)
        
        let params =
        [
            "mwsRequest":
                [
                    "String" : message,
                    "Checksum" : checkSum
                ]
            
        ] as [String : Any]
        
        guard let encodedParams = try? JSONSerialization.data(withJSONObject: params,options: []) else {
                print("error encoding parameters")
                return
        }
        
        httpRequest.httpBody = encodedParams
   
        session.dataTask(with: httpRequest, completionHandler: {
            data, response, error in
            
            if let error = error {
                print("Unexpected Error: \(error)")
                return
            }
            guard let data = data, let response = response as? HTTPURLResponse else {
                return
            }
            
            if (200...299).contains(response.statusCode){
                guard let jsonData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject] else{
                    return
                }
                self.handleResponse(data: jsonData,completion: completion)
                
            }else{
                completion(.failure(code: "500", message: "network call failed!"))
                print("response failed ", response.statusCode)
                return
            }
            
        }).resume()
        
    }
 
    func handleResponse(data: [String: AnyObject],completion : (completionStatus) -> () ) {
        
        if let response = data["mwsResponse"] as? [String: AnyObject] , let status = response["status"] as? [String: AnyObject], let code = status["code"] as? String , let message = status["message"] as? String {
           
            if code == "000" {
                CoreDataManager.shared.saveUserListApi(coParentmwsResponse: response, mailId: loginMail)
                completion(.success)
            }
            else {
                completion(.failure(code: code, message: message))
            }
        }
    }
    
    func isSessionAlive() -> Bool {
        
        let currentTime = NSDate().timeIntervalSince1970
        
        if currentTime >=  latestLoginTime + (15.0 * 60.0) {
            return false
        }
        else {
            return true
        }
        
    }
    
    func isConnectedToNetwork() -> Bool {

        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)

        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }

        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
    
    enum completionStatus {
        case success
        case failure(code : String , message : String)
    }

}

