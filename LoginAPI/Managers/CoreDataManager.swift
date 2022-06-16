//
//  CoreDataManager.swift
//  LoginAPI
//
//  Created by Sai Hari on 17/05/22.
//

import CoreData
import UIKit

class CoreDataManager {
    
    // shared instance for CoreDataManager class
    static let shared = CoreDataManager()

    let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let manager = FileSystemManager.shared
    //var coChildCount = 0
    
    func saveChanges(pc : NSManagedObjectContext) {
    
        guard pc.hasChanges || managedContext.hasChanges else {
            //print("no changes to save!")
            return
        }
    
        pc.performAndWait {
            do {
                try pc.save()
                //print("saved pc!")
            }
            catch {
                print("error saving background!")
            }
        }
    
        managedContext.perform {
            do {
                try self.managedContext.save()
               // print("main context saved")
            }
            catch {
                print("error saving main!")
            }
        }
    
    }
    
    func saveChildDetailsFromAPI(childuser : ManagedUser , childApi : [String : AnyObject]) {
        
        childuser.uuid = childApi["uuid"] as? String
        childuser.name = childApi["name"] as? String
        childuser.thumbnail = childApi["thumbnail"] as? String
        
        if let date = childApi["birth_date"] as? Int64 {
            childuser.birth_date = date
        }
        
        childuser.falcon_id = childApi["falcon_id"] as? String
        childuser.timezone = childApi["timezone"] as? String
        childuser.gender = childApi["gender"] as? String
        
        if let filter_level_id = childApi["filter_level_id"] as? Int64 {
            childuser.filter_level_id = filter_level_id
        }
        
        if let age = childApi["age"] as? Int64 {
            childuser.age = age
        }
    }
    
    func saveLoginApi(LoginMwsResponse : [String : AnyObject]) {
        
        let privateMOC = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateMOC.parent = managedContext
        
        guard let userApiData = LoginMwsResponse["user"] as? [String: AnyObject] , let userMail = userApiData["email"] as? String,let managedUsersApi = LoginMwsResponse["managed_users"] as? [[String : AnyObject]] else {
            return
        }
       
        
        privateMOC.performAndWait {
            
            let userRequest = User.fetchRequest()
            userRequest.predicate = NSPredicate(format: "email == %@", userMail)
            
            if let existingParent = try? privateMOC.fetch(userRequest) {
                
                if existingParent.isEmpty {
                    print("registering new user...!")
                    let parentUser = User(context: privateMOC)
                    // create new user
                    parentUser.name = userApiData["name"] as? String
                    parentUser.email = userApiData["email"] as? String
                    parentUser.thumbnail = userApiData["thumbnail"] as? String
                    
                    for managedUserApi in managedUsersApi {
                        let childUser = ManagedUser(context: privateMOC)
                        
                        saveChildDetailsFromAPI(childuser: childUser, childApi: managedUserApi)
                        
                        parentUser.addToManagedUsers(childUser)
                        childUser.addToUser(parentUser)
                    }
                }
                else {
                    // update information
                    print("user already registered!")
                    let managingUser = existingParent[0]
                    managingUser.name = userApiData["name"] as? String
                    managingUser.thumbnail = userApiData["thumbnail"] as? String
                  
                    if let managedUsers = managingUser.managedUsers?.allObjects as? [ManagedUser] {
                        
                        for managedUserApi in managedUsersApi {
                            var isSaved = false
                            for managedUser in managedUsers {
                                if managedUser.uuid == managedUserApi["uuid"] as? String {
                                    // updating name
                                    if let name = managedUserApi["name"] as? String {
                                        if managedUser.name != name {
                                            managedUser.name = name
                                        }
                                    }
                                    
                                    if let thumbnail = managedUserApi["thumbnail"] as? String {
                                        // checking if thumbnail from response is same as from db
                                        if managedUser.thumbnail != thumbnail {
                                           managedUser.thumbnail = thumbnail
                                           // since the thumbnail is updated, deleting it from cache
                                           manager.deleteImageFromFileManager(imageName: managedUser.uuid!)
                                        }
                                    }
                                    
                                    // updating bday
                                    if let bday = managedUserApi["birth_date"] as? Int64 {
                                        if managedUser.birth_date != bday {
                                            managedUser.birth_date = bday
                                        }
                                    }
                                    
                                    saveChanges(pc: privateMOC)
                                    
                                    isSaved = true
                                    break
                                }
                            }
                            
                            // if uuid not saved, means new user updated in server, so save it to core data
                            if !isSaved {
                                let newUser = ManagedUser(context: privateMOC)
                        
                                saveChildDetailsFromAPI(childuser: newUser, childApi: managedUserApi)
                                
                                managingUser.addToManagedUsers(newUser)
                                newUser.addToUser(managingUser)
                                
                                saveChanges(pc: privateMOC)
                            }
                        }
                    }
                    
                    var uuidList = [String]()
                    
                    for user in managedUsersApi {
                        if let uuid = user["uuid"] as? String{
                            uuidList.append(uuid)
                        }
                    }
                
                    // if the user is saved in core data but deleted from server,delete it in core data too
                    do {
                        let managingUser = try managedContext.fetch(userRequest) as [User]
                        
                        if let managedUsers = managingUser[0].managedUsers?.allObjects as? [ManagedUser]{
                                   
                                   for managedUser in managedUsers {
                                       if !uuidList.contains(managedUser.uuid!) {
                                           print("deleting data...!")
                                           managedContext.delete(managedUser)
                                           saveChanges(pc: privateMOC)
                                       }
                                
                                   }
                        }
                        
                    }catch {
                        print("Error:", error)
                    }
                    
                }
                
                saveChanges(pc: privateMOC)
            }
        
        }
    
    }
    
