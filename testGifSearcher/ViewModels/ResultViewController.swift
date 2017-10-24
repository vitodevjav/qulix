
import UIKit
import SDWebImage

class ResultViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    var giphyService: GiphyService!
    private var gifsOnScreenCount = 50

    private var result: [GifModel] = []
    private var selectedGifs:[GifModel] = []
    private var searchRequest: String!

    private var yFamilyIsNeeded:Bool = false
    private var gFamilyIsNeeded:Bool = false
    private var pgFamilyIsNeeded:Bool = false

    private let loadMoreGifsBottomOffset: CGFloat = 10.0
    private var loadStatus = false

    @IBOutlet weak var loadingStateView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBAction func pgCheckBoxStatusIsChanged(_ sender: Any) {
        pgFamilyIsNeeded = !pgFamilyIsNeeded
        selectGifs()
    }

    @IBAction func yCheckBoxStatusIsChanged(_ sender: Any) {
        yFamilyIsNeeded = !yFamilyIsNeeded
        selectGifs()
    }

    @IBAction func gCheckBoxStatusIsChanged(_ sender: Any) {
        gFamilyIsNeeded = !gFamilyIsNeeded
        selectGifs()
    }

    private func selectGifs() {
        selectedGifs.removeAll()
        for gif in result{
            if gFamilyIsNeeded && gif.family == "g"{
                selectedGifs.append(gif)
            }
            if yFamilyIsNeeded && gif.family == "y"{
                selectedGifs.append(gif)
            }
            if pgFamilyIsNeeded && gif.family == "pg"{
                selectedGifs.append(gif)
            }
        }
        tableView.reloadData()
        self.loadStatus = false
    }

    private func gifsDidLoad(isSuccess: Bool, result: [GifModel]) {
        self.result += result
        selectGifs()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if let searchRequest = title {
            self.searchRequest = searchRequest
            giphyService.searchGifsByName(searchRequest, offset: result.count, completion: gifsDidLoad)
        }
        selectedGifs = result

        let width = UIScreen.main.bounds.width
        tableView.rowHeight = width*0.7
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedGifs.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as! GifTableViewCell

        cell.gifView.sd_setImage(with: URL(string: selectedGifs[indexPath.row].url)!, placeholderImage: UIImage(named: "ImagePlaceHolder"))
        if (selectedGifs[indexPath.row].trended) {cell.starImageView.image = UIImage(named: "trendedImage")}

        return cell
    }

    func getNextGifsFromServer() {
         giphyService.searchGifsByName(searchRequest, offset: result.count, completion: {(isSuccess:Bool, result:[GifModel])in
            self.result += result
            self.loadingStateView.isHidden = true
            self.selectGifs()
        })
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        let deltaOffset = maximumOffset - currentOffset
        
        guard deltaOffset <= loadMoreGifsBottomOffset else {
            return
        }
        guard !loadStatus else {
            return
        }
        loadStatus = true
        loadingStateView.isHidden = false
        getNextGifsFromServer()
    }

    private func createAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: ""), style: UIAlertActionStyle.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert,animated: true, completion: nil)
    }
}
