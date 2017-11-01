import Foundation
import Alamofire
import CoreData

class GiphyService {

    var managedContext: NSManagedObjectContext!
    private let keyApi = "oTZ3TChX3NjlHPtzKLCvLIuETVsEpp5q"
    private let gifsCountToReturn = 50

    func parseJsonToGifArray(_ json: [String: Any]) -> [GifModelMO]? {
        guard let dataMap = json["data"] as? [[String: Any]] else {
            return nil
        }
        var gifArray: [GifModelMO]=[]
        for data in dataMap {
            guard let images = data["images"] as? [String: Any],
                let original = images["original"] as? [String: Any],
                let isTrended = (data["trending_datetime"] as? String)?.isEmpty,
                let rating = data["rating"] as? String,
                let originalURL = original["url"] as? String,
                let stringHeight = original["height"] as? String,
                let stringWidth = original["width"] as? String,
                let height = Int(stringHeight),
                let width = Int(stringWidth) else {
                    continue
            }
            let entity = NSEntityDescription.entity(forEntityName: GifModelMO.entityName, in: managedContext)
            guard let existingEntity = entity else {
                continue
            }
            let gifModel = NSManagedObject(entity: existingEntity, insertInto: managedContext) as! GifModelMO
            gifModel.height = Int32(height)
            gifModel.width = Int32(width)
            gifModel.originalURL = originalURL
            gifModel.rating = rating
            gifModel.isTrended = isTrended
            gifArray.append(gifModel)
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
