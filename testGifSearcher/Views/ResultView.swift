//
//  ResultView.swift
//  testGifSearcher
//
//  Created by Kazakevich, Vitaly on 10/25/17.
//  Copyright © 2017 Vitalik. All rights reserved.
//

import Foundation
import UIKit

class ResultView: UIView {
    var tableViewDelegate: UITableViewDelegate? {
        didSet {
            tableView.delegate = tableViewDelegate
        }
    }

    var dataSource: UITableViewDataSource? {
        didSet {
            tableView.dataSource = dataSource
        }
    }

    var refreshControl = UIRefreshControl()
    private let searchBarHeightConstant: CGFloat = 60.0
    private let segmentedControlHeightConstatnt: CGFloat = 40.0
    var tableView = UITableView()
    var activityIndicator = UIActivityIndicatorView()
    var segmentedControl = UISegmentedControl()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(tableView)
        addSubview(activityIndicator)
        addSubview(segmentedControl)
        tableView.addSubview(refreshControl)
        let refreshTitle = NSLocalizedString("loading", comment: "")
        refreshControl.attributedTitle = NSAttributedString(string: refreshTitle)

        customizeTableView()
        customizeActivityIndicator()
        customizeSegmentedControl()

        createSegmentedControlConstraints()
        createTableViewConstraints()
        createActivityIndicatorConstraints()

        layoutSubviews()
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

    func customizeSegmentedControl() {
        segmentedControl.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        segmentedControl.tintColor = UIColor.white.withAlphaComponent(0.7)
    }

    func customizeActivityIndicator() {
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.backgroundColor = UIColor.black
        activityIndicator.hidesWhenStopped = true
    }

    func customizeTableView() {
        tableView.backgroundColor = UIColor.darkGray
        tableView.register(GifTableViewCell.self, forCellReuseIdentifier: GifTableViewCell.identifier)
    }

    func reloadData() {
        tableView.reloadData()
    }

    func createTableViewConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }

    func createActivityIndicatorConstraints() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }

    func createSegmentedControlConstraints() {
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor).isActive = true
        segmentedControl.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        segmentedControl.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }

    func showLoadingView (_ isShowing: Bool) {
        activityIndicator.isHidden = !isShowing
        if !isShowing {
            refreshControl.endRefreshing()
        }
    }
}
