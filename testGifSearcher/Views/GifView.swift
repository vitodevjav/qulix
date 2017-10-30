//
//  GifView.swift
//  testGifSearcher
//
//  Created by Kazakevich, Vitaly on 10/30/17.
//  Copyright © 2017 Vitalik. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage

class GifView: UIView {
    private var placeHolder = UIImage(named: "placeholder")
    private var gifContent: GifModel? {
        didSet {
            guard let gif = gifContent else {
                return
            }
            imageView.sd_setImage(with: URL(string: gif.originalURL), placeholderImage: placeHolder)
        }
    }
    private var imageView: FLAnimatedImageView = {
        return FLAnimatedImageView()
    }()

    override init(frame: CGRect) {
        super.init(frame: .zero)
        addSubview(imageView)
        createImageViewConstraints()
    }

    override func layoutSubviews() {
        guard let gif = gifContent else {
            return
        }
        let heigthRatio = CGFloat(gif.height)/bounds.height
        let widthRatio = CGFloat(gif.width)/bounds.width
        if (widthRatio > heigthRatio) {
            NSLayoutConstraint.activate([imageView.widthAnchor.constraint(equalTo: widthAnchor),
                                         imageView.heightAnchor.constraint(equalToConstant: CGFloat(gif.height)/widthRatio)])
        } else {
            NSLayoutConstraint.activate([imageView.heightAnchor.constraint(equalTo: heightAnchor),
                                         imageView.widthAnchor.constraint(equalToConstant: CGFloat(gif.width)/heigthRatio)])
        }
    }

    func setViewContent(gif: GifModel) {
        gifContent = gif
    }

    private func createImageViewConstraints() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([imageView.topAnchor.constraint(equalTo: topAnchor),
                                     imageView.leadingAnchor.constraint(equalTo: leadingAnchor)])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
