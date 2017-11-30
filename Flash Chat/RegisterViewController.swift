//
//  RegisterViewController.swift
//  Flash Chat
//
//  Created by Konstantin Konstantinov on 11/24/17.
//  Copyright © 2017 Konstantin Konstantinov. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class RegisterViewController: UIViewController {

    @IBOutlet var emailTextfield: UITextField!
    @IBOutlet var passwordTextfield: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

  
    @IBAction func registerPressed(_ sender: AnyObject) {
        
        guard let email = emailTextfield.text,
            let password = passwordTextfield.text else { return }
        
        SVProgressHUD.show()
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] (user, error) in
            if error != nil {
                print(error!)
            } else {
                SVProgressHUD.dismiss()
                self?.performSegue(withIdentifier: "goToChat", sender: self)
            }
        }
    } 
    
    
}
