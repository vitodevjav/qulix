import UIKit
import Alamofire
import SDWebImage

class MainViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource{

    private let segueToResultView = "segueToResultView"
    private let giphyService = GiphyService()
    private let gifPlaceholder = UIImage(named: "ImagePlaceHolder")
    private let loadMoreGifsScrollOffset:CGFloat = 10.0
    private let gifsCountPerRequest = 20

    @IBOutlet weak var gifsLoadingStatusView: UIView!
    @IBOutlet weak var progressStateInfo: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    private var trendedGifs: [GifModel] = []
    private var searchResult: [GifModel] = []
    private var loadStatus = false
    private var refreshControl = UIRefreshControl()

    //MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let refreshTitle = NSLocalizedString("Loading", comment: "")

        refreshControl.attributedTitle = NSAttributedString(string: refreshTitle)
        refreshControl.addTarget(self, action: #selector(refreshTrendedGifs),
                                 for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl)

        progressStateInfo.text = NSLocalizedString("Loading", comment: "")
        progressStateInfo.isHidden = false

        giphyService.returnTrendingGifs(completion: self.trendedGifsDidLoad)

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

        guard deltaOffset <= -loadMoreGifsScrollOffset else {
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

    //MARK: - Actions
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        hideTableView(true)
        view.endEditing(false)
        progressStateInfo.text = NSLocalizedString("Loading", comment: "")
        guard let searchRequest = searchBar.text else {
            self.createAlert(title: NSLocalizedString("WarningTitle", comment: ""),
                             message: NSLocalizedString("WarningMessage", comment: ""))
            return
        }
        giphyService.searchGifsByName(searchRequest, completion: {(result:[GifModel]?) in
            guard let data = result else {
                self.createAlert(title: NSLocalizedString("WarningTitle", comment: ""),
                                 message: NSLocalizedString("WarningMessage", comment: ""))
                return
            }
            self.searchResult = data;
            self.performSegue(withIdentifier:self.segueToResultView, sender: self)
        })
    }

    @IBAction func backgroundTapped(_ sender: Any) {
        view.endEditing(false)
    }

    //MARK: - Prepare for transition
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! ResultViewController
        destination.result = searchResult
        guard let searchRequest = self.searchBar.text else {
            createAlert(title: NSLocalizedString("WarningTitle", comment: ""),
                             message: NSLocalizedString("WarningMessage", comment: ""))
            return
        }
        destination.title = searchRequest
    }

    //MARK: - Event handlers
    private func trendedGifsDidLoad(_ result:[GifModel]?) {
        if let data = result  {
            trendedGifs = data
            self.tableView.reloadData()
            hideTableView(false)
        }else {
            self.createAlert(title: NSLocalizedString("WarningTitle", comment: ""),
                             message: NSLocalizedString("WarningMessage", comment: ""))
        }
    }

    private func gifsDidLoad() {
        self.showGifsLoadingStatusView(false)
        self.tableView.reloadData()
    }

    //MARK: - Updating view content
    private func loadMoreGifs(completion: @escaping ()->Void) {
        DispatchQueue.global().async {
            completion()
        }
    }

    @objc private func refreshTrendedGifs() {
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
    }

    private func refreshTrendedGifsAsync (comletion: @escaping () -> Void) {
        DispatchQueue.global().async {
            self.giphyService.returnTrendingGifs(completion: self.trendedGifsDidLoad)
            comletion()
        }
    }

    //MARK: - Creating alerts
    private func createAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message,
                                      preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: ""),
                                      style: .default,
                                      handler: { (action) in
                                        alert.dismiss(animated: true, completion: nil)
                                        self.hideTableView(false)
        }))
        self.present(alert,animated: true, completion: nil)
    }

    //MARK: - Switching view states
    private func showGifsLoadingStatusView(_ isShown: Bool) {
        loadStatus = isShown
        gifsLoadingStatusView.isHidden = !isShown
        progressStateInfo.isHidden = !isShown
    }

    private func hideTableView (_ isHidden: Bool) {
            progressStateInfo.isHidden = !isHidden
            tableView.isHidden = isHidden
            activityIndicator.isHidden = !isHidden
    }
}

