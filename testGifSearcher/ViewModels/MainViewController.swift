import UIKit
import Alamofire
import SDWebImage

class MainViewController: UIViewController {

    private let segueToResultView = "segueToResultView"
    private let giphyService = GiphyService()
    private let gifPlaceholder = UIImage(named: "ImagePlaceHolder")

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loadingStateView: UIView!

    private var isLoading = false
    private let loadingTriggerOffset: CGFloat = 0.0
    private var trendedGifs: [GifModel] = []
    private var refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()

        let refreshTitle = NSLocalizedString("Loading", comment: "")
        refreshControl.attributedTitle = NSAttributedString(string: refreshTitle)
        refreshControl.addTarget(self, action: #selector(refreshTrendedGifs), for: .valueChanged)
        tableView.addSubview(refreshControl)

        giphyService.loadTrendingGifs(offset: trendedGifs.count, completion: trendedGifsDidLoad)

        let width = UIScreen.main.bounds.width
        tableView.rowHeight = width * 0.7
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showLoadingView(false)
    }

    @IBAction func backgroundTapped(_ sender: Any) {
        view.endEditing(false)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! ResultViewController
        destination.giphyService = giphyService
        guard let searchRequest = searchBar.text else {
            self.createAlert(title: NSLocalizedString("WarningTitle", comment: ""),
                             message: NSLocalizedString("WarningMessage", comment: ""))
            return
        }
        destination.searchRequest = searchRequest
    }

    private func trendedGifsDidLoad(result: [GifModel]?) {
        refreshControl.endRefreshing()
        guard let data = result else {
            self.createAlert(title: NSLocalizedString("warningTitle", comment: ""),
                             message: NSLocalizedString("serverError", comment: ""))
            return
        }
        trendedGifs += data
        self.tableView.reloadData()
        showLoadingView(false)
    }

    @objc func refreshTrendedGifs() {
        DispatchQueue.global().async {
            self.giphyService.loadTrendingGifs(offset: self.trendedGifs.count, completion: self.trendedGifsDidLoad)
        }
        trendedGifs.removeAll()
    }

    func loadNextGifsFromServer() {
        giphyService.loadTrendingGifs(offset: trendedGifs.count, completion: trendedGifsDidLoad)
    }

    private func createAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message,
                                      preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("close", comment: ""),
                                      style: .default,
                                      handler: {(action) in
                                        alert.dismiss(animated: true, completion: nil)
                                        self.showLoadingView(false)
        }))
        self.present(alert, animated: true, completion: nil)
    }

    private func showLoadingView (_ isShowing: Bool) {
            loadingStateView.isHidden = !isShowing
            tableView.isHidden = isShowing
            activityIndicator.isHidden = !isShowing
            isLoading = isShowing
    }
}

// MARK: - UISearchBarDelegate
extension MainViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        performSegue(withIdentifier: segueToResultView, sender: self)
        showLoadingView(true)
        view.endEditing(false)
    }
}

// MARK: - UITableViewDataSource
extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trendedGifs.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: GifTableViewCell.identifier,
                                                 for: indexPath) as! GifTableViewCell

        cell.gifView.sd_setImage(with: URL(string: trendedGifs[indexPath.row].url),
                                 placeholderImage: gifPlaceholder)
        cell.setTrendedMark()
        return cell
    }
}

// MARK: - UITableViewDataSource
extension MainViewController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        let deltaOffset = maximumOffset - currentOffset

        guard deltaOffset <= loadingTriggerOffset, !isLoading else {
            return
        }
        isLoading = true
        loadingStateView.isHidden = false
        loadNextGifsFromServer()
    }
}
