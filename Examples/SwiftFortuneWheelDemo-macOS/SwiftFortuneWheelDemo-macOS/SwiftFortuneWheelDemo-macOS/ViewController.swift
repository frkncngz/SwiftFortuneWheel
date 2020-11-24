//
//  ViewController.swift
//  SwiftFortuneWheelDemo-macOS
//
//  Created by Sherzod Khashimov on 7/13/20.
//  Copyright © 2020 Sherzod Khashimov. All rights reserved.
//

import Cocoa
import SwiftFortuneWheel

class ViewController: NSViewController {

    @IBOutlet weak var wrapperView: NoClippingView!
    @IBOutlet weak var drawCurvedLineSwitch: NSSwitch!
    @IBOutlet weak var colorsTypeSegment: NSSegmentedControl!
    
    lazy var wheelControl: SwiftFortuneWheel = {
        let frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        let wheelControl = SwiftFortuneWheel(frame: frame, slices: [], configuration: .blackCyanColorsConfiguration)
        wheelControl.onSpinButtonTap = { [weak self] in
            self?.startAnimating()
        }
        wheelControl.pinImage = "long-arrow-up"
        wheelControl.spinTitle = "SPIN"
        wheelControl.isSpinEnabled = true
        
        wheelControl.onEdgeCollision = { progress in
            print("edge collision progress: \(String(describing: progress))")
        }
        
        wheelControl.edgeCollisionSound = AudioFile(filename: "Click", extensionName: "mp3")
        
        wheelControl.edgeCollisionDetectionOn = true
        
        return wheelControl
    }()

    var prizes: [Prize] = []

    var drawCurvedLine: Bool = false {
        didSet {
            updateSlices()
        }
    }

    var minimumPrize: Int {
        return 4
    }

    var maximumPrize: Int {
        return 12
    }

    var finishIndex: Int {
        return Int.random(in: 0..<wheelControl.slices.count)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        drawCurvedLine = drawCurvedLineSwitch.state == .on
        
        wrapperView.addSubview(wheelControl)
        layoutWheel()
        
        prizes.append(Prize(amount: 100, description: "Prize".uppercased(), priceType: .money))
        prizes.append(Prize(amount: 200, description: "Prize".uppercased(), priceType: .money))
        prizes.append(Prize(amount: 300, description: "Prize".uppercased(), priceType: .money))
        prizes.append(Prize(amount: 400, description: "Prize".uppercased(), priceType: .money))
        
        updateSlices()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    func layoutWheel() {
        guard let superview = wheelControl.superview else { return }
        wheelControl.translatesAutoresizingMaskIntoConstraints = false
        wheelControl.topAnchor.constraint(equalTo: superview.topAnchor, constant: 25).isActive = true
        wheelControl.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: 25).isActive = true
        wheelControl.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -25).isActive = true
        wheelControl.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -25).isActive = true
    }

    @IBAction func colorsTypeValueChanged(_ sender: Any) {
        switch colorsTypeSegment.selectedSegment {
        case 1:
            wheelControl.configuration = .rainbowColorsConfiguration
            wheelControl.pinImage = "long-arrow-up-black"
        default:
            wheelControl.configuration = .blackCyanColorsConfiguration
            wheelControl.pinImage = "long-arrow-up"
        }
        updateSlices()
    }

    @IBAction func addPrizeAction(_ sender: Any) {
        guard prizes.count < maximumPrize - 1 else { return }
        let price = Prize(amount: (prizes.count + 1) * 100, description: "Prize".uppercased(), priceType: .money)
        prizes.append(price)

        updateSlices()
    }

    @IBAction func removePrizeAction(_ sender: Any) {
        guard prizes.count > minimumPrize else { return }
        _ = prizes.popLast()

        updateSlices()
    }

    @IBAction func drawCurverLineSwitchChanged(_ sender: NSSwitch) {
        drawCurvedLine = sender.state == .on
    }


    func updateSlices() {
        let slices: [Slice] = prizes.map({ Slice(contents: $0.sliceContentTypes(isMonotone: colorsTypeSegment.selectedSegment == 1, withLine: drawCurvedLine)) })

        wheelControl.slices = slices

        if prizes.count == maximumPrize - 1 {
            let imagePreferences = ImagePreferences(preferredSize: CGSize(width: 40, height: 40), verticalOffset: 40)
            let imageSliceContent = Slice.ContentType.assetImage(name: "crown", preferences: imagePreferences)
            var slice = Slice(contents: [imageSliceContent])
            if drawCurvedLine {
                let linePreferences = LinePreferences(colorType: .customPatternColors(colors: nil, defaultColor: .black), height: 2, verticalOffset: 35)
                let line = Slice.ContentType.line(preferences: linePreferences)
                slice.contents.append(line)
            }
            wheelControl.slices.append(slice)
        }
    }

    func startAnimating() {
        wheelControl.startRotationAnimation(finishIndex: finishIndex, continuousRotationTime: 1) { (finished) in
            print(finished)
        }
    }


}

