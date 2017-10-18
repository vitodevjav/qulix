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

    private var gifsOnScreenCount = 50;
    private var trendingGifs: [GifModel] = []
    private var searchResult: [GifModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        stateInfoView.text = NSLocalizedString("Loading", comment: "")
        stateInfoView.isHidden = false

        let width = UIScreen.main.bounds.width
        tableView.rowHeight = width*0.7
    }

    private func gifsAreLoadedCompletionHandler(_ isSuccess:Bool,_ result:[GifModel]){
        if isSuccess {
            trendingGifs = result
            self.tableView.reloadData()

            activityIndicator.isHidden = true
            searchBar.isHidden = false
            stateInfoView.isHidden = true
            tableView.isHidden = false
        }else {
            self.createAlert(title: NSLocalizedString("WarningTitle", comment: ""), message: NSLocalizedString("WarningMessage", comment: ""))
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! ResultViewController
        destination.result = searchResult
        destination.title = self.searchBar.text!
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        activityIndicator.isHidden = false
        stateInfoView.text = NSLocalizedString("Loading", comment: "")
        stateInfoView.isHidden = false
        tableView.isHidden = true

        giphyService.searchGifsByName(searchBar.text!, completion: {(isSuccess,result:[GifModel]) in
                                        self.searchResult = result;
                                        if isSuccess {
                                            self.performSegue(withIdentifier:self.searchSegueIdentifier, sender: self)
                                        }else {self.createAlert(title: NSLocalizedString("WarningTitle", comment: ""), message: NSLocalizedString("WarningMessage", comment: ""))}
        })
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if gifsOnScreenCount > trendingGifs.count {
            return trendingGifs.count
        }else {
            return gifsOnScreenCount
        }
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

        if deltaOffset <= 0 {
            if self.gifsOnScreenCount < self.trendingGifs.count{
                self.gifsOnScreenCount += 50
                tableView.reloadData()
            }else {
                createAlert(title: NSLocalizedString("WarningTitle", comment: ""), message: NSLocalizedString("WarningMessage", comment: ""))
            }
        }
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

