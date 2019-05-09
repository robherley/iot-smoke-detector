//
//  GraphController.swift
//  smoke-detector
//
//  Created by Robert Herley on 2/25/19.
//  Copyright © 2019 Robert Herley. All rights reserved.
//

import UIKit
import SocketIO
import ScrollableGraphView

class GraphController: UIViewController, ScrollableGraphViewDataSource {
    
    @IBOutlet var graphView: ScrollableGraphView!
    @IBOutlet weak var dataLabel: UILabel!
    
    var ip = ""
    var userLimit = 1600.0
    
    private let itemsDisplayed = 50
    private let maxGraphValue = 3000.0
    private let manager = SocketManager(socketURL: URL(string: "http://localhost:8080")!, config: [.log(false), .compress])
    
    private var shapeLayer : CAShapeLayer?
    private var textLayer : CATextLayer?
    private var currentIndex = 0
    private lazy var smokeData = [Double](repeating: 0.0, count: itemsDisplayed)
    
    @IBAction func alertButton(_ sender: Any) {
        let alert = UIAlertController(title: "New Alert Value", message: "Type a New PPM Value to Recieve Notifications For", preferredStyle: UIAlertController.Style.alert)
        alert.addTextField { textField in
            textField.placeholder = String(format: "%d", self.userLimit)
            textField.keyboardType = .numberPad
        }
        alert.addAction(UIAlertAction(title: "Update", style: UIAlertAction.Style.default){ [weak alert] _ in
            guard let alert = alert, let textField = alert.textFields?.first else { return }
            guard let text = textField.text, text.count > 0, let newAlert = Double(text) else { return }
            self.userLimit = newAlert
            self.shapeLayer?.removeFromSuperlayer()
            self.textLayer?.removeFromSuperlayer()
            self.shapeLayer = nil
            self.textLayer = nil
            self.drawLimit(on: self.graphView.frame)
        })
        
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        graphView.dataSource = self
        setupGraph(graphView: graphView)
        initSocketHandlers()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if shapeLayer == nil && textLayer == nil {
            drawLimit(on: graphView.frame)
        }
    }
    
    func value(forPlot plot: Plot, atIndex pointIndex: Int) -> Double {
        switch(plot.identifier) {
        case "data", "dots":
            return smokeData[pointIndex]
        default:
            return 0
        }
    }
    
    func label(atIndex pointIndex: Int) -> String {
        return "-\(Double(itemsDisplayed - pointIndex) / 2)s"
    }
    
    func numberOfPoints() -> Int {
        return itemsDisplayed
    }
    
    func setupGraph(graphView: ScrollableGraphView) {
        let dataLinePlot = LinePlot(identifier: "data")
        dataLinePlot.lineWidth = 3
        dataLinePlot.lineColor = UIColor(rgb: 0x16aafc)
        dataLinePlot.lineStyle = ScrollableGraphViewLineStyle.smooth
        dataLinePlot.fillType = ScrollableGraphViewFillType.gradient
        dataLinePlot.adaptAnimationType = ScrollableGraphViewAnimationType.elastic
        
        let dotPlot = DotPlot(identifier: "dots")
        dotPlot.adaptAnimationType = ScrollableGraphViewAnimationType.elastic
        dotPlot.dataPointType = ScrollableGraphViewDataPointType.circle
        dotPlot.dataPointSize = 5
        dotPlot.dataPointFillColor = UIColor(rgb: 0x16aafc)
        
        let referenceLines = ReferenceLines()
        referenceLines.referenceLineLabelFont = UIFont.boldSystemFont(ofSize: 8)
        referenceLines.referenceLineColor = UIColor.white.withAlphaComponent(0.2)
        referenceLines.referenceLineLabelColor = UIColor.white
        referenceLines.dataPointLabelColor = UIColor.white.withAlphaComponent(1)
        referenceLines.relativePositions = [0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1]
        
        graphView.rangeMin = 0
        graphView.rangeMax = maxGraphValue
        graphView.direction = ScrollableGraphViewDirection.rightToLeft
        graphView.addReferenceLines(referenceLines: referenceLines)
        //        graphView.rightmostPointPadding = (graphView.bounds.width / 2)
        graphView.addPlot(plot: dataLinePlot)
        graphView.addPlot(plot: dotPlot)
    }
    
    func addReading(data reading: Int){
        self.dataLabel.text = String(format: "%d", reading)
        if(currentIndex == itemsDisplayed){
            currentIndex = 0
        }
        
        if Double(reading) >= userLimit {
            dataLabel.textColor = UIColor(rgb: 0xBF616A)
            // THIS IS WHERE I WOULD PUT DANGER NOTIFICATIONS
        } else if (userLimit - Double(reading)) <= 150 {
            dataLabel.textColor = UIColor(rgb: 0xEBCB8B)
            // THIS IS WHERE I WOULD PUT WARNING NOTIFICATIONS
        } else {
            dataLabel.textColor = UIColor(rgb: 0xFFFFFF)
        }
        smokeData[0] = Double(reading)
        smokeData = smokeData.rotate(shift: 1)
        graphView.reload()
        currentIndex += 1
    }
    
    func drawLimit(on frame : CGRect) {
        let path = UIBezierPath()
        let yCoord = CGFloat(Double(frame.minY) + Double(frame.height - 30) * (1 - (userLimit / maxGraphValue)))
        path.move(to: CGPoint(x: frame.minX, y: yCoord))
        path.addLine(to: CGPoint(x: frame.maxX, y: yCoord))
        
        shapeLayer = CAShapeLayer()
        shapeLayer?.path = path.cgPath
        shapeLayer?.strokeColor = UIColor(rgb: 0xBF616A).cgColor
        shapeLayer?.fillColor = UIColor.clear.cgColor
        shapeLayer?.lineWidth = 3
        
        textLayer = CATextLayer()
        textLayer?.string = "ALERT"
        textLayer?.alignmentMode = CATextLayerAlignmentMode.right
        textLayer?.contentsScale = UIScreen.main.scale
        textLayer?.font = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.semibold)
        textLayer?.fontSize = 11
        textLayer?.foregroundColor = UIColor(rgb: 0xBF616A).cgColor
        let rect = CGRect(x: frame.minX, y: yCoord + 10, width: frame.width, height: CGFloat(20))
        textLayer?.frame = rect
        
        view.layer.addSublayer(shapeLayer!)
        view.layer.addSublayer(textLayer!)
    }
    
    func initSocketHandlers() {
        let socket = manager.defaultSocket
        socket.on(clientEvent: .connect) {data, ack in
            print("socket connected")
        }
        socket.on("reading") {data, ack in
            guard let reading = data[0] as? [String:Any] else { return }
            guard let value = reading["data"] as? Int else { return }
            guard let srcIP = reading["ip"] as? String else { return }
            if srcIP != self.ip { return }
            self.addReading(data: value)
            print("Reading from \(srcIP): \(value)ppm")
        }
        socket.connect()
    }
}

