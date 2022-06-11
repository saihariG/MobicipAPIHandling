//
//  SceneDelegate.swift
//  LoginAPI
//
//  Created by Sai Hari on 17/05/22.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }


}

/*
 
 func getImageString(index : Int) -> String? {
     guard let childUsers = mwsResponseDict?["managed_users"] as? [[String : AnyObject]] else {
         print("childUsers may be nil!")
         return nil
     }
     
     var i = 0
     var urlString : String?
     for childUser in childUsers {
         if i == index {
             urlString = childUser["thumbnail"] as? String
             break
         }
         i += 1
     }
     
     return urlString
 }
 
 func getChildName(index : Int) -> String? {
     
     guard let childUsers = mwsResponseDict?["managed_users"] as? [[String : AnyObject]] else {
         print("childUsers may be nil!")
         return nil
     }
     
     var i = 0
     var name : String?
     for childUser in childUsers {
         if i == index {
             name = childUser["name"] as? String
             break
         }
         i += 1
     }
     
     print("name is : \(String(describing: name))")
     return name
 }
 
 func getManagedUsersCount() -> Int {
     guard let childUsers = mwsResponseDict?["managed_users"] as? [[String : AnyObject]] else {
         print("childUsers may be nil!")
         return 0
     }
     
     print("number of children : \(childUsers.count)")
     
     return childUsers.count
 }
 
 
 
 */



/*   var i = 0

managedContext.performAndWait {
    let request = ManagedUser.fetchRequest()
    
    do {
        let results = try managedContext.fetch(request)
        
        for data in results as [NSManagedObject] {
            if i == index {
                let childName = data.value(forKey: "name") as! String
                name = childName
                break
            }
            i += 1
        }
    }
    catch {
        print("error fetching!")
    }
} */

        
      /*  guard let childUsers = mwsResponseDict?["managed_users"] as? [[String : AnyObject]] else {
            print("childUsers may be nil!")
            return 0
        }
        
        print("number of children : \(childUsers.count)")
        
        return childUsers.count */

/* if let url = managedUser.thumbnail {
    if i == index {
        urlString = url
        break
    }
    i += 1
} */


/*  func saveUserDetails(mwsResponse : [String : AnyObject]) {
      
      mwsResponseDict = mwsResponse
      
      guard let user = mwsResponse["user"] as? [String: AnyObject] else {
         return
      }
      
      let privateMOC = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
      privateMOC.parent = managedContext
      
  /*  print("userName : ", user["name"] as Any)
      print("userEmail : ",user["email"] as Any) */
       
      privateMOC.performAndWait {
          
          let User = User(context: privateMOC)
          
          User.name = user["name"] as? String
          User.email = user["email"] as? String
          
          if let managedUsers = mwsResponse["managed_users"] as? [[String: AnyObject]]{
          
              for managedUser in managedUsers {
                  let childUser = ManagedUser(context: privateMOC)
          
                  childUser.uuid = managedUser["uuid"] as? String
                  childUser.name = managedUser["name"] as? String
                  childUser.thumbnail = managedUser["thumbnail"] as? String
                  
                  if let date = managedUser["birth_date"] as? Int64 {
                      childUser.birth_date = date
                  }
                  
                  childUser.falcon_id = managedUser["falcon_id"] as? String
                  childUser.timezone = managedUser["timezone"] as? String
                  childUser.gender = managedUser["gender"] as? String
                  
                  if let filter_level_id = managedUser["filter_level_id"] as? Int64 {
                      childUser.filter_level_id = filter_level_id
                  }
                  
                  if let age = managedUser["age"] as? Int64 {
                      childUser.age = age
                  }
                  
                  User.addToManagedUsers(childUser)
              }
              
              saveChanges(pc: privateMOC)
          }
      } //
          
  } */



