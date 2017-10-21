import Foundation

class GifModel {
    var url:String
    var isTrended:Bool
    var family:String

    init(url:String ,trended: Bool, family:String) {
        self.url = url
        self.isTrended = trended
        self.family = family
    }
}
