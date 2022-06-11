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
        ChildViewController.clearCache()
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

extension ParentViewController : UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellIdentifier", for: indexPath) as! CustomCollectionViewCell
        
        if coParentList.isEmpty {
            return cell
        }
        
        // fetching name from child list and setting to label
        guard let name = coParentList[indexPath.row].name else {
            print("name may be nil!")
            return cell
        }
        
        cell.childName.text = name
        
        if let image = imageWith(name: name) {
            cell.profileImg.image = image
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
