//
//  TrendedGifsView.swift
//  testGifSearcher
//
//  Created by Kazakevich, Vitaly on 10/25/17.
//  Copyright © 2017 Vitalik. All rights reserved.

import Foundation
import UIKit

class TrendedGifsView: GifView {

    private var searchBarHeightConstant: CGFloat = 60.0
    private var isLoadingViewHeightConstant: CGFloat = 30.0
    private var isLoadingViewWidthConstant: CGFloat = 200.0

    var searchBar = UISearchBar()
    var isLoadingLabel = UILabel()

    weak var searchBarDelegate: UISearchBarDelegate? {
        didSet {
            searchBar.delegate = searchBarDelegate
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(searchBar)
        addSubview(isLoadingLabel)

        customizeSearchBar()
        customizeLabel()

        createSearchBarConstraints()
        createTableViewConstraints()
        createActivityIndicatorConstraints()
        createLoadingLabelConstraints()
    }

    func customizeLabel() {
        isLoadingLabel.text = NSLocalizedString("loading", comment: "")
        isLoadingLabel.font = UIFont(name: isLoadingLabel.font.fontName, size: 30)
        isLoadingLabel.textAlignment = .center
    }

    func customizeSearchBar() {
        searchBar.placeholder = NSLocalizedString("Search", comment: "")
    }

    func createSearchBarConstraints() {
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor).isActive = true
        searchBar.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        searchBar.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        searchBar.heightAnchor.constraint(equalToConstant: searchBarHeightConstant).isActive = true
    }

    func createTableViewConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }

    func createActivityIndicatorConstraints() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }

    func createLoadingLabelConstraints() {
        isLoadingLabel.translatesAutoresizingMaskIntoConstraints = false
        isLoadingLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        isLoadingLabel.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor).isActive = true
        isLoadingLabel.widthAnchor.constraint(equalToConstant: isLoadingViewWidthConstant).isActive = true
        isLoadingLabel.heightAnchor.constraint(equalToConstant: isLoadingViewHeightConstant).isActive = true
    }

    override func showLoadingView(_ isShowing: Bool) {
        super.showLoadingView(isShowing)
        isLoadingLabel.isHidden = !isShowing
    }
}




