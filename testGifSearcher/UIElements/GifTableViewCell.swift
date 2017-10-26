import UIKit
import SDWebImage

class GifTableViewCell: UITableViewCell {

    private let trendedMarkSize: CGFloat = 50
    static let identifier = "GifTableViewCell"
    private let trendedMarkImage = UIImage(named: "trendedImage")
    var gifView = FLAnimatedImageView()
    var starImageView = UIImageView()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        starImageView.image = trendedMarkImage

        addSubview(gifView)
        addSubview(starImageView)

        createGifViewConstraints()
        createStarImageViewConstraints()
    }

    private func createGifViewConstraints() {
        gifView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([gifView.topAnchor.constraint(equalTo: topAnchor),
                                     gifView.leadingAnchor.constraint(equalTo: leadingAnchor),
                                     gifView.trailingAnchor.constraint(equalTo: trailingAnchor),
                                     gifView.bottomAnchor.constraint(equalTo: bottomAnchor)])
    }

    private func createStarImageViewConstraints() {
        starImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([starImageView.topAnchor.constraint(equalTo: gifView.topAnchor),
                                     starImageView.leadingAnchor.constraint(equalTo: gifView.leadingAnchor),
                                     starImageView.widthAnchor.constraint(equalToConstant: trendedMarkSize),
                                     starImageView.heightAnchor.constraint(equalToConstant: trendedMarkSize)])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        starImageView.isHidden = true
    }

    public func setTrendedMark() {
        starImageView.isHidden = false
    }
}
