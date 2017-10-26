//
//  GifView.swift
//  testGifSearcher
//
//  Created by Kazakevich, Vitaly on 10/26/17.
//  Copyright © 2017 Vitalik. All rights reserved.
//

import Foundation

class GifView: UIView {

    private var isLoadingViewHeightConstant: CGFloat = 30.0
    private var isLoadingViewWidthConstant: CGFloat = 200.0
    private var tableViewTopAnchor: NSLayoutConstraint?
    private var tableView = UITableView()
    private var activityIndicator = UIActivityIndicatorView()
    private var isLoadingLabel = UILabel()
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

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(tableView)
        addSubview(activityIndicator)
        addSubview(isLoadingLabel)
        tableView.addSubview(refreshControl)

        customizeTableView()
        customizeActivityIndicator()
        customizeLabel()

        createTableViewConstraints()
        createActivityIndicatorConstraints()
        createLoadingLabelConstraints()
    }

    private func customizeLabel() {
        isLoadingLabel.text = NSLocalizedString("loading", comment: "")
        isLoadingLabel.font = UIFont(name: isLoadingLabel.font.fontName, size: 30)
    }


    private func customizeActivityIndicator() {
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.color = .black
        activityIndicator.hidesWhenStopped = true
    }

    private func customizeTableView() {
        tableView.backgroundColor = .darkGray
        tableView.register(GifTableViewCell.self, forCellReuseIdentifier: GifTableViewCell.identifier)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 140
    }

    func reloadData() {
        tableView.reloadData()
    }

    func insertViewBeforeTableView(view: UIView) {
        tableViewTopAnchor?.isActive = false
        tableView.topAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }

    private func createTableViewConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableViewTopAnchor = tableView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor)
        tableViewTopAnchor?.isActive = true
        NSLayoutConstraint.activate([tableViewTopAnchor!,
                                     tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
                                     tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
                                     tableView.bottomAnchor.constraint(equalTo: bottomAnchor)])
    }

    private func createActivityIndicatorConstraints() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
                                     activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)])
    }

    private func createLoadingLabelConstraints() {
        isLoadingLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([isLoadingLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
                                     isLoadingLabel.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor),
                                     isLoadingLabel.widthAnchor.constraint(equalToConstant: isLoadingViewWidthConstant),
                                     isLoadingLabel.heightAnchor.constraint(equalToConstant: isLoadingViewHeightConstant)])
    }

    func showLoadingView(_ isShowing: Bool) {
        isLoadingLabel.isHidden = !isShowing
        if isShowing {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
            refreshControl.endRefreshing()
        }
    }
}
