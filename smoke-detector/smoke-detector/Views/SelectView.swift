//
//  ViewController.swift
//  TableView
//
//  Created by Robert Herley on 3/4/19.
//  Copyright © 2019 Robert Herley. All rights reserved.
//

import UIKit

struct Detector : Decodable {
    let name: String
    let ip : String
}

class SelectController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var table: UITableView!
    private var detectors : [Detector]?
    private var selectedIP : String!
    
    func fetch() {
        let jsonUrlString = "http://localhost:8080/list"
        guard let url = URL(string: jsonUrlString) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            if(err != nil) {
                print("An error occurred while fetching:", err ?? "unknown error")
                return
            }
            
            let status = (response as! HTTPURLResponse).statusCode
            if(!(status >= 200 && status < 300)){
                print("Invalid HTTP Response:", status)
                return
            }
            
            guard let data = data else { return }
            
            do {
                let detectors = try JSONDecoder().decode([Detector].self, from: data)
                self.detectors = detectors;
                DispatchQueue.main.async {
                    self.table.reloadData()
                }
                print(self.detectors!)
            } catch let jsonErr {
                print("An error occurred while parsing the json:", jsonErr)
                return
            }
            }.resume()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        table.dataSource = self
        table.delegate = self
        fetch()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        let graphController = segue.destination as! GraphController
        graphController.ip = selectedIP!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIP = detectors?[indexPath.item].ip
        self.performSegue(withIdentifier: "showGraph", sender: self)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return detectors?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DetectCell") else { return UITableViewCell()}
        
        guard let curr = self.detectors?[indexPath.row] else { return UITableViewCell() }
        
        cell.textLabel?.text = curr.name
        cell.detailTextLabel?.text = curr.ip
        
        return cell
    }
    
}

