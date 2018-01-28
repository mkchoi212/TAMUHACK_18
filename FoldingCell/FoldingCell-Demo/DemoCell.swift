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
}

class DemoCell: FoldingCell {
    @IBOutlet var closeNumberLabel: UILabel!
    @IBOutlet var openNumberLabel: UILabel!
    @IBOutlet var foodView: UIView!
    @IBOutlet var ticketView: UIView!
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
        UIView.transition(with: containerView, duration: 0.6, options: .transitionFlipFromRight, animations: {
            self.containerView.insertSubview(self.foodView, aboveSubview: self.ticketView)
        }, completion: nil)
    }
    
    @IBAction func completeOrder(_: AnyObject) {
        UIView.transition(with: containerView, duration: 0.6, options: .transitionFlipFromRight, animations: {
            self.containerView.insertSubview(self.ticketView, aboveSubview: self.foodView)
        }, completion: nil)
    }
    
    @IBAction func buttonHandler(_: AnyObject) {
        print("tap!")
        delegate?.moveToNextCell()
    }
    
    @IBAction func rebookFlight(_: AnyObject) {
        delegate?.rebook()
    }
}
