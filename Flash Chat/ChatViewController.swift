//
//  ViewController.swift
//  Flash Chat
//
//  Created by Konstantin Konstantinov on 11/24/17.
//  Copyright © 2017 Konstantin Konstantinov. All rights reserved.
//

import UIKit
import Firebase
import ChameleonFramework
import SVProgressHUD

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    var messageArray = [Message]()
    
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var messageTextfield: UITextField!
    @IBOutlet var messageTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set delegates and dataSource
        messageTableView.delegate = self
        messageTableView.dataSource = self
        messageTextfield.delegate = self
        
        // Add tap gesture recognizer to TableView
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        messageTableView.addGestureRecognizer(tapGesture)
        
        // Register xib
        messageTableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "customMessageCell")
        
        configureTableView()
        retreiveMessages()
        
        messageTableView.separatorStyle = .none
    }
    
    //MARK: - TableView DataSource Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell
        
        cell.messageBody.text = messageArray[indexPath.row].messageBody
        cell.senderUsername.text = messageArray[indexPath.row].sender
        cell.avatarImageView.image = UIImage(named: "egg")
        
        if let currentUserEmail = Auth.auth().currentUser?.email {
            if messageArray[indexPath.row].sender == currentUserEmail {
                cell.messageBackground.backgroundColor = UIColor.flatSkyBlue()
                cell.avatarImageView.backgroundColor = UIColor.flatMint()
                cell.senderUsername.textColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.65)
                cell.messageBody.textColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            } else {
                cell.messageBackground.backgroundColor = UIColor(red: 0.90, green: 0.90, blue: 0.92, alpha: 1.0)
                cell.avatarImageView.backgroundColor = UIColor.flatWatermelon()
                cell.senderUsername.textColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.65)
                cell.messageBody.textColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.75)
            }
        }
        
        return cell
    }
    
    @objc func tableViewTapped() {
        messageTextfield.endEditing(true)
    }
    
    /// Adjusts TableView row height
    func configureTableView() {
        messageTableView.rowHeight = UITableViewAutomaticDimension
        messageTableView.estimatedRowHeight = 120
    }
    
    //MARK:- TextField Delegate Methods
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.heightConstraint.constant = 308
            self?.view.layoutIfNeeded()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.heightConstraint.constant = 50
            self?.view.layoutIfNeeded()
        }
    }
    
    //MARK: - Send & Recieve from Firebase
    
    @IBAction func sendPressed(_ sender: AnyObject) {
        sendButton.isEnabled = false
        messageTextfield.isEnabled = false
        
        guard let sender = Auth.auth().currentUser?.email,
            let messageBody = messageTextfield.text else { return }
        
        let messagesDB = Database.database().reference().child("Message")
        let messageDictionary = ["Sender": sender, "MessageBody": messageBody]
        
        messagesDB.childByAutoId().setValue(messageDictionary) { [weak self] (error, reference) in
            if error != nil {
                print("Error: \(error!)")
            } else {
                print("Message sent successfully!")
                
                self?.sendButton.isEnabled = true
                self?.messageTextfield.isEnabled = true
                self?.messageTextfield.text = ""
            }
        }
    }
    
    /// Fetches messages from Firebase database
    func retreiveMessages() {
        let messagesDB = Database.database().reference().child("Message")
        
        messagesDB.observe(.childAdded) { (snapshot) in
            
            guard let snapshotValue = snapshot.value as? Dictionary<String, String>,
                let text = snapshotValue["MessageBody"],
                let sender = snapshotValue["Sender"] else { return }
            
            self.messageArray.append(Message(sender: sender, messageBody: text))
            
            self.messageTableView.reloadData()
        }
    }
    
    @IBAction func logOutPressed(_ sender: AnyObject) {
        do {
            try Auth.auth().signOut()
            
            navigationController?.popToRootViewController(animated: true)
        } catch {
            print("Error: \(error)")
        }
    }

}
