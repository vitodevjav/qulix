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
        setConstraints()

        starImageView.image = trendedMarkImage

        addSubview(gifView)
        addSubview(starImageView)

        createGifViewConstraints()
        createStarImageViewConstraints()
    }

    func setConstraints() {
        heightAnchor.constraint(equalTo: widthAnchor, multiplier: 0.7).isActive = true
    }

    private func createGifViewConstraints() {
        gifView.translatesAutoresizingMaskIntoConstraints = false
        gifView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        gifView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        gifView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        gifView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }

    private func createStarImageViewConstraints() {
        starImageView.translatesAutoresizingMaskIntoConstraints = false
        starImageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        starImageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        starImageView.widthAnchor.constraint(equalToConstant: trendedMarkSize).isActive = true
        starImageView.heightAnchor.constraint(equalToConstant: trendedMarkSize).isActive = true
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
