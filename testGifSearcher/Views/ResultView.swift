//
//  ResultView.swift
//  testGifSearcher
//
//  Created by Kazakevich, Vitaly on 10/25/17.
//  Copyright © 2017 Vitalik. All rights reserved.
//

import Foundation
import UIKit

class ResultView: GifView {


    private let searchBarHeightConstant: CGFloat = 60.0
    private let segmentedControlHeightConstatnt: CGFloat = 40.0
    var segmentedControl = UISegmentedControl()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(segmentedControl)
        customizeSegmentedControl()
        createSegmentedControlConstraints()
        insertViewBeforeTableView(view: segmentedControl)
    }

    func setSegmentedControlWith(array: [Any]) {
        for item in array {
            guard let name = item as? String else {
                continue
            }
            segmentedControl.insertSegment(withTitle: name, at: segmentedControl.numberOfSegments, animated: true)
        }
        segmentedControl.selectedSegmentIndex = 0
    }

    private func customizeSegmentedControl() {
        segmentedControl.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        segmentedControl.tintColor = UIColor.white.withAlphaComponent(0.7)
    }

    private func createSegmentedControlConstraints() {
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([segmentedControl.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
                                     segmentedControl.leadingAnchor.constraint(equalTo: leadingAnchor),
                                     segmentedControl.trailingAnchor.constraint(equalTo: trailingAnchor)])
    }
}
