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

    var searchBar = UISearchBar()

    var searchBarDelegate: UISearchBarDelegate? {
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
        customizeSearchBar()
        createSearchBarConstraints()
        insertViewBeforeTableView(view: searchBar)
    }

    private func customizeSearchBar() {
        searchBar.placeholder = NSLocalizedString("Search", comment: "")
    }

    private func createSearchBarConstraints() {
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([searchBar.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
                                     searchBar.leadingAnchor.constraint(equalTo: leadingAnchor),
                                     searchBar.trailingAnchor.constraint(equalTo: trailingAnchor),
                                     searchBar.heightAnchor.constraint(equalToConstant: searchBarHeightConstant)])
    }
}
