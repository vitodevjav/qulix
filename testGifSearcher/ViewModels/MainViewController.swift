import UIKit
import Alamofire
import SDWebImage

class MainViewController: UIViewController{

    private let segueToResultView = "segueToResultView"
    private let giphyService = GiphyService()
    private let gifPlaceholder = UIImage(named: "ImagePlaceHolder")
    private var isLoading = true
    private let loadingTriggerOffset: CGFloat = 0.0
    private var trendedGifs: [GifModel] = []
    var trendedGifsView = TrendedGifsView(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))

    override func viewDidLoad() {
        super.viewDidLoad()
        view = trendedGifsView
        title = NSLocalizedString("gifSearcher", comment: "")
        trendedGifsView.tableViewDelegate = self
        trendedGifsView.searchBarDelegate = self
        trendedGifsView.dataSource = self
        let refreshTitle = NSLocalizedString("loading", comment: "")
        trendedGifsView.refreshControl.attributedTitle = NSAttributedString(string: refreshTitle)
        trendedGifsView.refreshControl.addTarget(self, action: #selector(refreshTrendedGifs), for: .valueChanged)

        giphyService.loadTrendingGifs(offset: trendedGifs.count, completion: trendedGifsDidLoad)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        trendedGifsView.hideLoadingView()
    }

    private func trendedGifsDidLoad(result: [GifModel]?) {
        guard let data = result else {
            createAlert(title: NSLocalizedString("warningTitle", comment: ""),
                             message: NSLocalizedString("serverError", comment: ""))
            return
        }
        trendedGifs += data
        trendedGifsView.reloadData()
        trendedGifsView.hideLoadingView()
        isLoading = false
    }

    @objc func refreshTrendedGifs() {
        DispatchQueue.global().async {
            self.giphyService.loadTrendingGifs(offset: self.trendedGifs.count, completion: self.trendedGifsDidLoad)
        }
        trendedGifs.removeAll()
    }

    func loadNextGifsFromServer() {
        trendedGifsView.showLoadingView()
        giphyService.loadTrendingGifs(offset: trendedGifs.count, completion: trendedGifsDidLoad)
    }

    private func createAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message,
                                      preferredStyle: UIAlertControllerStyle.alert)

        let action = UIAlertAction(title: NSLocalizedString("close", comment: ""), style: .cancel)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: - UISearchBarDelegate
extension MainViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchRequest = searchBar.text else {
            createAlert(title: "warningTitle", message: "badRequest")
            return
        }
        navigationController?.pushViewController(ResultViewController(giphyService: giphyService, searchRequest: searchRequest), animated: true)
//        performSegue(withIdentifier: segueToResultView, sender: self)
        trendedGifsView.showLoadingView()
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

// MARK: - UITableViewDelegate
extension MainViewController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        let deltaOffset = maximumOffset - currentOffset

        guard deltaOffset <= loadingTriggerOffset, !isLoading else {
            return
        }
        isLoading = true
        loadNextGifsFromServer()
    }
}
