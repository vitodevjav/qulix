import Foundation

class GifModel {
    var url: String
    var isTrended: Bool
    var rating: String

    init(url: String, trended: Bool, rating: String) {
        self.url = url
        self.isTrended = trended
        self.rating = rating
    }
}
