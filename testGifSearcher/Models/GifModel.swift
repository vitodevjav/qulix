import Foundation

class GifModel {
    var url: String
    var isTrended: Bool
    var rating: String
    var height: Int
    var width: Int

    init(url: String, trended: Bool, rating: String, height: Int, width: Int) {
        self.url = url
        self.isTrended = trended
        self.rating = rating
        self.height = height
        self.width = width
    }
}
