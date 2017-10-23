import Foundation
import Alamofire


class GiphyService {

    private let keyApi = "oTZ3TChX3NjlHPtzKLCvLIuETVsEpp5q"
    private let gifsCountToReturn = 1000

    private func parseJsonToGifArray(_ JSON:[String:Any])->[GifModel]{
        guard let dataMap = JSON["data"] as? [[String: Any]] else {
            return []
        }
        var gifArray:[GifModel]=[]
        for data in dataMap {
            guard let images = data["images"] as? [String: Any],
                  let fixedSizeGif = images["downsized"] as? [String: Any],
                  let trended = (data["trending_datetime"] as? String)?.isEmpty,
                  let family = data["rating"] as? String,
                  let url = fixedSizeGif["url"] as? String else {
                return []
            }
            gifArray.append(GifModel(url: url,trended: trended,family: family))
        }
        return gifArray
    }

    public func returnTrendingGifs(completion:@escaping([GifModel]?) -> Void){
        let urlString = "https://api.giphy.com/v1/gifs/trending?api_key=\(keyApi)&limit=\(self.gifsCountToReturn)"
        
        Alamofire.request(urlString, method: .get, parameters: nil,
                          encoding: JSONEncoding.default)
            .responseJSON { response in
                guard let json = response.result.value as? [String: Any] else {
                    completion(nil)
                    return
                }
                let gifArray  = self.parseJsonToGifArray(json)
                completion(gifArray)
            }
    }

    public func searchGifsByName(_ name:String, completion:@escaping([GifModel]?) -> Void){
        let httpName = name.replacingOccurrences(of: " ", with: "+")
        let urlString = "https://api.giphy.com/v1/gifs/search?q=\(httpName)&api_key=\(keyApi)&limit=\(gifsCountToReturn)"

        Alamofire.request(urlString, method: .get, parameters: nil,encoding: JSONEncoding.default)
            .responseJSON { response in
                guard let json = response.result.value as? [String: Any] else {
                    completion(nil)
                    return
                }
                let gifArray  = self.parseJsonToGifArray(json)
                completion(gifArray)
        }
    }
}
