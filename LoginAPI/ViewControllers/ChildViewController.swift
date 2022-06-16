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
            guard let image = UIImage.image(withLabel: name) else {
                return cell
            }
            cell.profileImg.image = image
            return cell
        }
        
        // checking if image is already downloaded in file manager
        if let image = FileSystemManager.shared.getImageFromFileManager(imageName: uuid) {
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
                    guard let cacheDirectory  = FileSystemManager.shared.getImagePath(name: "\(String(describing: uuid))") else {
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
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "dvcIdentifier") as! DetailsViewController
        vc.name = coChildList[selectedChildIndex].name!
        vc.uuid = coChildList[selectedChildIndex].uuid!
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension ChildViewController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.size.width
        return CGSize(width: width , height: 80)
    }
}
