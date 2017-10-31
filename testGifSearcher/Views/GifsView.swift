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
    private var selectViewHeightConstant: CGFloat = 50
    private var initialTableViewContentOffset: CGFloat = -100

    private var selectView: SelectView = {
        let selectView = SelectView(frame: .zero)
        return selectView
    }()

    private var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .darkGray
        tableView.register(GifTableViewCell.self, forCellReuseIdentifier: GifTableViewCell.identifier)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 0
        return tableView
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
        searchBar.barTintColor = .black
        searchBar.placeholder = NSLocalizedString("Search", comment: "")
        return searchBar
    }()

    var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        let refreshTitle = NSLocalizedString("loading", comment: "")
        refreshControl.attributedTitle = NSAttributedString(string: refreshTitle)
        refreshControl.addTarget(self, action: #selector(refreshTableViewItems), for: .valueChanged)
        return refreshControl
    }()

    private var segmentedControlTitles: [String]? {
        didSet {
            guard segmentedControlTitles != nil else {
                return
            }
            selectView.setSegmentedControlWith(titles: segmentedControlTitles!)
        }
    }

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

    var tableViewDataSource: UITableViewDataSource? {
        didSet {
            tableView.dataSource = tableViewDataSource
        }
    }
    
    private var refresh: (() -> Void)?
    private var resetFilter: ((_: Bool) -> Void)?
    private var filter: ((_: String) -> Void)? {
        didSet {
            guard filter != nil else {
                return
            }
            selectView.setSelectionIsChangedAction(action: filter!)
        }
    }

    //MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(searchBar)
        addSubview(selectView)
        addSubview(tableView)
        addSubview(activityIndicator)
        addSubview(isLoadingLabel)
        tableView.addSubview(refreshControl)

        createSearchBarConstraints()
        createSelectViewConstraints()
        createTableViewConstraints()
        createActivityIndicatorConstraints()
        createLoadingLabelConstraints()
    }

    @objc func backgroundTapped() {
        endEditing(true)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //MARK: - Actions
    @objc private func refreshTableViewItems() {
        refresh?()
    }

    func setSelectOptions(options: [String]) {
        segmentedControlTitles = options
    }

    func setSwitcherWith(action: @escaping (_ : Bool) -> Void){
        resetFilter = action
    }

    func setRefreshControlWith(action: @escaping () -> Void) {
        refresh = action
    }

    func setSegmentedControlWith(action: @escaping (_ : String) -> ()){
        filter = action
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

    //MARK: - Constraint creating
    private func createSearchBarConstraints() {
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([searchBar.topAnchor.constraint(equalTo: topAnchor),
                                     searchBar.leadingAnchor.constraint(equalTo: leadingAnchor),
                                     searchBar.trailingAnchor.constraint(equalTo: trailingAnchor)])
    }

    private func createSelectViewConstraints() {
        selectView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([selectView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
                                     selectView.leadingAnchor.constraint(equalTo: leadingAnchor),
                                     selectView.trailingAnchor.constraint(equalTo: trailingAnchor),
                                     selectView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.08)])
    }

    private func createTableViewConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([tableView.topAnchor.constraint(equalTo: selectView.bottomAnchor),
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
}
