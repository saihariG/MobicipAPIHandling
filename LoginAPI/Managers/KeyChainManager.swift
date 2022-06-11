//
//  KeyChainManager.swift
//  LoginAPI
//
//  Created by Sai Hari on 24/05/22.
//

import Foundation

class KeyChainManager {
    
    static let shared = KeyChainManager()
    
    
    enum KeyChainError : Error {
        case Unknown(OSStatus)
        case duplicateEntry
    }
    
    
    func storeCredentials(server : String , email : String, password: String) throws {
        
        // trying to fetch credentials
        let query = [
          kSecClass as String: kSecClassInternetPassword,
          kSecAttrServer as String: server,
          kSecReturnAttributes as String: kCFBooleanTrue as Any,
          kSecReturnData as String: kCFBooleanTrue as Any
        ] as CFDictionary

        var result: AnyObject?
        var status = SecItemCopyMatching(query, &result)
     
        // if credentials are already stored, delete the old credentials
        if result != nil{
            
            let query = [
              kSecClass as String: kSecClassInternetPassword,
              kSecAttrServer as String: server
            ] as CFDictionary

            status = SecItemDelete(query)
            //print("deleted credentials : \(status)")
        }
        
        // saving new credentials
        let Query = [
            kSecClass as String: kSecClassInternetPassword,
            kSecAttrServer as String: server,
            kSecAttrAccount as String: email,
            kSecValueData as String: password.data(using: .utf8)!
        ] as CFDictionary

        let storeStatus = SecItemAdd(Query, nil)

        guard storeStatus != errSecDuplicateItem else {
            throw KeyChainError.duplicateEntry
        }
        
        guard storeStatus == errSecSuccess else {
            throw KeyChainError.Unknown(status)
        }
        
        //print("saved to Keychain \(status)")
    }
    
    func retreiveCredentials() -> [String : String] {
    
        let query = [
          kSecClass: kSecClassInternetPassword,
          kSecAttrServer: "https://webd.prgr.in/api/v2/login",
          kSecReturnAttributes: kCFBooleanTrue as Any,
          kSecReturnData: kCFBooleanTrue as Any
        ] as CFDictionary

        var result: AnyObject?
        let status = SecItemCopyMatching(query, &result)
        
       // print("retrieve status : \(status)")

        guard let result = result else {
            // print("result is nil!")
            return [:]
        }

        let dict = result as! NSDictionary

        let email = (dict[kSecAttrAccount] as? String) ?? ""
        let passwordData = dict[kSecValueData] as! Data
        let password = String(data: passwordData, encoding: .utf8)!
        
        let credentials : [String: String] = [
            "mailId" : email,
            "password" : password
        ]
        
        return credentials
    }
   
    func deleteData(){
        print("Logging out!")
        
        let query = [
          kSecClass as String: kSecClassInternetPassword,
          kSecAttrServer as String: "https://webd.prgr.in/api/v2/login"
        ] as CFDictionary

        let status = SecItemDelete(query)
        //print("deleting status : ", status)
    }
    
    
    
}
