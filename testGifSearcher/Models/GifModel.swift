import Foundation

class GifModel {
    var url:String
    var trended:Bool
    var family:String

    init(url:String ,trended: Bool, family:String) {
        self.url = url
        self.trended = trended
        self.family = family
    }
}
