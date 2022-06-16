//
//  ViewController.swift
//  LoginAPI
//
//  Created by Sai Hari on 17/05/22.
//

import UIKit
import CryptoKit
import func CommonCrypto.CC_MD5
import var CommonCrypto.CC_MD5_DIGEST_LENGTH
import typealias CommonCrypto.CC_LONG


class ViewController: UIViewController {

    // outlet connections for ui elements
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passField: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var rememberBtn: UIButton! {
        didSet {
            rememberBtn.setImage(UIImage(systemName: "square"), for: .normal)
            rememberBtn.setImage(UIImage(systemName: "checkmark.square.fill"), for: .selected)
        }
    }
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    let defaults = UserDefaults.standard
    // shared context for CoreDataManager class
    let coreDataContext = CoreDataManager.shared
    // shared context for NetworkManager class
    let networkContext = NetworkManager.shared
    
    var shouldRemember : Bool = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        emailField.text = ""
        passField.text = ""
        
        let remembered = UserDefaults.standard.bool(forKey: "RememberMe")
        
        let credentials = KeyChainManager.shared.retreiveCredentials()
       
        guard let maild = credentials["mailId"] , let password = credentials["password"] else {
            spinner.stopAnimating()
            spinner.isHidden = true
            loginBtn.isEnabled = true
            shouldRemember = false
            return
        }
        
        
        if remembered {
          
            spinner.isHidden = false
            spinner.startAnimating()
            loginBtn.isEnabled = false
            
            if networkContext.isConnectedToNetwork() {
                networkContext.generateHTTPRequest(mailId: maild, password: password) { [self] result in
                    switch result {
                    case .success:
                        DispatchQueue.main.async { [self] in
                            spinner.stopAnimating()
                            spinner.isHidden = true
                            loginBtn.isEnabled = true
                            emailField.text = ""
                            passField.text = ""
                            shouldRemember = false
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let vc = storyboard.instantiateViewController(identifier: "parentVC")
                            navigationController?.pushViewController(vc, animated: true)
                        }
                      
                    case .failure(let code, let message):
                        DispatchQueue.main.async { [self] in
                            view.isUserInteractionEnabled = true
                            spinner.stopAnimating()
                            spinner.isHidden = true
                            loginBtn.isEnabled = true
                            showAlert(code: code, message: message)
                        }
                        
                    }
                }
            }
            else {
                print("not remembered")
                showAlert(code: "400", message: "please check your internet connection!")
            }
            
        }
        else {
            spinner.stopAnimating()
            spinner.isHidden = true
            loginBtn.isEnabled = true
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        // Do any additional setup after loading the view
        self.emailField.delegate = self
        self.passField.delegate = self
        
        self.emailField.returnKeyType = .next
        self.passField.returnKeyType = .done
        
        spinner.isHidden = true
        self.title = "Log In"
        // coreDataContext.noOfSavedUsers()
    }
    
    @IBAction func rememberTap(_ sender: Any) {
        rememberBtn.isSelected = !rememberBtn.isSelected
        shouldRemember = rememberBtn.isSelected
    }
    
    @IBAction func loginTap(_ sender: Any) {
        spinner.isHidden = false
        spinner.startAnimating()
        spinner.color = .systemBlue
        loginBtn.isEnabled = false
        
        let mail = emailField.text?.trimmingCharacters(in: .whitespaces)
        let pass = passField.text?.trimmingCharacters(in: .whitespaces)
        
        // input error handling
        if(mail == "" && pass == "" || mail != "" && pass == "" || mail == "" && pass != "") {
            showAlert(code: "", message: "Empty Field!")
            return
        }
      
        // checking if entered mail is valid
        if(!isValidEmailAddress(emailAddressString: mail!) && mail != "" ) {
            showAlert(code: "", message: "invalid mail format")
            return
        }
        
        makeNetworkCalls()
    }
    