    // function to save a new user details to core data. if user details already saved, then syncs updated information
    func saveUserListApi(coParentmwsResponse : [String : AnyObject] ,mailId : String) {
        
        let privateMOC = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateMOC.parent = managedContext
        
        guard let coParents = coParentmwsResponse["users"] as? [[String : AnyObject]]  else {
            return
        }

        let request = User.fetchRequest()
        request.predicate = NSPredicate(format: "email == %@",mailId)
            
        privateMOC.performAndWait {
            
            do {
                let managingUser = try privateMOC.fetch(request) as [User]
            
                if managingUser.isEmpty {
                    return 
                }
                
                guard let coUsers = managingUser[0].coParents?.allObjects as? [User] else { return }
                
                // means user is not registered , so save new user
                if coUsers.count <= 0 {
                    print("registering new user lists")
                   
                    for coParent in coParents {
                        
                        let coUser = User(context: privateMOC)
                        
                        let role = (coParent["role"])!["name"]! as? String
                        
                        if role != "owner" {
                            //print("  \(coParent["email"]!) -->  \(role!)")
                            coUser.name = coParent["name"] as? String
                            coUser.email = coParent["email"] as? String
                            coUser.thumbnail = coParent["thumbnail"] as? String
                            
                            managingUser[0].addToCoParents(coUser)
  
                            // for each co-parent save its child
                            if let childUsers = coParent["managed_users"] as? [[String : AnyObject]] {
                                for childUser in childUsers {
                                    
                                    let childuser = ManagedUser(context: privateMOC)
                                    
                                    saveChildDetailsFromAPI(childuser: childuser, childApi: childUser)
                                    
                                    coUser.addToManagedUsers(childuser)
                                   
                                    childuser.addToUser(coUser)
                                }
                            }
                        }
                        
                       
                    }
                    
                    saveChanges(pc: privateMOC)
                }
                else {
                    print("Syncing user list!!!")
                    var isUpdated = false
                    
                    if let coParentUsers = managingUser[0].coParents?.allObjects as? [User]  {
                        // iterate through all the co-parents from core-data
                        for coParent in coParents {
                            
                            guard let coChildrenApi = coParent["managed_users"] as? [[String : AnyObject]] else {
                                return
                            }
                            
                            if let mail = coParent["email"] as? String {
                                var isCoParentSaved = false
                                
                                for coParentUser in coParentUsers {
                                    if coParentUser.email == mail {
                                        
                                        // updating co-parent's name
                                        if let name = coParent["name"] as? String {
                                            if coParentUser.name != name {
                                                isUpdated = true
                                                print("co-parent name updated!")
                                                coParentUser.name = name
                                            }
                                        }
                                        
                                        // updating co-parent's thumbnail
                                        if let thumbnail = coParent["thumbnail"] as? String {
                                            if coParentUser.thumbnail != thumbnail {
                                                isUpdated = true
                                                print("co-parent thumbnail updated!")
                                                coParentUser.thumbnail = thumbnail
                                                manager.deleteImageFromFileManager(imageName: coParentUser.email!)
                                            }
                                        }
                                        
                                        saveChanges(pc: privateMOC)
                                        
                                        // for each-coparent check if any of it's child is updated
                                        if let coChildren = coParentUser.managedUsers?.allObjects as? [ManagedUser] {
                                            
                                            for coChildApi in coChildrenApi {
                                                
                                                if let uuid = coChildApi["uuid"] as? String {
                                                    var isCoChildSaved = false
                                                    
                                                    for coChild in coChildren {
                                                        if coChild.uuid == uuid {
                                                            
                                                            // updating name and thumbnail and bday
                                                            if let name = coChildApi["name"] as? String {
                                                                if coChild.name != name {
                                                                    isUpdated = true
                                                                    print("updating co-child name!")
                                                                    coChild.name = name
                                                                }
                                                            }
                                                            
                                                            if let thumbnail = coChildApi["thumbnail"] as? String {
                                                                if coChild.thumbnail != thumbnail {
                                                                    isUpdated = true
                                                                    print("updating co-child thumbnail!")
                                                                    coChild.thumbnail = thumbnail
                                                                    manager.deleteImageFromFileManager(imageName: coChild.uuid!)
                                                                }
                                                            }
                                                            
                                                            if let bday = coChildApi["birth_date"] as? Int64 {
                                                                if coChild.birth_date != bday {
                                                                    isUpdated = true
                                                                    print("updating co-child's bday!")
                                                                    coChild.birth_date = bday
                                                                }
                                                            }
                                                            
                                                            saveChanges(pc: privateMOC)
                                                            
                                                            isCoChildSaved = true
                                                            break
                                                        }
                                                    } //
                                                    
                                                    if !isCoChildSaved {
                                                        
                                                        let newChild = ManagedUser(context: privateMOC)
                                                        
                                                        saveChildDetailsFromAPI(childuser: newChild, childApi: coChildApi)
                                                        
                                                        print("new child added to co-parent!")
                                                        isUpdated = true
                                                        
                                                        coParentUser.addToManagedUsers(newChild)
                                                        
                                                        newChild.addToUser(coParentUser)
                                                    }
                                                    
                                                }
                                                
                                            }
                                            
                                        
                                        }
                                        
                                        saveChanges(pc: privateMOC)
                                        isCoParentSaved = true
                                        break
                                    }
                                }
                                
                                if !isCoParentSaved {
                                    let newUser = User(context: privateMOC)
                                    
                                    let role = (coParent["role"])!["name"]! as? String
                                    
                                    if role != "owner" {
                                        
                                        newUser.name = coParent["name"] as? String
                                        newUser.email = coParent["email"] as? String
                                        newUser.thumbnail = coParent["thumbnail"] as? String
                                        
                                        managingUser[0].addToCoParents(newUser)
                                        
                                        print("new co-parent added!")
                                        
                                        for child in coChildrenApi {
                                            let childuser = ManagedUser(context: privateMOC)
                                            
                                            saveChildDetailsFromAPI(childuser: childuser, childApi: child)
                                            
                                            newUser.addToManagedUsers(childuser)
                                            childuser.addToUser(newUser)

                                        }
                                    
                                    }
                                    
                                    isUpdated = true
                                    saveChanges(pc: privateMOC)
                                }
                                
                            }
                        }
                        
                    }
                    
                    var mailList = [String]()
                    
                    for coParent in coParents {
                        
                        guard let email = coParent["email"] as? String else {
                            return
                        }
                        
                        
                        let role = (coParent["role"])!["name"]! as? String
                        
                        if role != "owner" {
                           mailList.append(email)
                        }
                        
                        // for each managed user check if any child is deleted from server
                        var uuidList = [String]()
                        
                        if let childUsers = coParent["managed_users"] as? [[String : AnyObject]] {
                            
                            for childUser in childUsers {
                                if let uuid = childUser["uuid"] as? String {
                                    uuidList.append(uuid)
                                }
                            }
                            
                            do {
                                let request = User.fetchRequest()
                                request.predicate = NSPredicate(format: "email == %@" , "\(email)")
                                
                                let coParentUser = try managedContext.fetch(request) as [User]
                                
                                if let childUsers = coParentUser[0].managedUsers?.allObjects as? [ManagedUser] {
                                    
                                    for childUser in childUsers {
                                        if !uuidList.contains(childUser.uuid!) {
                                            isUpdated = true
                                            print("deleting child!")
                                            managedContext.delete(childUser)
                                            saveChanges(pc: privateMOC)
                                        }
                                            
                                    }
                                }
                                
                            }
                            catch {
                                print("error!")
                            }
                        }
                        
                    }
                    
                    do {
                        let primaryUser = try managedContext.fetch(request) as [User]
                        
                        if let coParents = primaryUser[0].coParents?.allObjects as? [User] {
                            
                            for coParent in coParents {
                                if !mailList.contains(coParent.email!) {
                                    isUpdated = true
                                    print("deleting co-parent")
                                    managedContext.delete(coParent)
                                    saveChanges(pc: privateMOC)
                                }
                            }
                        }
                        
                    }
                    catch {
                        print("error!")
                    }
                    
                    if isUpdated {
                       // print("synced details!")
                    }
                    else {
                       // print("no updates to sync!")
                    }
                    
                } // end - else
                
            }
            catch {
                print("error fetching !")
            }
        }
        
    }
   
