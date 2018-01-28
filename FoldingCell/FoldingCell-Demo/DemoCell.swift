//
//  DemoCell.swift
//  FoldingCell
//
//  Created by Alex K. on 25/12/15.
//  Copyright © 2015 Alex K. All rights reserved.
//

import FoldingCell
import UIKit

protocol FoldingCellDelegate {
    func moveToNextCell()
    func rebook()
    func updateTable()
    func arrived()
}

class DemoCell: FoldingCell {
    @IBOutlet var closeNumberLabel: UILabel!
    @IBOutlet var openNumberLabel: UILabel!
    @IBOutlet var foodView: UIView!
    @IBOutlet var ticketView: UIView!
    @IBOutlet var statusView: UIView!
    
    var delegate: FoldingCellDelegate?

    var number: Int = 0
    
    override func awakeFromNib() {
        foregroundView.layer.cornerRadius = 10
        foregroundView.layer.masksToBounds = true
        super.awakeFromNib()
    }

    override func animationDuration(_ itemIndex: NSInteger, type _: FoldingCell.AnimationType) -> TimeInterval {
        let durations = [0.26, 0.2, 0.2]
        return durations[itemIndex]
    }
}

// MARK: - Actions ⚡️
extension DemoCell {
    @IBAction func orderFood(_: AnyObject) {
        UIView.transition(with: containerView, duration: 0.6, options: UIViewAnimationOptions.transitionFlipFromRight, animations: {
            let ticketView = self.containerView.subviews.filter{ $0.restorationIdentifier == "tickets" }.first!
            self.containerView.sendSubview(toBack: ticketView)
        }, completion: nil)
    }
    
    @IBAction func completeOrder(_: AnyObject) {
        UIView.transition(with: containerView, duration: 0.6, options: UIViewAnimationOptions.transitionFlipFromLeft, animations: {
            let foodView =  self.containerView.subviews.filter{ $0.restorationIdentifier == "food" }.first!
            self.containerView.sendSubview(toBack: foodView)
        }, completion: { _ in
            TemporaryAlert.show(image: .checkmark, title: "Order placed", message: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {
                self.delegate?.moveToNextCell()
            })
        })
    }
    
    @IBAction func finalButton(_: AnyObject) {
        self.delegate?.arrived()
    }
    
    @IBAction func buttonHandler(_: AnyObject) {
        UIView.animate(withDuration: 0.5, animations: {
            self.statusView.backgroundColor = #colorLiteral(red: 0, green: 0.5607843137, blue: 0, alpha: 1)
        }) { (_) in
            self.delegate?.moveToNextCell()
        }
    }
    
    @IBAction func rebookFlight(_: AnyObject) {
        delegate?.rebook()
    }
}
