//
//  ChildViewController.swift
//  LoginAPI
//
//  Created by Sai Hari on 17/05/22.
//

import UIKit

class ChildViewController: UIViewController {

    
    @IBOutlet weak var collectionView: UICollectionView!
    
    // variable to store selected row in collection view
    var selectedChildIndex = -1
    // variable for total no of children
    var noOfChildren = 0
    
    // file manager instance
    let manager = FileManager.default
    
    var parentEmail = ""
    var parentName = ""
    
    var coChildList : [ManagedUser] = []
    
    deinit {
       // print("deallocated")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        collectionView.delegate = self
        collectionView.dataSource = self
        
        coChildList =  CoreDataManager.shared.fetchCoParentChildList(mailId: parentEmail)
        if coChildList.isEmpty {
            collectionView.isHidden = true
        }
       
        title = "Children of \(parentName)"
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueIdentifier" {
            let vc = segue.destination as! DetailsViewController
            vc.name = coChildList[selectedChildIndex].name!
            vc.uuid = coChildList[selectedChildIndex].uuid!
        }
    }
    
    // function to return image with initials based on the first few characters of the given name
    func imageWith(name: String?) -> UIImage? {
        
        let frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        let nameLabel = UILabel(frame: frame)
        nameLabel.layer.masksToBounds = true
        nameLabel.layer.cornerRadius = 25.0
        nameLabel.textAlignment = .center
        nameLabel.backgroundColor = .lightGray
        nameLabel.textColor = .darkGray
        nameLabel.font = UIFont.boldSystemFont(ofSize: 20)
      
        var initial : String.SubSequence?
        if name!.count < 3 {
            initial = name?.prefix(through: String.Index(utf16Offset: 1, in: name!))
        }
        else {
            initial = name?.prefix(through: String.Index(utf16Offset: 2, in: name!))
        }
        //print("initial is : \(String(describing: initial?.uppercased()))")
    
        nameLabel.text = initial?.uppercased()
        UIGraphicsBeginImageContext(frame.size)
        if let currentContext = UIGraphicsGetCurrentContext() {
               nameLabel.layer.render(in: currentContext)
               let nameImage = UIGraphicsGetImageFromCurrentImageContext()
               return nameImage
        }
        return nil
    }

}


extension ChildViewController : UICollectionViewDataSource {
    // delegate function to set no of items in collection view
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return coChildList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellIdentifier", for: indexPath) as! CustomCollectionViewCell
        
        guard let uuid = coChildList[indexPath.row].uuid else {
            print("uuid is nil")
            return cell
        }
        
        // fetching name from child list and setting to label
        guard let name = coChildList[indexPath.row].name else {
            print("name may be nil!")
            return cell
        }
        cell.childName.text = name
        
        let urlString = coChildList[indexPath.row].thumbnail

        // if urlString is empty or nil, set image based on initials
        if urlString == "" || urlString == nil {
            guard let image = imageWith(name: name) else {
                return cell
            }
            cell.profileImg.image = image
            return cell
        }
        
        // checking if image is already downloaded in file manager
        if let image = getImageFromFileManager(imageName: uuid) {
            cell.profileImg.image = image
            return cell
        }
        
        guard let url = URL(string: urlString!) else {
            print("invalid url!")
            return cell
        }
        
        cell.tag = indexPath.row
        DispatchQueue.global().async {
                    let data = try? Data(contentsOf: url)
                    if let data = data {
                        let image = UIImage(data: data)!
                        DispatchQueue.main.async {
                            // saving the downloaded image in file manager
                            guard let cacheDirectory  = self.getImagePath(name: "\(String(describing: uuid))") else {
                                return
                            }
                            
                            do {
                                try data.write(to: cacheDirectory)
                            }
                            catch {
                                print("error canot save \(String(describing: uuid))'s profile!")
                                return
                            }
                            
                            if cell.tag == indexPath.row {
                                cell.profileImg.image = image
                            }
                        }
                    }
        }
            
        return cell
    }
    
}

extension ChildViewController : UICollectionViewDelegate {
    // delegate method to handle cell selection
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // updating the selectedChildIndex
        selectedChildIndex = indexPath.row
        performSegue(withIdentifier: "segueIdentifier", sender: nil)
    }
}

extension ChildViewController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.size.width
        return CGSize(width: width , height: 80)
    }
}

extension ChildViewController {
    func getImageFromFileManager(imageName : String) -> UIImage? {
        
        guard let path = getImagePath(name: "\(imageName)")?.path  else {
            print("error getting path!")
            return nil
        }

        guard manager.fileExists(atPath: path) == true else {
           // print("file not exists!")
            return nil
        }
        
        return UIImage(contentsOfFile: path)
    }
    
    
    func getImagePath(name : String) -> URL? {
        guard let path = manager.urls(for: .cachesDirectory, in: .userDomainMask).first?.appendingPathComponent("\(name).jpg") else {
            print("can't get path!")
            return nil
        }
        return path
    }
    
    static func deleteImageFromFileManager(imageName : String) {
        
        guard let cacheDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            print("error : couldn't find directory")
            return
        }
        
        let imgfile = cacheDir.appendingPathComponent("\(imageName).jpg")
        
        if FileManager.default.fileExists(atPath: imgfile.path) {
            do {
                try FileManager.default.removeItem(at: imgfile)
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
    
    static func clearCache() {
        guard let cacheDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            print("error : couldn't find directory")
            return
        }
        
        do {
            // Get the directory contents urls (including subfolders urls)
            let directoryContents = try FileManager.default.contentsOfDirectory( at: cacheDir, includingPropertiesForKeys: nil, options: [])
            for file in directoryContents {
                do {
                    try FileManager.default.removeItem(at: file)
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