/*  func syncUserDetails(mwsResponse : [String : AnyObject], mailId : String) {
    
    let privateMOC = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
    privateMOC.parent = managedContext
    
    if let users = mwsResponse["managed_users"] as? [[String: AnyObject]] {
        let request = User.fetchRequest()
        request.predicate = NSPredicate(format: "email == %@", mailId)
        
        privateMOC.performAndWait {
            do{
              let managingUser = try privateMOC.fetch(request) as [User]
                
              if managingUser.count <= 0 {
                    return
              }
                
              for user in managingUser {
                print("inside sync : ",user.name)
              }
                
              if let managedUsers = managingUser[0].managedUsers?.allObjects as? [ManagedUser] {
                    for user in users {
                        if let uuid = user["uuid"] as? String{
                            var isSaved = false
                            
                            // checking if uuid already saved in core data
                            for managedUser in managedUsers {
                                if managedUser.uuid == uuid {
                                    isSaved = true
                                    break
                                }
                            }
                            
                            if !isSaved {
                                let newUser = ManagedUser(context: privateMOC)
                        
                                newUser.uuid = user["uuid"] as? String
                                newUser.name = user["name"] as? String
                                newUser.thumbnail = user["thumbnail"] as? String
                                if let date = user["birth_date"] as? Int64 {
                                    newUser.birth_date = date
                                }
                                newUser.falcon_id = user["falcon_id"] as? String
                                newUser.timezone = user["timezone"] as? String
                                newUser.gender = user["gender"] as? String
                                
                                
                                if let filter_level_id = user["filter_level_id"] as? Int64 {
                                    newUser.filter_level_id = filter_level_id
                                }
                                
                                if let age = user["age"] as? Int64 {
                                    newUser.age = age
                                }
                                
                                managingUser[0].addToManagedUsers(newUser)
                    
                                saveChanges(pc: privateMOC)
                            }
                        }
                    }
                } // end - if
                
            }catch{
                print("Error:", error)
            }
        } // end
        
        var uuidList = [String]()
        
        for user in users {
            if let uuid = user["uuid"] as? String{
                uuidList.append(uuid)
            }
        }
        
        // if the user is saved in core data but deleted from server,delete it in core data too
        do {
            let managingUser = try managedContext.fetch(request) as [User]
            
            if managingUser.count <= 0 {
                return
            }
            
            if let managedUsers = managingUser[0].managedUsers?.allObjects as? [ManagedUser]{
                for managedUser in managedUsers {
                    if !uuidList.contains(managedUser.uuid!){
                        managedContext.delete(managedUser)
                        saveChanges(pc: privateMOC)
                    }
                }
            }
        }catch{
            print("Error:", error)
        }
        
    }
} */

/* func isRegistered(mailId : String) -> Bool {
     
     let request = User.fetchRequest()
     
     request.fetchLimit = 1
     request.predicate = NSPredicate(format: "email == %@", "\(mailId)")
     
     let context = managedContext
     
     do{
         let result =  try context.fetch(request)
         if result.isEmpty {
             print("no user / not saved!")
             return false
         }
         print("saved user : \(mailId)")
         return true
     }catch{
         print("error!")
         return false
     }
  
 } */


/*  func getImage(mail : String) -> [UIImage]? {
   
    var images : [UIImage]?
     //  var i = 0
    // fetching image string for user
    let request = User.fetchRequest()
    request.predicate = NSPredicate(format : "email == %@","\(mail)")
    
    managedContext.performAndWait { [self] in
        do {
            print("processing.......!")
            let managingUser = try managedContext.fetch(request) as [User]
            
            if managingUser.count <= 0 {
                return
            }
            
            images = []
            
            if let managedUsers = managingUser[0].managedUsers?.allObjects as? [ManagedUser] {
            
                for managedUser in managedUsers {
                  
                    if managedUser.thumbnail == nil || managedUser.thumbnail == "" {
                        let img = UIImage(named: "default profile")
                        images?.append(img!)
                    }
                    else {
                       guard let thumbnail = managedUser.thumbnail else {
                            print("thumbnail is nil!")
                            return
                       }
                        
                       guard let url = URL(string: thumbnail) else { return }
                        
                       let data = try? Data(contentsOf: url)
                       if let imagedata = data {
                            let image = UIImage(data: imagedata)
                            images?.append(image!)
                       }
                       
                    }
                   
                }
            }
            
        }
        catch {
            print("error fetching imageString!")
        }
    }
    
    guard let imagesArr = images else {
        print("images arr is nil!")
        return nil
    }
    
   /* print("total urls \(urlStrings.count)")
    
    for string in urlStrings {
        print("image url : ",string)
    }
    
    */

    return imagesArr
}

