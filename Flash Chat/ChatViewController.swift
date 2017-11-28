//
//  ViewController.swift
//  Flash Chat
//
//  Created by Angela Yu on 29/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import Firebase

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
    }

    ///////////////////////////////////////////
    
    //MARK: - TableView DataSource Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell
        
        cell.messageBody.text = messageArray[indexPath.row].messageBody
        cell.senderUsername.text = messageArray[indexPath.row].sender
        cell.avatarImageView.image = UIImage(named: "egg")
        
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
    
    ///////////////////////////////////////////
    
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
    
    ///////////////////////////////////////////
    
    
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
            
            self.configureTableView()
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
