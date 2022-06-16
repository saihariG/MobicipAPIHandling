//
//  ParentViewController.swift
//  LoginAPI
//
//  Created by Sai Hari on 25/05/22.
//

import UIKit

class ParentViewController: UIViewController {


    @IBOutlet weak var collectionView: UICollectionView!
    
    let coredata = CoreDataManager.shared
    let networkContext = NetworkManager.shared
    let manager = FileSystemManager.shared
    
    var coParentList : [User] =  CoreDataManager.shared.fetchCoParentList()
    var selectedParentIdx = -1
    
    deinit {
       // print("deallocated")
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        title = "Co-Parents"
      
        if networkContext.isConnectedToNetwork() {
            
            networkContext.generateCoParentHTTPRequest { [self] result in
                switch result {
                    case .success:
                        coParentList = coredata.fetchCoParentList()
                        if coParentList.isEmpty {
                            DispatchQueue.main.async { [self] in
                                collectionView.isHidden = true
                            }
                            return
                        }
                        DispatchQueue.main.async { [self] in
                            collectionView.reloadData()
                        }
                    case .failure(let code,let message):
                        showAlert(code: code, message: message)
                        
                }
                
            }
            
        }
        else {
            showAlert(code : "400", message: "please check your internet connection!")
        }
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // to hide back button in navigation bar
        navigationItem.setHidesBackButton(true, animated: true)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "power"), style: .plain, target: self, action: #selector(signOut))
    }
    
    @objc func signOut() {
      
        let credentials = KeyChainManager.shared.retreiveCredentials()
        let mailId = credentials["mailId"]
        
        KeyChainManager.shared.deleteData()
        coredata.deleteData(mailId: mailId!)
        manager.clearCache()
        navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "parentSegueIdentifier" {
            let vc = segue.destination as! ChildViewController
            vc.parentEmail = coParentList[selectedParentIdx].email!
            vc.parentName = coParentList[selectedParentIdx].name!
        }
    }

    // shows alert dialog when encountered error
    func showAlert(code : String , message : String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Error", message: "Code: \(code)\n Message: \(message)", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "Close", style: .cancel)
            
            alert.addAction(alertAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}

extension ParentViewController : UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellIdentifier", for: indexPath) as! CustomCollectionViewCell
        
        if coParentList.isEmpty {
            return cell
        }
        
        guard let email = coParentList[indexPath.row].email else {
            print("email is nil")
            return cell
        }
    
        // fetching name from child list and setting to label
        guard let name = coParentList[indexPath.row].name else {
            print("name may be nil!")
            return cell
        }
        cell.childName.text = name
        
        let urlString = coParentList[indexPath.row].thumbnail

        // if urlString is empty or nil, set image based on initials
        if urlString == "" || urlString == nil {
            guard let image = UIImage.image(withLabel: name) else {
                return cell
            }
            cell.profileImg.image = image
            return cell
        }
        
        // checking if image is already downloaded in file manager
        if let image = manager.getImageFromFileManager(imageName: email) {
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
                    guard let cacheDirectory  = self.manager.getImagePath(name: "\(String(describing: email))") else {
                        return
                    }
                            
                    do {
                        try data.write(to: cacheDirectory)
                    }
                    catch {
                        print("error canot save \(String(describing: email))'s profile!")
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return coParentList.count
    }
    
}

extension ParentViewController : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedParentIdx = indexPath.row
        performSegue(withIdentifier: "parentSegueIdentifier", sender: nil)
    }
}

extension ParentViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.size.width
        return CGSize(width: width , height: 80)
    }
}