func getChildName(mail : String) -> [String]? {
    
    var childnames : [String]?
    
    let request = User.fetchRequest()
    request.predicate = NSPredicate(format: "email == %@", "\(mail)")
   
 //   var i = 0
    
    managedContext.performAndWait { [self] in
        do{
            let managingUser = try managedContext.fetch(request) as [User]

            if managingUser.count <= 0 {
                return
            }
            
            childnames =  []
            
            if let managedUsers = managingUser[0].managedUsers?.allObjects as? [ManagedUser] {
                
                for managedUser in managedUsers {
                    
                    childnames?.append(managedUser.name!)
                }
            }
            
        }catch{
            print("Error Fethcing child name!")
        }
    }
    
    guard let childnames = childnames else {
        print("childnames is nil!")
        return nil
    }
    
    print("total child : \(childnames.count)")
    
    for string in childnames {
        
        print("child : " ,string)
    }

    
    return childnames
} */


// caching the image
//self.cache.setObject(image, forKey: urlString! as NSString)


// checking if the image is already cached
/*   if let image = cache.object(forKey: urlString! as NSString) as? UIImage {
    print("fetcing from cache!")
    cell.profileImg.image = image
    return cell
}
else {
    print("couldn't load from cache!")
}  */


/* let name = childnames[indexPath.row]

cell.childName.text = name
if urlImages[indexPath.row] == UIImage(named: "default profile") {
    guard let image = imageWith(name: name) else {
        print("profile image is nil")
        return cell
    }
    cell.profileImg.image =  image
}
else {
    cell.profileImg.image = urlImages[indexPath.row]
} */


//  var childnames : [String] = CoreDataManager.shared.getChildName(mail: ViewController.currentUserMail!) ?? []
//  var urlImages : [UIImage] = CoreDataManager.shared.getImage(mail: ViewController.currentUserMail!) ?? []


/*  guard let managedUsers = mwsResponse["managed_users"] as? [[String : AnyObject]] else { return }

for managedUser in managedUsers {
print(managedUser["name"] as! String)
}

*/


/*  func syncResponse(jsonData : Data , mailId : String)  {
    
    let jsonData = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: AnyObject]
  
    guard let mwsResponse = jsonData?["mwsResponse"] as? [String: AnyObject] else{
        print("unexpected error!")
        return
    }
    
    handleStatus(mwsResponse: mwsResponse)
    
    coreDataContext.syncUserDetails(mwsResponse: mwsResponse, mailId: mailId)
    
    ViewController.currentUserMail = mailId
    
    coreDataContext.displayData()
    
    if canLogin {
      DispatchQueue.main.async {
          self.spinner.stopAnimating()
          self.spinner.isHidden = true
          let storyboard = UIStoryboard(name: "Main", bundle: nil)
          let vc = storyboard.instantiateViewController(identifier: "childVC")
          self.navigationController?.pushViewController(vc, animated: true)
      }
    }
          
} */


/* if !nameList.contains(managedUser.name!) {
     isUpdated = true
 managedUser.name = nameList[]
 } */

/*    if nameList[idx] != managedUser.name! {
     isUpdated = true
     print("name updated from \(String(describing: managedUser.name)) to \(nameList[idx])")
     managedUser.name = nameList[idx]
     saveChanges(pc: privateMOC)
     }

     if profileList[idx] != managedUser.thumbnail ?? "" {
isUpdated = true
print("url updated from \(String(describing: managedUser.thumbnail)) to \(profileList[idx])")
managedUser.thumbnail = profileList[idx]
saveChanges(pc: privateMOC)
}

idx += 1 */
   
/*print("name from core data --> ",managedUser.name)

var i = 0
var isNameFound = false
for name in nameList {
    print("\(name) == \(managedUser.name) ?")
    if nameList[i] == managedUser.name {
        isNameFound = true
        break
    }
    i += 1
}

if !isNameFound {
    print("name not found !")
}
rint("name from response : \(user)") */

/*   if !isNameFound {
 isUpdated = true
 managedUser.name = nameList[i]
 print("name updated !!!!!!")
 } */

