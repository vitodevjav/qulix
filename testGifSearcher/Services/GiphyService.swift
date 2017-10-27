import Foundation
import Alamofire


class GiphyService {

    private let keyApi = "oTZ3TChX3NjlHPtzKLCvLIuETVsEpp5q"
    private let gifsCountToReturn = 50

    private func parseJsonToGifArray(_ json: [String: Any]) -> [GifModel]? {
        guard let dataMap = json["data"] as? [[String: Any]] else {
            return nil
        }
        var gifArray: [GifModel]=[]
        for data in dataMap {
            guard let images = data["images"] as? [String: Any],
                  let original = images["original"] as? [String: Any],
                  let trended = (data["trending_datetime"] as? String)?.isEmpty,
                  let rating = data["rating"] as? String,
                  let url = original["url"] as? String,
                  let stringHeight = original["height"] as? String,
                  let stringWidth = original["width"] as? String,
                  let height = Int(stringHeight),
                  let width = Int(stringWidth) else {
                continue
            }

            gifArray.append(GifModel(url: url, trended: trended, rating: rating, height: height, width: width))
        }
        return gifArray
    }

    public func loadTrendingGifs(offset: Int, rating: String, completion: @escaping ([GifModel]?) -> Void) {
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

    public func searchGifsByName(_ name: String, offset: Int, rating: String, completion: @escaping ([GifModel]?) -> Void) {
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
