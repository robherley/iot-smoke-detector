//
//  ViewController.swift
//  smoke-detector
//
//  Created by Robert Herley on 2/25/19.
//  Copyright © 2019 Robert Herley. All rights reserved.
//

import UIKit
import SocketIO

class ViewController: UIViewController {
    @IBOutlet weak var dataLabel: UILabel!
    let manager = SocketManager(socketURL: URL(string: "http://localhost:8080")!, config: [.log(true), .compress])

    override func viewDidLoad() {
        super.viewDidLoad()
        initHandlers()
        
    }

    func initHandlers() {
        let socket = manager.defaultSocket
        socket.on(clientEvent: .connect) {data, ack in
            print("socket connected")
        }
        socket.on("reading") {data, ack in
            guard let reading = data[0] as? [String:Double] else { return }
            self.dataLabel.text = String(format: "%.2f", reading["data"]!)
        }
        socket.connect()
    }
    
}

