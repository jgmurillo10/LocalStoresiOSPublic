//
//  ListsViewController.swift
//  LocalStoresiOS
//
//  Created by Juan Murillo on 3/10/17.
//  Copyright © 2017 Juan Murillo. All rights reserved.
//

import UIKit
import Firebase

class ListsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    @IBOutlet weak var listsTableView: UITableView!
    var userLists: [DocumentSnapshot] = []
    override func viewWillAppear(_ animated: Bool) {
        
        // bring list from this user
        listsTableView.isHidden = true
        spinner.startAnimating()
        let user = Auth.auth().currentUser
            if let user  = user {
                let uid = user.uid
                print("userid : \(uid)")
                Firestore.firestore().collection("lists").whereField("user", isEqualTo: uid)
                    .getDocuments() { (querySnapshot, err) in
                        if let err = err {
                            print("Error getting lists: \(err)")
                            
                            self.showAlert(title: "Error showing the lists", message: "Hello", closeButtonTitle: "kk")
                        } else {
                            self.userLists = querySnapshot!.documents
                            self.listsTableView.reloadData()
                            for list in self.userLists {
                                //print(list.data())
                            }
                            self.listsTableView.isHidden = false
                            self.spinner.stopAnimating()
                        }
                }
            }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        listsTableView.delegate = self
        listsTableView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userLists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "MyListCell")!
        //let currentname: String = userLists[indexPath.row].data()["name"] as! String
        //print("llamando cellForRowAt " + currentname)
        //cell.textLabel!.text = currentname
        cell.textLabel!.text = userLists[indexPath.row]["name"] as? String
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showList", sender: userLists[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showList" {
            let targetController: ListViewController = segue.destination as! ListViewController
            targetController.selectedList = sender as? DocumentSnapshot
        }
    }
    
    
    @IBAction func createNewList(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "createNewList", sender: self)
    }
    
    
    // function to show alerts in case there is no input in textfields
    func showAlert(title: String, message: String, closeButtonTitle: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: closeButtonTitle, style: .default, handler: {(action: UIAlertAction) in})
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: {})
    }
    

}
