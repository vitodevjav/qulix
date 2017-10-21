import UIKit
import Alamofire
import SDWebImage

class MainViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource{

    private let segueToResultView = "segueToResultView"
    private let giphyService = GiphyService()
    private let gifPlaceholder = UIImage(named: "ImagePlaceHolder")
    private let loadMoreGifsScrollOffset:CGFloat = -10.0
    private let gifsCountPerRequest = 20

    @IBOutlet weak var gifsLoadingStatusView: UIView!

    @IBOutlet weak var progressStateInfo: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    private var gifsOnScreenCount = 20;
    private var trendedGifs: [GifModel] = []
    private var searchResult: [GifModel] = []
    private var loadStatus = false
    private var refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        let refreshTitle = NSLocalizedString("Loading", comment: "")

        refreshControl.attributedTitle = NSAttributedString(string: refreshTitle)
        refreshControl.addTarget(self, action: #selector(refresh(sender:)),
                                 for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl)

        progressStateInfo.text = NSLocalizedString("Loading", comment: "")
        progressStateInfo.isHidden = false

        giphyService.returnTrendingGifs(completion: {(isSuccess:Bool, result:[GifModel])in
            self.trendedGifsDidLoad(isSuccess,result)})

        let width = UIScreen.main.bounds.width
        tableView.rowHeight = width*0.7
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideTableView(false)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if gifsOnScreenCount > trendedGifs.count {
            return trendedGifs.count
        }else {
            return gifsOnScreenCount
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: GifTableViewCell.identifier,
                                                 for: indexPath) as! GifTableViewCell

        cell.gifView.sd_setImage(with: URL(string: trendedGifs[indexPath.row].url),
                                 placeholderImage: gifPlaceholder)
        cell.setTrended()
        return cell
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        let deltaOffset = maximumOffset - currentOffset

        guard deltaOffset <= loadMoreGifsScrollOffset else {
            return
        }
        guard !loadStatus else {
            return
        }
        showGifsLoadingStatusView(true)
        loadMoreGifs() {
            self.gifsDidLoad()
        }
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        hideTableView(true)
        progressStateInfo.text = NSLocalizedString("Loading", comment: "")
        giphyService.searchGifsByName(searchBar.text!, completion: {(isSuccess,result:[GifModel]) in
            self.searchResult = result;
            if isSuccess {
                self.performSegue(withIdentifier:self.segueToResultView, sender: self)
            }else {
                self.createAlert(title: NSLocalizedString("WarningTitle", comment: ""),
                                 message: NSLocalizedString("WarningMessage", comment: ""))
            }
        })
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! ResultViewController
        destination.result = searchResult
        destination.title = self.searchBar.text!
    }

    private func trendedGifsDidLoad(_ isSuccess:Bool,_ result:[GifModel]) {
        if isSuccess {
            trendedGifs = result
            self.tableView.reloadData()
            hideTableView(false)
        }else {
            self.createAlert(title: NSLocalizedString("WarningTitle", comment: ""),
                             message: NSLocalizedString("WarningMessage", comment: ""))
        }
    }

    private func showGifsLoadingStatusView(_ isShown: Bool){
        loadStatus = isShown
        gifsLoadingStatusView.isHidden = !isShown
        progressStateInfo.isHidden =  !isShown
    }

    private func gifsDidLoad(){
        DispatchQueue.main.async{
            self.showGifsLoadingStatusView(false)
            self.tableView.reloadData()
        }
    }

    private func loadMoreGifs(completion: @escaping ()->Void) {
        DispatchQueue.global().async {
            self.gifsOnScreenCount += self.gifsCountPerRequest
            completion()
        }
    }

    @objc private func refresh(sender:AnyObject) {
        beginRefresh(newtext: "Refresh") {
                        self.tableView.reloadData()
                        self.refreshControl.endRefreshing()
        }
    }

    private func beginRefresh(newtext:String, endRefresh: @escaping () -> Void) {
        DispatchQueue.global().async {
            self.giphyService.returnTrendingGifs(completion: {(isSuccess:Bool, result:[GifModel])in
                self.trendedGifsDidLoad(isSuccess,result)})
                endRefresh()
        }
    }

    private func createAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message,
                                      preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: ""),
                                      style: UIAlertActionStyle.default,
                                      handler: { (action) in
                                        alert.dismiss(animated: true, completion: nil)
                                        self.hideTableView(true)
        }))
        self.present(alert,animated: true, completion: nil)
    }

    private func hideTableView (_ isHidden: Bool) {
            progressStateInfo.isHidden = !isHidden
            tableView.isHidden = isHidden
            activityIndicator.isHidden = !isHidden
    }
}

