//
//  SelectView.swift
//  testGifSearcher
//
//  Created by Kazakevich, Vitaly on 10/27/17.
//  Copyright © 2017 Vitalik. All rights reserved.
//

import Foundation

class SelectView: UIView, UIGestureRecognizerDelegate {

    private let defaultMargin: CGFloat = 10
    private var switcherTitleLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("resetFilter", comment: "")
        label.font = UIFont(name: label.font.fontName, size: 15)
        label.textAlignment = .center
        label.textColor = .white
        label.isEnabled = false
        return label
    }()

    private var segmentedControlActivitySwitcher: UISwitch = {
        let switcher = UISwitch()
        switcher.onTintColor = UIColor.white.withAlphaComponent(0.9)
        switcher.actions(forTarget: self, forControlEvent: .valueChanged)
        switcher.addTarget(self, action: #selector(enableFilter), for: .valueChanged)
        switcher.setOn(false, animated: true)
        return switcher
    }()

    private var segmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl()
        segmentedControl.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        segmentedControl.tintColor = UIColor.white.withAlphaComponent(0.7)
        segmentedControl.addTarget(self, action: #selector(filter), for: .valueChanged)
        segmentedControl.isEnabled = false
        return segmentedControl
    }()

    private var selectionIsChangedAction: ((_ : String) -> Void)?

    //MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(segmentedControl)
        addSubview(switcherTitleLabel)
        addSubview(segmentedControlActivitySwitcher)

        createSegmentedControlConstraints()
        createSwitchConstraints()
        createSwitcherTitleConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //MARK: - Actions
    @objc private func enableFilter() {
        let isEnabled = segmentedControlActivitySwitcher.isOn
        segmentedControl.isEnabled = isEnabled
        if (!isEnabled) {
            segmentedControl.selectedSegmentIndex = -1
        }
        switcherTitleLabel.isEnabled = isEnabled
        filter()
    }

    @objc private func filter() {
        let index = segmentedControl.selectedSegmentIndex
        guard index != -1 else {
            selectionIsChangedAction?("")
            return
        }
        guard let title = segmentedControl.titleForSegment(at: index) else {
            return
        }
        selectionIsChangedAction?(title)
    }

    func setSegmentedControlWith(titles: [String]) {
        for item in titles {
            segmentedControl.insertSegment(withTitle: item, at: segmentedControl.numberOfSegments, animated: true)
        }
    }

    func setSelectionIsChangedAction(action: @escaping (_ : String) -> Void) {
        selectionIsChangedAction = action
    }

    // MARK: - Constraints creating
    private func createSwitchConstraints() {
        segmentedControlActivitySwitcher.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([segmentedControlActivitySwitcher.centerYAnchor.constraint(equalTo: centerYAnchor),
                                     segmentedControlActivitySwitcher.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -defaultMargin)])
    }

    private func createSegmentedControlConstraints() {
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([segmentedControl.centerYAnchor.constraint(equalTo: centerYAnchor),
                                     segmentedControl.leadingAnchor.constraint(equalTo: leadingAnchor, constant: defaultMargin),
                                     segmentedControl.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.6)])
    }

    private func createSwitcherTitleConstraints() {
        switcherTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([switcherTitleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
                                     switcherTitleLabel.trailingAnchor.constraint(equalTo: segmentedControlActivitySwitcher.leadingAnchor, constant: -defaultMargin)])
    }
}
