//
//  ProductsTableViewController.swift
//  LocalStoresiOS
//
//  Created by Juan Murillo on 7/10/17.
//  Copyright © 2017 Juan Murillo. All rights reserved.
//

import UIKit
import Firebase
import Speech
@available(iOS 10.0, *)
class ProductsTableViewController: UITableViewController, UISearchResultsUpdating {
    
    @IBOutlet var productsTableView: UITableView!
    
    var timer: Timer!
    var collectionRef: CollectionReference!
    var db: Firestore!
    
    var searchController: UISearchController!
    var resultsController = UITableViewController()
    var products = [DocumentSnapshot]()
    var filteredProducts = [DocumentSnapshot]()
    var cellIdentifier: String = "ProductCell"
    var alert : UIAlertController?
    @IBOutlet weak var voiceSearchButton: UIBarButtonItem!
    
    
    let audioEngine = AVAudioEngine()
    //    let speechRecognizer : SFSpeechRecognizer? = SFSpeechRecognizer()
    let speechRecognizer : SFSpeechRecognizer? = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))
    var request = SFSpeechAudioBufferRecognitionRequest()
    var recognitionTask : SFSpeechRecognitionTask?
    var inputNode : AVAudioInputNode?
    
    override func viewWillAppear(_ animated: Bool) {
        
        if products.count != 0 {
            return
        }
        db.collection("flat-stores").order(by: "price", descending: false).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                
                for document in querySnapshot!.documents {
                    print("PRODUCT")
                    print("\(document.documentID) => \(document.data())")
                    self.products.append(document)
                }
                self.resultsController.tableView.reloadData()
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        collectionRef = db.collection("flat-stores")
        self.resultsController.tableView.dataSource = self
        self.resultsController.tableView.delegate = self
        // this line deletes the awkward space in the results table view between the search bar and the first element
        self.resultsController.edgesForExtendedLayout = []
        self.resultsController.tableView.rowHeight = 50
        self.tableView.rowHeight = 50
        
        initializeSearchController()
        
        checkUserPermissions()
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.longPress(longPressGestureRecognizer:)))
        longPressRecognizer.minimumPressDuration = 0.5
        longPressRecognizer.delegate = self as? UIGestureRecognizerDelegate
        resultsController.tableView.addGestureRecognizer(longPressRecognizer)
        //self.productsTableView.addGestureRecognizer(longPressRecognizer)
    }
    func checkUserPermissions() -> Int {
        switch AVAudioSession.sharedInstance().recordPermission() {
        case AVAudioSessionRecordPermission.granted:
            print("Permission granted")
            voiceSearchButton.isEnabled = true
            return 1
        case AVAudioSessionRecordPermission.denied:
            print("Pemission denied")
            voiceSearchButton.isEnabled = false
            return -1
        case AVAudioSessionRecordPermission.undetermined:
            print("Request permission here")
            return 0
        default:
            return 0
        }
    }
    func initializeSearchController() {
        self.searchController = UISearchController(searchResultsController: self.resultsController)
        self.tableView.tableHeaderView = self.searchController.searchBar
        self.searchController.searchResultsUpdater = self
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.searchBar.placeholder = "search for a product..."
        
        self.searchController.definesPresentationContext = true
        
        alert = UIAlertController().showAlert(title: "Voice search, looking for:", message: "", acceptButtonTitle: "Accept", closeButtonTitle: "Close", onCancel: {
            self.stopRecognizeSpeech()
            self.searchController.searchBar.text = ""
        }, onAccept: {
            self.stopRecognizeSpeech()
            self.searchController.searchBar.text = self.alert?.message
        })
    }
    func update(query: String)  {
        db.collection("flat-stores").whereField("name", isEqualTo: query).order(by: "price", descending: false)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        print("\(document.documentID) => \(document.data())")
                        
                    }
                }
        }
    }
    func updateSearchResults(for searchController: UISearchController) {
        // filter through the array by product's name
        self.filteredProducts = self.products.filter { ( doc: DocumentSnapshot) -> Bool in
            let strName:String = doc["name"] as! String
            if strName.lowercased().contains(self.searchController.searchBar.text!.lowercased()){
                //print("filter \(self.searchController.searchBar.text!)")
                return true
            }else{
                return false
            }
        }
        self.resultsController.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView {
            return 0
        } else {
            return self.filteredProducts.count
        }
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedProduct = filteredProducts[indexPath.row]
        print(selectedProduct.data()["name"] as! String)
        print("before perform segue")
        self.dismiss(animated: true, completion: {})
        self.performSegue(withIdentifier: "showLocalizationProduct", sender: selectedProduct)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("prepare for segue")
        if segue.identifier == "showLocalizationProduct" {
            let viewController : ResultsViewController = segue.destination as! ResultsViewController
            viewController.selectedProduct = sender as! DocumentSnapshot
            
        }
        else if segue.identifier == "addProductToList" {
            let viewController : AddListViewController = segue.destination as! AddListViewController
            viewController.selectedProduct = sender as! DocumentSnapshot
        }
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell: UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier:  cellIdentifier, for: indexPath)
        let currentProduct: DocumentSnapshot = self.filteredProducts[indexPath.row]
        cell.textLabel?.text = currentProduct["name"] as? String
        let price :String! = String(describing: currentProduct["price"] as! Int)
        cell.detailTextLabel?.text =  "$\(price as! String) COP  \(currentProduct["place"] as! String)"
        return cell
    }
    func stopRecognizeSpeech(){
        self.audioEngine.stop()
        inputNode?.removeTap(onBus: 0)
        self.request.endAudio()
        self.recognitionTask = nil
    }
    func recordAndRecognizeSpeech(){
        inputNode = audioEngine.inputNode
        let recordingFormat = inputNode?.outputFormat(forBus: 0)
        inputNode?.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.request.append(buffer)
        }
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            print("error audio engine start")
            return print(error)
        }
        
        guard let myRecognizer = SFSpeechRecognizer() else {
            print("error creating my recognizer")
            return
        }
        if !myRecognizer.isAvailable {
            print("Error my recognizer is not available")
            return
        }
        
        recognitionTask = speechRecognizer?.recognitionTask(with: request, resultHandler: { result, error in
            if let result = result {
                self.alert?.message = result.bestTranscription.formattedString
            } else if let error = error {
                print("error in result speech recognizer")
                print(error)
            }
        })
    }
    @IBAction func searchVoice(_ sender: Any) {
        let res = checkUserPermissions()
        if currentReachabilityStatus != .notReachable {
            self.alert?.message = ""
            self.present(alert!, animated: true, completion: nil)
            recordAndRecognizeSpeech()
        }
        else if res == -1 {
            let al = UIAlertController().showAlert(title: "Error", message: "You denied the permission to this app to use microphone and speech recognition. You need to accept them in Settings/General/LocalStores", acceptButtonTitle: "Accept", closeButtonTitle: "Close", onCancel: {}, onAccept: {})
            self.present(al, animated: true, completion: {})
        }
        else {
            let al = UIAlertController().showAlert(title: "Error", message: "Your internet connection is unreachable. You need internet connection like mobile network or wifi to use voice search.", acceptButtonTitle: "Accept", closeButtonTitle: "Close", onCancel: {}, onAccept: {})
            self.present(al, animated: true, completion: {})
        }
        
    }
    
    //Called, when long press occurred
    func longPress(longPressGestureRecognizer: UILongPressGestureRecognizer) {
        print("entra detector")
        
        let p = longPressGestureRecognizer.location(in: resultsController.tableView)
        let indexPath = resultsController.tableView.indexPathForRow(at: p)
        if indexPath == nil {
            print("Long press on table view, not row.")
        }
        else if (longPressGestureRecognizer.state == UIGestureRecognizerState.began) {
            print("Long press on row, at \(indexPath!.row)")
            print(filteredProducts[indexPath!.row].data())
            let selectedProduct : DocumentSnapshot = self.filteredProducts[indexPath!.row]
            self.dismiss(animated: true, completion: nil)
            self.performSegue(withIdentifier: "addProductToList", sender: selectedProduct)
        }
    }
    // alert function with two options.
}
extension UIAlertController {
    func showAlert(title: String, message: String,acceptButtonTitle: String, closeButtonTitle: String, onCancel: @escaping () -> (), onAccept: @escaping () -> ()) -> UIAlertController{
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: closeButtonTitle, style: .cancel, handler: {(action: UIAlertAction) in
            onCancel()
            
        })
        let acceptAction = UIAlertAction(title: acceptButtonTitle, style: .default, handler: {(action: UIAlertAction) in
            onAccept()
            
        })
        alertController.addAction(cancelAction)
        alertController.addAction(acceptAction)
        return alertController
    }
}
