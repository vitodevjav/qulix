//
//  GifViewController.swift
//  testGifSearcher
//
//  Created by Kazakevich, Vitaly on 10/30/17.
//  Copyright © 2017 Vitalik. All rights reserved.
//

import Foundation
import UIKit

class GifViewController: UIViewController {

    private var gifView = GifView(frame: .zero)
    private var gif: GifModel
    init(gif: GifModel) {
        self.gif = gif
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        super.loadView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(gifView)
        gifView.setViewContent(gif: gif)
        createConstraints()
    }

    func createConstraints() {
        gifView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([gifView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor),
                                     gifView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                                     gifView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                                     gifView.trailingAnchor.constraint(equalTo: view.trailingAnchor)])
    }
}