// checking if name and profile has been updated
/*   do {
    let managingUser = try managedContext.fetch(request) as [User]
    
    if let managedUsers = managingUser[0].managedUsers?.allObjects as? [ManagedUser] {
        
        
        for childUser in childUsers {
            if let name = childUser["name"] as? String {
                
                var isNameSaved = false
                
               // var mUser : ManagedUser?
                var i = 0
                // searching if name exists
                for managedUser in managedUsers {
                    print("\(managedUser.name) == \(name) ?? ")
                    if managedUser.name! == name {
                        //mUser = managedUser
                        isNameSaved = true
                        break
                    }
                    
                }
                
                print("is saved : \(isNameSaved)")
        
                if !isNameSaved {
                    managedUsers[4].name! = name
                    
                    print("name updated from \(String(describing: managedUsers[4].name)) to \(name)")
                    saveChanges(pc: privateMOC)
                }
                
            }
        }
        
    }
}
catch {
    print("Error!")
} */



/* func saveCoParentDetails(LoginmwsResponse : [String : AnyObject],coparentmwsResponse : [String : AnyObject],mailId : String) {
    
    let privateMOC = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
    privateMOC.parent = managedContext
    
                
    if let coParents = coparentmwsResponse["users"] as? [[String : AnyObject]] {
    
        let request = User.fetchRequest()
        request.predicate = NSPredicate(format: "email == %@",mailId)
        
        privateMOC.performAndWait {
            do {
            
                let managingUser = try privateMOC.fetch(request) as [User]
                
                if managingUser.count <= 0 {
                    print("registering new user...!")
                    guard let user = LoginmwsResponse["user"] as? [String: AnyObject] else {
                       return
                    }
                   
                
                    let User = User(context: privateMOC)
                    
                    User.name = user["name"] as? String
                    User.email = user["email"] as? String
                    
                    // storing all co-parents
                    for coParent in coParents {
                    
                        let coparent = CoParent(context: privateMOC)
                    
                        coparent.name = coParent["name"] as? String
                        coparent.thumbnail = coParent["thumbnail"] as? String
                        coparent.uuid = coParent["uuid"] as? String

                        User.addToCoParent(coparent)
                        
                        
                        // for each co-parent save its child
                        if let childUsers = coParent["managed_users"] as? [[String : AnyObject]] {
                            for childUser in childUsers {
                                let childuser = ManagedUser(context: privateMOC)
                                
                               
                                childuser.uuid = childUser["uuid"] as? String
                                childuser.name = childUser["name"] as? String
                                childuser.thumbnail = childUser["thumbnail"] as? String
                                
                                if let date = childUser["birth_date"] as? Int64 {
                                    childuser.birth_date = date
                                }
                                
                                childuser.falcon_id = childUser["falcon_id"] as? String
                                childuser.timezone = childUser["timezone"] as? String
                                childuser.gender = childUser["gender"] as? String
                                
                                if let filter_level_id = childUser["filter_level_id"] as? Int64 {
                                    childuser.filter_level_id = filter_level_id
                                }
                                
                                if let age = childUser["age"] as? Int64 {
                                    childuser.age = age
                                }
                                
                                coparent.addToManagedUser(childuser)
                                
                            }
                        }
                    
                        
        
                    }
                    
                    saveChanges(pc: privateMOC)
                }
                else {
                    print("user already registered! syncing details!!")
                }
                
            }
            catch {
                print("unexpected error!")
            }
        }
        
    }
    
    
} */

// storing all the child details to core data
/*    for childuser in childUsers {
        let childUser = ManagedUser(context: privateMOC)

        childUser.uuid = childuser["uuid"] as? String
        childUser.name = childuser["name"] as? String
        childUser.thumbnail = childuser["thumbnail"] as? String
        
        if let date = childuser["birth_date"] as? Int64 {
            childUser.birth_date = date
        }
        
        childUser.falcon_id = childuser["falcon_id"] as? String
        childUser.timezone = childuser["timezone"] as? String
        childUser.gender = childuser["gender"] as? String
        
        if let filter_level_id = childuser["filter_level_id"] as? Int64 {
            childUser.filter_level_id = filter_level_id
        }
        
        if let age = childuser["age"] as? Int64 {
            childUser.age = age
        }
        
        user.addToManagedUsers(childUser)
} */

