//
//  TrendedGifsView.swift
//  testGifSearcher
//
//  Created by Kazakevich, Vitaly on 10/25/17.
//  Copyright © 2017 Vitalik. All rights reserved.

import Foundation
import UIKit

class TrendedGifsView: UIView {

    private var searchBarHeightConstant: CGFloat = 60.0
    private var isLoadingViewHeightConstant: CGFloat = 30.0
    private var isLoadingViewWidthConstant: CGFloat = 200.0

    var tableView = UITableView()
    var searchBar = UISearchBar()
    var activityIndicator = UIActivityIndicatorView()
    var isLoadingLabel = UILabel()
    var refreshControl = UIRefreshControl()

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

    var searchBarDelegate: UISearchBarDelegate? {
        didSet {
            searchBar.delegate = searchBarDelegate
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(tableView)
        addSubview(searchBar)
        addSubview(activityIndicator)
        addSubview(isLoadingLabel)
        tableView.addSubview(refreshControl)

        customizeSearchBar()
        customizeTableView()
        customizeActivityIndicator()
        customizeLabel()

        layoutSubviews()
    }

    func customizeLabel() {
        isLoadingLabel.text = NSLocalizedString("loading", comment: "")
        isLoadingLabel.font = UIFont(name: isLoadingLabel.font.fontName, size: 30)
    }

    func customizeSearchBar() {
        searchBar.placeholder = NSLocalizedString("Search", comment: "")
    }

    func customizeActivityIndicator() {
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.color = UIColor.black
        activityIndicator.hidesWhenStopped = true
    }

    func customizeTableView() {
        tableView.backgroundColor = UIColor.darkGray
        tableView.register(GifTableViewCell.self, forCellReuseIdentifier: GifTableViewCell.identifier)
        tableView.rowHeight = UIScreen.main.bounds.width * 0.7
        tableView.estimatedRowHeight = 0

    }

    func reloadData() {
        tableView.reloadData()
    }

    override func layoutSubviews() {
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor).isActive = true
        searchBar.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        searchBar.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        searchBar.heightAnchor.constraint(equalToConstant: searchBarHeightConstant).isActive = true

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true

        isLoadingLabel.translatesAutoresizingMaskIntoConstraints = false
        isLoadingLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        isLoadingLabel.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor).isActive = true
        isLoadingLabel.widthAnchor.constraint(equalToConstant: isLoadingViewWidthConstant).isActive = true
        isLoadingLabel.heightAnchor.constraint(equalToConstant: isLoadingViewHeightConstant).isActive = true
    }

    func showLoadingView() {
        activityIndicator.startAnimating()
        isLoadingLabel.isHidden = false
    }

    func hideLoadingView() {
        activityIndicator.stopAnimating()
        isLoadingLabel.isHidden = true
        refreshControl.endRefreshing()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}




