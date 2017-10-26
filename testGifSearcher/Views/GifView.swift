//
//  GifView.swift
//  testGifSearcher
//
//  Created by Kazakevich, Vitaly on 10/26/17.
//  Copyright © 2017 Vitalik. All rights reserved.
//

import Foundation

class GifView: UIView {
    weak var tableViewDelegate: UITableViewDelegate? {
        didSet {
            tableView.delegate = tableViewDelegate
        }
    }

    weak var dataSource: UITableViewDataSource? {
        didSet {
            tableView.dataSource = dataSource
        }
    }

    var refreshControl = UIRefreshControl()
    private let searchBarHeightConstant: CGFloat = 60.0
    var tableView = UITableView()
    var activityIndicator = UIActivityIndicatorView()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(tableView)
        addSubview(activityIndicator)
        
        tableView.addSubview(refreshControl)
        let refreshTitle = NSLocalizedString("loading", comment: "")
        refreshControl.attributedTitle = NSAttributedString(string: refreshTitle)

        customizeTableView()
        customizeActivityIndicator()

        createActivityIndicatorConstraints()
        createTableViewConstraints()
    }

    func customizeActivityIndicator() {
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.backgroundColor = UIColor.black
        activityIndicator.hidesWhenStopped = true
    }

    func customizeTableView() {
        tableView.backgroundColor = UIColor.darkGray
        tableView.register(GifTableViewCell.self, forCellReuseIdentifier: GifTableViewCell.identifier)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 200
    }

    func createTableViewConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }

    func createActivityIndicatorConstraints() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }

    func reloadData() {
        tableView.reloadData()
    }

    func showLoadingView (_ isShowing: Bool) {
        activityIndicator.isHidden = !isShowing
        if !isShowing {
            refreshControl.endRefreshing()
        }
    }
}
