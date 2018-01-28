//
//  MainTableViewController.swift
//
// Copyright (c) 21/12/15. Ramotion Inc. (http://ramotion.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import FoldingCell
import UIKit

class MainTableViewController: UITableViewController {
    var currentIndex = 0
    var cellCount = 6
    
    let kCloseCellHeight: CGFloat = 179
    let kOpenCellHeight: CGFloat = 488
    let kRowsCount = 10
    var cellHeights: [CGFloat] = []
    var rebookCellKey = "RouteCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    private func setup() {
      
        tableView.register(UINib(nibName: "UberCell", bundle: nil), forCellReuseIdentifier: "UberCell")
        tableView.register(UINib(nibName: "TerminalCell", bundle: nil), forCellReuseIdentifier: "TerminalCell")
        tableView.register(UINib(nibName: "RouteCell", bundle: nil), forCellReuseIdentifier: "RouteCell")
        tableView.register(UINib(nibName: "RebookCell", bundle: nil), forCellReuseIdentifier: "RebookCell")
        tableView.register(UINib(nibName: "BaggageCell", bundle: nil), forCellReuseIdentifier: "BaggageCell")
        tableView.register(UINib(nibName: "CanceledCell", bundle: nil), forCellReuseIdentifier: "CanceledCell")

        cellHeights = Array(repeating: kCloseCellHeight, count: kRowsCount)
        tableView.estimatedRowHeight = kCloseCellHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "background"))
    }
}

extension MainTableViewController: FoldingCellDelegate {
    func rebook() {
        let indexPath = IndexPath(row: currentIndex, section: 0)
        self.cellCount -= 1
        self.tableView.deleteRows(at: [indexPath], with: .right)
        self.cellCount += 1
        self.rebookCellKey = "RebookCell"
        self.tableView.insertRows(at: [indexPath], with: .left)
    }
    
    func moveToNextCell() {
        let indexPath = IndexPath(row: currentIndex, section: 0)
        let nextPath = IndexPath(row: currentIndex + 1, section: 0)
        let curCell = tableView.cellForRow(at: indexPath) as! FoldingCell
        let nxtCell = tableView.cellForRow(at: nextPath) as! FoldingCell
        cellHeights[indexPath.row] = kCloseCellHeight
        cellHeights[indexPath.row + 1] = kOpenCellHeight
        
        let container = curCell.foregroundView!
        let overlay = UIView(frame: container.frame)
        overlay.clipsToBounds = true
        overlay.layer.cornerRadius = 10.0
        overlay.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.4911708048)
        overlay.alpha = 0.0
        curCell.addSubview(overlay)
        
        curCell.unfold(false, animated: true) {
            UIView.animate(withDuration: 0.5, animations: {
            }) { (_) in
                UIView.animate(withDuration: 1.0, animations: {
                    overlay.alpha = 1.0
                    self.tableView.beginUpdates()
                    self.tableView.endUpdates()
                }, completion: { (_) in
                    self.currentIndex += 1
                    let indexPath = IndexPath(row: self.currentIndex, section: 0)
                    self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                    nxtCell.unfold(true, animated: true) {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: {
                            if self.currentIndex == 2 {
                                self.cellCount -= 1
                                self.tableView.deleteRows(at: [nextPath], with: .right)
                                self.cellCount += 1
                                self.rebookCellKey = "CanceledCell"
                                self.tableView.insertRows(at: [nextPath], with: .left)
                            }
                        })
                    }
                })
            }
        }
    }
}

// MARK: - TableView
extension MainTableViewController {
    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return cellCount
    }

    override func tableView(_: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard case let cell as DemoCell = cell else {
            return
        }

        cell.backgroundColor = .clear

        if cellHeights[indexPath.row] == kCloseCellHeight {
            cell.unfold(false, animated: false, completion: nil)
        } else {
            cell.unfold(true, animated: false, completion: nil)
        }
        cell.delegate = self
        cell.number = indexPath.row
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = FoldingCell()
        
        if indexPath.row == 1 {
           cell = tableView.dequeueReusableCell(withIdentifier: "TerminalCell", for: indexPath) as! FoldingCell
        } else if indexPath.row == 2 {
            cell = tableView.dequeueReusableCell(withIdentifier: rebookCellKey, for: indexPath) as! FoldingCell
        } else if indexPath.row == 3 {
            cell = tableView.dequeueReusableCell(withIdentifier: "BaggageCell", for: indexPath) as! FoldingCell
        } else {
           cell = tableView.dequeueReusableCell(withIdentifier: "UberCell", for: indexPath) as! FoldingCell
        }

        let durations: [TimeInterval] = [0.26, 0.2, 0.2]
        cell.durationsForExpandedState = durations
        cell.durationsForCollapsedState = durations
        return cell
    }

    override func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeights[indexPath.row]
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let cell = tableView.cellForRow(at: indexPath) as! FoldingCell

        if cell.isAnimating() {
            return
        }

        var duration = 0.0
        let cellIsCollapsed = cellHeights[indexPath.row] == kCloseCellHeight
        if cellIsCollapsed {
            cellHeights[indexPath.row] = kOpenCellHeight
            cell.unfold(true, animated: true, completion: nil)
            duration = 0.5
        } else {
            cellHeights[indexPath.row] = kCloseCellHeight
            cell.unfold(false, animated: true, completion: nil)
            duration = 0.8
        }

        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: { () -> Void in
            tableView.beginUpdates()
            tableView.endUpdates()
        }, completion: nil)
    }
}
