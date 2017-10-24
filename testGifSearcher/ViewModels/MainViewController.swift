import UIKit
import Alamofire
import SDWebImage

class MainViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {

    private let segueToResultView = "segueToResultView"
    private let giphyService = GiphyService()
    private let gifPlaceholder = UIImage(named: "ImagePlaceHolder")

    @IBOutlet weak var progressStateInfo: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    private var trendedGifs: [GifModel] = []
    private var searchResult: [GifModel] = []
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
        if let data = result {
            trendedGifs = data
            self.tableView.reloadData()
            hideTableView(false)
        }else {
            self.createAlert(title: NSLocalizedString("WarningTitle", comment: ""),
                             message: NSLocalizedString("WarningMessage", comment: ""))
        }
    }

    //MARK: - Updating view content
    @objc private func refreshTrendedGifs() {
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
    }

    private func refreshTrendedGifsAsync (completion: @escaping () -> Void) {
        DispatchQueue.global().async {
            self.giphyService.returnTrendingGifs(completion: self.trendedGifsDidLoad)
            completion()
        }
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
            progressStateInfo.isHidden = !isHidden
            tableView.isHidden = isHidden
            activityIndicator.isHidden = !isHidden
    }
}

