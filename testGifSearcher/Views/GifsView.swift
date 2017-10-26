//
//  GifView.swift
//  testGifSearcher
//
//  Created by Kazakevich, Vitaly on 10/26/17.
//  Copyright © 2017 Vitalik. All rights reserved.
//

import Foundation

class GifsView: UIView {

    private var searchBarHeightConstant: CGFloat = 60.0
    private var isLoadingViewHeightConstant: CGFloat = 30.0
    private var isLoadingViewWidthConstant: CGFloat = 200.0

    private var switcherTitleLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("resetFilter", comment: "")
        label.font = UIFont(name: label.font.fontName, size: 15)
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()

    private var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .darkGray
        tableView.register(GifTableViewCell.self, forCellReuseIdentifier: GifTableViewCell.identifier)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 0
        return tableView
    }()

    private var segmentedControlActivitySwitcher: UISwitch = {
        let switcher = UISwitch()
        switcher.onTintColor = UIColor.white.withAlphaComponent(0.9)
        switcher.addTarget(self, action: #selector(resetFilter), for: .valueChanged)
        return switcher
    }()

    private var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.color = .black
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
    }()

    private var isLoadingLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("loading", comment: "")
        label.font = UIFont(name: label.font.fontName, size: 30)
        label.textAlignment = .center
        return label
    }()
    private var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = NSLocalizedString("Search", comment: "")
        return searchBar
    }()

    private var segmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl()
        segmentedControl.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        segmentedControl.tintColor = UIColor.white.withAlphaComponent(0.7)
        segmentedControl.addTarget(self, action: #selector(filterTableViewData), for: .valueChanged)
        return segmentedControl
    }()

    var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        let refreshTitle = NSLocalizedString("loading", comment: "")
        refreshControl.attributedTitle = NSAttributedString(string: refreshTitle)
        refreshControl.addTarget(self, action: #selector(refreshTableViewItems), for: .valueChanged)
        return refreshControl
    }()

    private var refresh: (() -> Void)?
    private var filter: ((_: Int) -> Void)?
    private var reset: ((_: Bool) -> Void)?

    var searchBarDelegate: UISearchBarDelegate? {
        didSet {
            searchBar.delegate = searchBarDelegate
        }
    }

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

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(tableView)
        addSubview(activityIndicator)
        addSubview(isLoadingLabel)
        addSubview(searchBar)
        addSubview(segmentedControl)
        addSubview(segmentedControlActivitySwitcher)
        addSubview(switcherTitleLabel)
        tableView.addSubview(refreshControl)

        createSearchBarConstraints()
        createSegmentedControlConstraints()
        createTableViewConstraints()
        createActivityIndicatorConstraints()
        createLoadingLabelConstraints()
        createSwitchConstraints()
        createSwitcherTitleConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setSegmentedControlWith(titles: [String]) {
        for item in titles {
            segmentedControl.insertSegment(withTitle: item, at: segmentedControl.numberOfSegments, animated: true)
        }
        segmentedControl.selectedSegmentIndex = 0
    }

    func setSwitcherWith(action: @escaping (_ : Bool) -> Void){
        reset = action
    }

    func setRefreshControlWith(action: @escaping () -> Void) {
        refresh = action
    }

    @objc private func resetFilter() {
        reset(segmentedControlActivitySwitcher.isOn)
    }

    @objc private func filterTableViewData() {
        filter?(segmentedControl.selectedSegmentIndex)
    }

    @objc private func refreshTableViewItems() {
        refresh?()
    }

    func setSegmentedControlWith(action: @escaping (_ : Int) -> ()){
        filter = action
    }

    private func createSwitchConstraints() {
        segmentedControlActivitySwitcher.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([segmentedControlActivitySwitcher.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
                                     segmentedControlActivitySwitcher.trailingAnchor.constraint(equalTo: trailingAnchor)])
    }

    private func createSearchBarConstraints() {
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([searchBar.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
                                     searchBar.leadingAnchor.constraint(equalTo: leadingAnchor),
                                     searchBar.trailingAnchor.constraint(equalTo: trailingAnchor),
                                     searchBar.heightAnchor.constraint(equalToConstant: searchBarHeightConstant)])
    }

    private func createSegmentedControlConstraints() {
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([segmentedControl.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
                                     segmentedControl.leadingAnchor.constraint(equalTo: leadingAnchor),
                                     segmentedControl.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.6)])
    }

    private func createTableViewConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([tableView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor),
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

    private func createSwitcherTitleConstraints() {
        switcherTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([switcherTitleLabel.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
                                     switcherTitleLabel.leadingAnchor.constraint(equalTo: segmentedControl.trailingAnchor),
                                     switcherTitleLabel.trailingAnchor.constraint(equalTo: segmentedControlActivitySwitcher.leadingAnchor),
                                     switcherTitleLabel.bottomAnchor.constraint(equalTo: tableView.topAnchor)])
    }

    func reloadData() {
        tableView.reloadData()
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
