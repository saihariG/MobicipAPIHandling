//
//  FileSystemManager.swift
//  LoginAPI
//
//  Created by Sai Hari on 16/06/22.
//

import Foundation
import UIKit

class FileSystemManager {
    static let shared = FileSystemManager()
    
    let fileManager = FileManager.default
    
    func getImageFromFileManager(imageName : String) -> UIImage? {
        
        guard let path = getImagePath(name: "\(imageName)")?.path  else {
            print("error getting path!")
            return nil
        }

        guard fileManager.fileExists(atPath: path) == true else {
            // print("file not exists!")
            return nil
        }
        
        return UIImage(contentsOfFile: path)
    }
    
    
    func getImagePath(name : String) -> URL? {
        guard let path = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first?.appendingPathComponent("\(name).jpg") else {
            print("can't get path!")
            return nil
        }
        return path
    }
    
    func deleteImageFromFileManager(imageName : String) {
        
        guard let cacheDir = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            print("error : couldn't find directory")
            return
        }
        
        let imgfile = cacheDir.appendingPathComponent("\(imageName).jpg")
        
        if fileManager.fileExists(atPath: imgfile.path) {
            do {
                try fileManager.removeItem(at: imgfile)
                print("\(imageName) deleted successfully!")
            }
            catch {
                print("error deleting file!")
            }
        }
        else {
            print("404 not found!")
        }
        
    }
    
    func clearCache() {
        guard let cacheDir = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            print("error : couldn't find directory")
            return
        }
        
        do {
            // Get the directory contents urls (including subfolders urls)
            let directoryContents = try fileManager.contentsOfDirectory( at: cacheDir, includingPropertiesForKeys: nil, options: [])
            for file in directoryContents {
                do {
                    try fileManager.removeItem(at: file)
                }
                catch let error as NSError {
                    debugPrint("Ooops! Something went wrong: \(error)")
                }

            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    
    }
}