    func makeNetworkCalls()  {
     
        let email = emailField.text!
        let pass = passField.text!
        
        if networkContext.isConnectedToNetwork() {
            networkContext.generateHTTPRequest(mailId: emailField.text!, password: passField.text!) { [self] result in
            
            switch result {
                case .success:
                
                   if shouldRemember {
                       UserDefaults.standard.set(true, forKey: "RememberMe")
                   }
                   else {
                       UserDefaults.standard.set(false, forKey: "RememberMe")
                   }
                
                   do {
                      try KeyChainManager.shared.storeCredentials(server: "https://webd.prgr.in/api/v2/login", email: email, password: pass)
                    
                   }
                   catch {
                      print("error storing credentials!")
                  }
                
                   DispatchQueue.main.async { [self] in
                         
                            spinner.stopAnimating()
                            spinner.isHidden = true
                            loginBtn.isEnabled = true
                            emailField.text = ""
                            passField.text = ""
                            shouldRemember = false
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let vc = storyboard.instantiateViewController(identifier: "parentVC")
                            navigationController?.pushViewController(vc, animated: true)
                        
                    }
                
                case .failure(let code,let message):
                
                    DispatchQueue.main.async { [self] in
                        spinner.stopAnimating()
                        spinner.isHidden = true
                        loginBtn.isEnabled = true
                        showAlert(code: code, message: message)
                    }
                   
                }
            }
            
        }
        else {
            showAlert(code: "400", message: "please check your internet connection!")
        }
    
    }
    
    // returns true if the entered mail is valid
    func isValidEmailAddress(emailAddressString: String) -> Bool {
          
          var returnValue = true
          let emailRegEx = "[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}"
          
          do {
              let regex = try NSRegularExpression(pattern: emailRegEx)
              let nsString = emailAddressString as NSString
              let results = regex.matches(in: emailAddressString, range: NSRange(location: 0, length: nsString.length))
              
              if results.count == 0
              {
                  returnValue = false
              }
              
          } catch let error as NSError {
              print("invalid regex: \(error.localizedDescription)")
              returnValue = false
          }
          
          return returnValue
    }

    
    // shows alert dialog when encountered error
    func showAlert(code : String , message : String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Error", message: "Code: \(code)\n Message: \(message)", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "Close", style: .cancel)
            
            alert.addAction(alertAction)
            self.present(alert, animated: true, completion: nil)
            
            self.loginBtn.isEnabled = true
            self.spinner.isHidden = true
        }
    }
    
}

// keyboard handling
extension ViewController : UITextFieldDelegate {
      // To hide keyboard on touch
       override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
           self.view.endEditing(true)
       }
     
       func textFieldShouldReturn(_ textField: UITextField) -> Bool {
           self.switchBasedNextTextField(textField)
           return true
       }
       
       private func switchBasedNextTextField(_ textField: UITextField) {
           switch textField {
            case self.emailField:
               self.passField.becomeFirstResponder()
            case self.passField:
               self.passField.resignFirstResponder()
            default:
               self.emailField.becomeFirstResponder()
           }
       }
}

// MARK: Crypto
extension ViewController {
    
    static func generateProfileHash() -> Data {
        
        let uuidString = UUID().uuidString
    
        return uuidString.lowercased().data(using: .utf8)!
    }
    
    static func MD5(string : String) -> String {
        
        let length = Int(CC_MD5_DIGEST_LENGTH)
        let messageData = string.data(using:.utf8)!
        var digestData = Data(count: length)

        _ = digestData.withUnsafeMutableBytes { digestBytes -> UInt8 in
            messageData.withUnsafeBytes { messageBytes -> UInt8 in
                if let messageBytesBaseAddress = messageBytes.baseAddress, let digestBytesBlindMemory = digestBytes.bindMemory(to: UInt8.self).baseAddress {
                            let messageLength = CC_LONG(messageData.count)
                            CC_MD5(messageBytesBaseAddress, messageLength, digestBytesBlindMemory)
                        }
                        return 0
                }
        }
        return digestData.map { String(format: "%02hhx", $0) }.joined()
    }
    
    static func hmac(message : Data ,token : String) -> String {
        let clientKey = "eQmqIhqfIeNs0OX6avY5YpauB"
      
        var tokenString = token
        tokenString.append(contentsOf: String(data: message, encoding: .utf8)!)
        tokenString.append(clientKey)
        
        //print("token string is : ",tokenString)
        
        let key = SymmetricKey(data: Data(token.utf8))

        let signature = HMAC<SHA256>.authenticationCode(for: Data(tokenString.utf8), using: key)
        let signatureString = Data(signature).map { String(format: "%02hhx", $0) }.joined()
        //print("signature is : ",signatureString)
        
        return signatureString
    }
    
}