    func fetchCoParentList() -> [User] {
        
        var coParentsList : [User] = []
        
        let request = User.fetchRequest()
        
        let credentials = KeyChainManager.shared.retreiveCredentials()
        let mailId = credentials["mailId"]
        
        request.predicate = NSPredicate(format: "email == %@" , mailId!)
        //let sort = NSSortDescriptor(key: "name", ascending: true,selector: #selector(NSString.caseInsensitiveCompare(_:)))
        //request.sortDescriptors = [sort]
        
        managedContext.performAndWait  { [self] in
            do {
                let parentUser = try managedContext.fetch(request) as [User]
            
                if parentUser.isEmpty {
                    return
                }
            
                if let coParents = parentUser[0].coParents?.allObjects as? [User] {
            
                    for coParent in coParents {
                        coParentsList.append(coParent)
                    }
          
                }
        
            }
            catch {
                print("error ")
            }
        }
        
        return coParentsList
    }
    
    func fetchCoParentChildList(mailId : String) -> [ManagedUser] {
        
        var coChildList : [ManagedUser] = []
        let request = User.fetchRequest()
     
        request.predicate = NSPredicate(format: "email == %@" , "\(mailId)")
        //let sort = NSSortDescriptor(key: "name", ascending: true,selector: #selector(NSString.caseInsensitiveCompare(_:)))
        //request.sortDescriptors = [sort]
        
        managedContext.performAndWait {
            
            do {
            
                let parentUser = try managedContext.fetch(request) as [User]
            
                if let childUsers = parentUser[0].managedUsers?.allObjects as? [ManagedUser] {
                    //coChildCount = childUsers.count
                    for childUser in childUsers {
                        coChildList.append(childUser)
                    }
                }
            
            }
            catch {
                print("error fetching!")
            }
        }
        
        print(coChildList.count)
        return coChildList
    }

    func fetchCoParentChildDetails(uuid : String) -> ManagedUser? {
     
        var childUser : ManagedUser?
        
        let request = ManagedUser.fetchRequest()
        request.predicate = NSPredicate(format: "uuid == %@", "\(uuid)")
       
        do {
            let managedUser = try managedContext.fetch(request) as [ManagedUser]
            
            if managedUser.count <= 0 {
                return nil
            }
       
            let user = managedUser[0]
           
            childUser = user
        }
        catch {
            print("error ")
        }
        
        return childUser
    }
    
    func deleteData(mailId : String) {

        let privateMOC = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateMOC.parent = managedContext
        
        let request = User.fetchRequest()
        request.predicate = NSPredicate(format: "email == %@" , "\(mailId)")
        
        privateMOC.perform { [self] in
            do
            {
                let user = try managedContext.fetch(request)
        
                if user.isEmpty {
                    return
                }
                else {
                
                    print("user deleted")
                    managedContext.delete(user.first!)
            
                }
            
                saveChanges(pc: privateMOC)
            }
            catch
            {
                print("error fetching!")
            }
        
        }
        
    }
 
}


