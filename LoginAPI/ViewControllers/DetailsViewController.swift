//
//  DetailsViewController.swift
//  LoginAPI
//
//  Created by Sai Hari on 18/05/22.
//

import UIKit

class DetailsViewController: UIViewController {

    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var birthDateLabel: UILabel!
    @IBOutlet weak var uuidLabel: UILabel!
    @IBOutlet weak var timezoneLabel: UILabel!
    @IBOutlet weak var falconidLabel: UILabel!
    @IBOutlet weak var filterLevelIdLabel: UILabel!
    
    var name = ""
    var uuid = ""
    
    deinit {
       // print("deallocated")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        title = "Details of \(name)"
        setDetails()
    }

    func setDetails() {
        
        guard let childUser = CoreDataManager.shared.fetchCoParentChildDetails(uuid: uuid) else {
            print("details is nil!")
            showAlert(message: "error fetching child data")
            return
        }
        
        
        // setting contents of label 
        ageLabel.text = "Age : \(childUser.age)"
        genderLabel.text = "Gender : \(String(describing: childUser.gender))"
        birthDateLabel.text = "Birth Date : \(childUser.birth_date)"
        // since uuid will be available whatsoever, force unwrapping it
        uuidLabel.text = "uuid : \(String(describing: childUser.uuid!))"
        timezoneLabel.text = "Time Zone : \(String(describing: childUser.timezone))"
        if let falcon_id = childUser.falcon_id {
            falconidLabel.text = "falcon id : \(String(describing: falcon_id))"
        }
        filterLevelIdLabel.text = "filter level id : \(String(childUser.filter_level_id))"
        
    }

    func showAlert(message : String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Error", message: "Message: \(message)", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "Close", style: .cancel) { _ in
                self.navigationController?.popViewController(animated: true)
            }
            
            alert.addAction(alertAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}
