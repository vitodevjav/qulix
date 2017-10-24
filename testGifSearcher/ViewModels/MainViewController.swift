import UIKit
import Alamofire
import SDWebImage

class MainViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {

    private let segueToResultView = "segueToResultView"
    private let giphyService = GiphyService()
    private let gifPlaceholder = UIImage(named: "ImagePlaceHolder")

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loadingStateView: UIView!

    private var loadStatus = false
    private var trendedGifsOffset = 0
    private let getNextGifsFromServerBottomOffset: CGFloat = 10.0
    private var trendedGifs: [GifModel] = []
    private var refreshControl = UIRefreshControl()

    //MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let refreshTitle = NSLocalizedString("Loading", comment: "")

        refreshControl.attributedTitle = NSAttributedString(string: refreshTitle)
        refreshControl.addTarget(self, action: #selector(refreshTrendedGifs), for: .valueChanged)
        tableView.addSubview(refreshControl)

        giphyService.returnTrendingGifs(offset: trendedGifs.count, completion: trendedGifsDidLoad)

        let width = UIScreen.main.bounds.width
        tableView.rowHeight = width * 0.7
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideTableView(false)
    }

    //MARK: - TableView delegate's methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trendedGifs.count
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

        guard deltaOffset <= -getNextGifsFromServerBottomOffset else {
            return
        }
        guard !loadStatus else {
            return
        }
        loadStatus = true
        loadingStateView.isHidden = false
        getNextGifsFromServer()
    }

    //MARK: - Actions
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        performSegue(withIdentifier: segueToResultView, sender: self)
        hideTableView(true)
        view.endEditing(false)
    }

    @IBAction func backgroundTapped(_ sender: Any) {
        view.endEditing(false)
    }

    //MARK: - Prepare for transition
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! ResultViewController
        destination.giphyService = giphyService
        guard let searchRequest = searchBar.text else {
            self.createAlert(title: NSLocalizedString("WarningTitle", comment: ""),
                             message: NSLocalizedString("WarningMessage", comment: ""))
            return
        }
        destination.title = searchRequest
    }

    //MARK: - Event handlers
    private func trendedGifsDidLoad(result: [GifModel]?) {
        refreshControl.endRefreshing()
        guard let data = result else {
            self.createAlert(title: NSLocalizedString("WarningTitle", comment: ""),
                             message: NSLocalizedString("WarningMessage", comment: ""))
            return
        }
        trendedGifs += data
        self.tableView.reloadData()
        hideTableView(false)
    }

    //MARK: - Updating view content
    @objc func refreshTrendedGifs() {
        refreshTrendedGifsAsync()
    }

    private func refreshTrendedGifsAsync () {
        DispatchQueue.global().async {
            self.giphyService.returnTrendingGifs(offset: self.trendedGifs.count, completion: self.trendedGifsDidLoad)
        }
    }

    func getNextGifsFromServer() {
        giphyService.returnTrendingGifs(offset: trendedGifs.count, completion: trendedGifsDidLoad)
    }

    //MARK: - Creating alerts
    private func createAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message,
                                      preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: ""),
                                      style: .default,
                                      handler: {(action) in
                                        alert.dismiss(animated: true, completion: nil)
                                        self.hideTableView(false)
        }))
        self.present(alert, animated: true, completion: nil)
    }

    //MARK: - Switching view states
    private func hideTableView (_ isHidden: Bool) {
            loadingStateView.isHidden = !isHidden
            tableView.isHidden = isHidden
            activityIndicator.isHidden = !isHidden
            loadStatus = isHidden
    }
}

