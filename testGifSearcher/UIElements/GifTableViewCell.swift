import UIKit
import SDWebImage

@IBDesignable
class GifTableViewCell: UITableViewCell {
    static let identifier = "gifCell"
    @IBOutlet weak var isTrendedMarkerView: UIView!
    @IBOutlet weak var gifView: FLAnimatedImageView!
    @IBOutlet weak var starImageView: UIImageView!

    override func prepareForReuse() {
        super.prepareForReuse()
        isTrendedMarkerView.isHidden = true
    }

    public func setTrended() {
        starImageView.image = UIImage(named: "trendedImage")
        isTrendedMarkerView.isHidden = false
    }
}