/*
else {
    print("user already saved ! Syncing details....!")
    
    if let managedUsers = managingUser[0].managedUsers?.allObjects as? [ManagedUser] {
        // iterating through all the child users
        for childUser in childUsers {
            if let uuid = childUser["uuid"] as? String {
               
                // variable indicating if the child user is saved
                var isSaved = false
           
                // checking if uuid already saved in core data
                for managedUser in managedUsers {
                    if managedUser.uuid == uuid {
                        // updating name
                        if let name = childUser["name"] as? String {
                            if managedUser.name != name {
                                managedUser.name = name
                            }
                        }
                        
                        if let thumbnail = childUser["thumbnail"] as? String {
                            // checking if thumbnail from response is same as from db
                            if managedUser.thumbnail != thumbnail {
                               managedUser.thumbnail = thumbnail
                               // since the thumbnail is updated, deleting it from cache
                               ChildViewController.deleteImageFromFileManager(imageName: managedUser.uuid!)
                            }
                        }
                        
                        // updating bday
                        if let bday = childUser["birth_date"] as? Int64 {
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
            
                    newUser.uuid = childUser["uuid"] as? String
                    newUser.name = childUser["name"] as? String
                    newUser.thumbnail = childUser["thumbnail"] as? String
                    if let date = childUser["birth_date"] as? Int64 {
                        newUser.birth_date = date
                    }
                    newUser.falcon_id = childUser["falcon_id"] as? String
                    newUser.timezone = childUser["timezone"] as? String
                    newUser.gender = childUser["gender"] as? String
                    
                    
                    if let filter_level_id = childUser["filter_level_id"] as? Int64 {
                        newUser.filter_level_id = filter_level_id
                    }
                    
                    if let age = childUser["age"] as? Int64 {
                        newUser.age = age
                    }
                    
                    managingUser[0].addToManagedUsers(newUser)
        
                    saveChanges(pc: privateMOC)
                }
               
            }
        }
       
    }
    
    var uuidList = [String]()
    
    for user in childUsers {
        if let uuid = user["uuid"] as? String{
            uuidList.append(uuid)
        }
    }

    // if the user is saved in core data but deleted from server,delete it in core data too
    do {
        let managingUser = try managedContext.fetch(request) as [User]
        
        if let managedUsers = managingUser[0].managedUsers?.allObjects as? [ManagedUser]{
                   
                   for managedUser in managedUsers {
                       if !uuidList.contains(managedUser.uuid!) {
                           print("deleting data...!")
                           managedContext.delete(managedUser)
                           saveChanges(pc: privateMOC)
                       }
                
                   }
        }
        
    }catch{
        print("Error:", error)
    }
    
}
*/






/*  if let coParents = parentUser[0].coParents?.allObjects as? [User] {

    for coParent in coParents {
        
        if let childUsers = coParent.managedUsers?.allObjects as? [ManagedUser] {
            for childUser in childUsers {
                print(childUser.name!)
            }
        }
        else {
            
        }
    }

}
else {
    
} */

/*   func saveCoParentDetails(LoginmwsResponse : [String : AnyObject],coparentmwsResponse : [String : AnyObject],mailId : String) {
       
       let privateMOC = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
       privateMOC.parent = managedContext
       
                   
       if let coParents = coparentmwsResponse["users"] as? [[String : AnyObject]] {
       
           let request = User.fetchRequest()
           request.predicate = NSPredicate(format: "email == %@",mailId)
                               
                   for coParent in coParents {
                       let role = (coParent["role"])!["name"]! as? String
                       
                       if role != "owner" {
                           print("  \(coParent["email"]!) -->  \(role!)")
                       }
                       
                   }
       }
       
       
   } */



// returns an array of child users , each user containing it's specific information
/*  func fetchChildList(mail : String) -> [ManagedUser] {
    
    var childusersList : [ManagedUser] = []
    
    let request = User.fetchRequest()
    request.predicate = NSPredicate(format: "email == %@", "\(mail)")
    
    managedContext.performAndWait {
    
     do {
        let parentUser = try managedContext.fetch(request) as [User]
        
        if let childUsers = parentUser[0].managedUsers?.allObjects as? [ManagedUser] {
            
            for childUser in childUsers {
                childusersList.append(childUser)
            }
    
        }
        
     }
     catch
     {
        print("unexpected error while fetching!")
     }
     
    }
    
    return childusersList
} */




