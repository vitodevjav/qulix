import Foundation
import Alamofire
import CoreData

class GiphyService {

    private let keyApi = "oTZ3TChX3NjlHPtzKLCvLIuETVsEpp5q"
    private let gifsCountToReturn = 50

    func parseNotificationMessageToGif(json: [String: Any]) -> GifModelMO? {
        debugPrint(json)
        guard let originalURL = json["url"] as? String,
            let height = json["height"] as? Int,
            let width = json["width"] as? Int,
            let rating = json["rating"] as? String,
            let isTrended = json["isTrended"] as? Bool else {
                return nil
        }
        return CoreDataStack.instance.createGifModelMO(height: height, width: width, rating: rating,
                                                     originalUrl: originalURL, isTrended: isTrended)
    }

    private func parseJsonToGifArray(_ json: [String: Any]) -> [GifModelMO]? {
        guard let dataMap = json["data"] as? [[String: Any]] else {
            return nil
        }
        var gifArray: [GifModelMO]=[]
        for data in dataMap {
            guard let images = data["images"] as? [String: Any],
                let original = images["original"] as? [String: Any],
                let trended = (data["trending_datetime"] as? String)?.isEmpty,
                let rating = data["rating"] as? String,
                let originalURL = original["url"] as? String,
                let stringHeight = original["height"] as? String,
                let stringWidth = original["width"] as? String,
                let height = Int(stringHeight),
                let width = Int(stringWidth) else {
                    continue
            }
            gifArray.append(CoreDataStack.instance.createGifModelMO(height: height, width: width, rating: rating,
                                                                    originalUrl: originalURL, isTrended: trended))
        }
        return gifArray
    }

    public func loadTrendingGifs(offset: Int, rating: String, completion: @escaping ([GifModelMO]?) -> Void) {
        let urlString = "https://api.giphy.com/v1/gifs/trending?rating=\(rating)&api_key=\(keyApi)&limit=\(self.gifsCountToReturn)&offset=\(offset)"

        Alamofire.request(urlString).responseJSON { response in
            guard let json = response.result.value as? [String: Any] else {
                completion(nil)
                return
            }
            let gifArray  = self.parseJsonToGifArray(json)
            completion(gifArray)
        }
    }

    public func searchGifsByName(_ name: String, offset: Int, rating: String, completion: @escaping ([GifModelMO]?) -> Void) {
        let httpName = name.replacingOccurrences(of: " ", with: "+")
        let urlString = "https://api.giphy.com/v1/gifs/search?q=\(httpName)&rating=\(rating)&api_key=\(keyApi)&limit=\(gifsCountToReturn)&offset=\(offset)"

        Alamofire.request(urlString).responseJSON { response in
            guard let json = response.result.value as? [String: Any] else {
                completion(nil)
                return
            }
            let gifArray = self.parseJsonToGifArray(json)
            completion(gifArray)
        }
    }
}
