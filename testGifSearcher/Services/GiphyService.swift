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
                  let fixedSizeGif = images["original"] as? [String: Any],
                  let trended = (data["trending_datetime"] as? String)?.isEmpty,
                  let rating = data["rating"] as? String,
                  let url = fixedSizeGif["url"] as? String else {
                continue
            }
            gifArray.append(GifModel(url: url, trended: trended, rating: rating))
        }
        return gifArray
    }

    public func loadTrendingGifs(offset: Int, completion: @escaping ([GifModel]?) -> Void) {
        let urlString = "https://api.giphy.com/v1/gifs/trending?api_key=\(keyApi)&limit=\(self.gifsCountToReturn)&offset=\(offset)"

        Alamofire.request(urlString).responseJSON { response in
            guard let json = response.result.value as? [String: Any] else {
                completion(nil)
                return
            }
            let gifArray  = self.parseJsonToGifArray(json)
            completion(gifArray)
        }
    }

    public func searchGifsByName(_ name: String, offset: Int, completion: @escaping ([GifModel]?) -> Void) {
        let httpName = name.replacingOccurrences(of: " ", with: "+")
        let urlString = "https://api.giphy.com/v1/gifs/search?q=\(httpName)&api_key=\(keyApi)&limit=\(gifsCountToReturn)&offset=\(offset)"

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
