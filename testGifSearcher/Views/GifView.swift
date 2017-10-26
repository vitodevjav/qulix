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

    func showLoadingView (_ isShowing: Bool) {
        activityIndicator.isHidden = !isShowing
        if !isShowing {
            refreshControl.endRefreshing()
        }
    }
}