// returns the count of number of child for that parent
/*  func getManagedUsersCount(mail : String) -> Int {
    
    let request = User.fetchRequest()
    request.predicate = NSPredicate(format: "email == %@", "\(mail)")
   
    var count = 0
    managedContext.performAndWait {
        do{
            let managingUser = try managedContext.fetch(request) as [User]

            if managingUser.count <= 0 {
                return
            }
        
            if let managedUsers = managingUser[0].managedUsers?.allObjects as? [ManagedUser] {
              
                //print("number of children : ",managedUsers.count)
                count = managedUsers.count
                    
            }
        }
        catch {
            print("error fetching count")
        }
    }
    
    return count
} */

// fetching details of the specified child name in an array
/*  func getChildDetails(name : String) -> [String]? {
    
    var arr : [String]?
    
    let request = ManagedUser.fetchRequest()
    request.predicate = NSPredicate(format: "name == %@", "\(name)")
    
    do {
        let managedUser = try managedContext.fetch(request) as [ManagedUser]
        
        if managedUser.count <= 0{
            return nil
        }
   
        let user = managedUser[0]
        arr = []
    
        arr?.append(String(user.age))
        
        if let gender = user.gender {
            arr?.append(gender)
        }
        else {
            arr?.append("nil")
        }
        
        arr?.append(String(user.birth_date))
    
        arr?.append(user.uuid!)
        
        if let zone = user.timezone {
          arr?.append(zone)
        }
        else {
            arr?.append("nil")
        }
        
        if let fid = user.falcon_id {
            arr?.append(fid)
        }
        else {
            arr?.append("nil")
        }
        
        arr?.append(String(user.filter_level_id))
        
    }catch{
        print("Error")
    }
    
    return arr
} */

// function to handle response status
/*  func handleStatus(mwsResponse : [String : AnyObject]) -> Int {
    var statusCode = 0
    
    if let status = mwsResponse["status"] as? [String: AnyObject]{
        if let code = status["code"] as? String {
            // "000" -> represents success
            if code != "000" {
                // if code is not success , then set canLogin to false
                DispatchQueue.main.async {
                    self.loginBtn.isEnabled = true
                    self.spinner.isHidden = true
                }
                
                if code == "004" {
                    self.showAlert(code: code, message: "checksum error!")
                }
                else if code == "006" {
                    self.showAlert(code: code, message: "missing parameters")
                }
                else if code == "007" {
                    self.showAlert(code: code, message: "content-type not set in header")
                }
                else {
                    if let message = status["message"] as? String {
                        self.showAlert(code: code, message: message)
                    }
                    else {
                        self.showAlert(code: code, message: "unknown error")
                    }
                }
                statusCode = -1
            }
            else {
                canLogin = true
                statusCode = 1
            }
        }
        else{
            print("error in status code!")
            statusCode = -1
        }
    }

    return statusCode
} */

/*   func fetchCoParentsCount() -> Int {
       let request = User.fetchRequest()
       let mailId = ViewController.currentUserMail!
       request.predicate = NSPredicate(format: "email == %@" , mailId)
       var count = 0
       
       do {
           let parentUser = try managedContext.fetch(request) as [User]
           
           if parentUser.isEmpty {
               return 0
           }
           
           guard let coParents = parentUser[0].coParents?.allObjects as? [User] else { return 0 }
           
           count = coParents.count
            
       }
       catch {
           print("error ")
       }
       
       return count
   } */

/* func displayData() {
    
    let request = User.fetchRequest()
   
    if let results = try? CoreDataManager.shared.managedContext.fetch(request) {
        for result in results {
           // print(result)
            print(result.managedUsers?.allObjects as Any)
        }
    }
    
}
 
 
 // no of unique saved users in core data
 func noOfSavedUsers() {
     let req = User.fetchRequest()
     
     do {
         let managingUser = try managedContext.fetch(req) as [User]
         print("------no of registered users : \(managingUser.count)------")
         for users in managingUser {
             print(users.email as Any)
         }
     }
     catch {
         print("error!")
     }
 }
 

 
 
 */
