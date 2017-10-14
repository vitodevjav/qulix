import UIKit
import SDWebImage

@IBDesignable
class GifTableViewCell: UITableViewCell {
    @IBOutlet weak var isTrendedMarkerView: UIView!
    @IBOutlet weak var gifView: FLAnimatedImageView!
    @IBOutlet weak var starImageView: UIImageView!
}
