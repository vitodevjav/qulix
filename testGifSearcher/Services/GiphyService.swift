import Foundation
import Alamofire


class GiphyService {

    private let keyApi = "oTZ3TChX3NjlHPtzKLCvLIuETVsEpp5q"
    private let gifsCountToReturn = 50
    private var trendedGifsOffset = 0

    private func parseJsonToGifArray(_ JSON:[String:Any])->[GifModel]{
        var gifArray:[GifModel]=[]

        if let dataMap = JSON["data"] as? [[String: Any]]{
            for data in dataMap{
                let images = data["images"] as! [String: Any]
                let fixedSizeGif = images["fixed_height_small"] as! [String: Any]

                let trended = !(data["trending_datetime"] as! String).isEmpty
                let family = data["rating"] as! String
                let url = fixedSizeGif["url"] as! String

                gifArray.append(GifModel(url: url,trended: trended,family: family))
            }
        }
        return gifArray
    }

    public func returnTrendingGifs(completion:@escaping(Bool,[GifModel]) -> Void){
        var gifArray:[GifModel]=[]
        let urlString = "https://api.giphy.com/v1/gifs/trending?api_key=\(keyApi)&limit=\(self.gifsCountToReturn)&offset=\(self.trendedGifsOffset)"
        
        Alamofire.request(urlString, method: .get, parameters: nil,encoding: JSONEncoding.default)
            .responseJSON { response in
                gifArray  = self.parseJsonToGifArray(response.result.value as! [String: Any])
                if gifArray.count > 0 {
                    completion(true,gifArray)
                    self.trendedGifsOffset += self.gifsCountToReturn
                }
                else{ completion(false,gifArray)}
            }
        
    }

    public func searchGifsByName(_ name:String, completion:@escaping(Bool,[GifModel]) -> Void){
        var gifArray:[GifModel]=[]
        let httpName = name.replacingOccurrences(of: " ", with: "+")
        let urlString = "https://api.giphy.com/v1/gifs/search?q=\(httpName)&api_key=\(keyApi)&limit=\(gifsCountToReturn)"

        Alamofire.request(urlString, method: .get, parameters: nil,encoding: JSONEncoding.default)
            .responseJSON { response in
                if let data = response.result.value{
                    gifArray = self.parseJsonToGifArray(data as! [String: Any])
                }

                if gifArray.count > 0 {completion(true,gifArray)}
                else{ completion(false,gifArray)}
        }
        
        
    }
}
