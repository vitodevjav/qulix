import UIKit
import Alamofire
import SDWebImage

class MainViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource{

    private let searchSegueIdentifier = "searchSegue"

    private let giphyService = GiphyService()

    @IBOutlet weak var stateInfoView: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!


    @IBOutlet weak var loadingStateView: UIView!
    private var loadStatus = false
    private var gifsOnScreenCount = 50
    private var trendedGifsOffset = 0
    private let loadMoreGifsBottomOffset: CGFloat = 10.0
    private var trendingGifs: [GifModel] = []
    private var searchResult: [GifModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        stateInfoView.text = NSLocalizedString("Loading", comment: "")
        stateInfoView.isHidden = false

        giphyService.returnTrendingGifs(offset: trendingGifs.count, completion: {(isSuccess: Bool, result: [GifModel]) in
            self.gifsAreLoadedCompletionHandler(isSuccess, result)
        })
        let width = UIScreen.main.bounds.width
        tableView.rowHeight = width*0.7
    }

    private func gifsAreLoadedCompletionHandler(_ isSuccess:Bool,_ result:[GifModel]){
        if isSuccess {
            trendingGifs = result
            tableView.reloadData()
            
            activityIndicator.isHidden = true
            searchBar.isHidden = false
            stateInfoView.isHidden = true
            tableView.isHidden = false
        }else {
            self.createAlert(title: NSLocalizedString("WarningTitle", comment: ""), message: NSLocalizedString("WarningMessage", comment: ""))
        }
    }

    func getNextGifsFromServer() {
        giphyService.returnTrendingGifs(offset: trendingGifs.count, completion: {(isSuccess: Bool, result: [GifModel]) in
            self.trendingGifs += result
            self.loadingStateView.isHidden = true
            self.tableView.reloadData()
            self.loadStatus = false
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! ResultViewController
        destination.giphyService = giphyService
        destination.title = self.searchBar.text!
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        performSegue(withIdentifier: searchSegueIdentifier, sender: self)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trendingGifs.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! GifTableViewCell

        cell.gifView.sd_setImage(with: URL(string: trendingGifs[indexPath.row].url)!, placeholderImage: UIImage(named: "ImagePlaceHolder"))
        if (trendingGifs[indexPath.row].trended) {cell.starImageView.image = UIImage(named: "trendedImage")}

        return cell
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        let deltaOffset = maximumOffset - currentOffset

        guard deltaOffset <= -loadMoreGifsBottomOffset else {
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
                self.tableView.isHidden = false
                self.stateInfoView.isHidden = true
                self.activityIndicator.isHidden = true

        }))
        self.present(alert,animated: true, completion: nil)
    }
}

