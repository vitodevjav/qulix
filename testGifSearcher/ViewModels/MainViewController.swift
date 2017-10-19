import UIKit
import Alamofire
import SDWebImage

class MainViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource{

    private let searchSegueIdentifier = "searchSegue"
    private let oopsWarningMessageString = "There are some problems. Try other request or check your internet connection."
    private let warningTitleString = "Sorry.."
    private let endWarningMessageString = "No more results."

    @IBOutlet weak var loadMoreView: UIView!
    private let giphyService = GiphyService()

    @IBOutlet weak var stateInfoView: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    private var gifsOnScreenCount = 20;
    private var trendingGifs: [GifModel] = []
    private var searchResult: [GifModel] = []
    
    private var loadStatus = false
    private var refreshControl = UIRefreshControl()

    override func viewWillAppear(_ animated: Bool) {
        tableView.isHidden = false
        stateInfoView.isHidden = true
        activityIndicator.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        refreshControl.attributedTitle = NSAttributedString(string: NSLocalizedString("Loading", comment: ""))
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl)
        
        stateInfoView.text = "Loading..."
        stateInfoView.isHidden = false

        let width = UIScreen.main.bounds.width
        tableView.rowHeight = width*0.7

        if NetworkReachabilityManager()!.isReachable {
            giphyService.returnTrendingGifs(completion: {(isSuccess:Bool, result:[GifModel])in
                self.gifsAreLoadedCompletionHandler(isSuccess,result)})
        }else{
            stateInfoView.text = "No internet connection"
            activityIndicator.isHidden = true
        }
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
            self.createAlert(title: self.warningTitleString, message: self.oopsWarningMessageString)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! ResultViewController
        destination.result = searchResult
        destination.title = self.searchBar.text!
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        activityIndicator.isHidden = false
        stateInfoView.text = "Loading..."
        stateInfoView.isHidden = false
        tableView.isHidden = true

        giphyService.searchGifsByName(searchBar.text!, completion: {(isSuccess,result:[GifModel]) in
                                        self.searchResult = result;
                                        if isSuccess {
                                            self.performSegue(withIdentifier:self.searchSegueIdentifier, sender: self)
                                        }else {self.createAlert(title : self.warningTitleString, message: self.oopsWarningMessageString)}
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
        
        if deltaOffset <= -10 {
            guard self.gifsOnScreenCount < self.trendingGifs.count else{
                self.createAlert(title: self.warningTitleString, message: self.endWarningMessageString)
                return
            }
            if !loadStatus {
                loadStatus = true
                loadMoreView.isHidden = false
                stateInfoView.isHidden =  false
                loadmore(completion: {() in
                    self.gifsDidLoadOntoScreen()
                })
            }
        }
    }
    
    func loadmore(completion: @escaping ()->()){
        DispatchQueue.global().async {
            sleep(2)
            self.gifsOnScreenCount += 20
            completion()
        }
    }
    
    func gifsDidLoadOntoScreen(){
        DispatchQueue.main.async{
            self.loadStatus = false
            self.loadMoreView.isHidden = true
            self.tableView.reloadData()
        }
    }
    
    @objc func refresh(sender:AnyObject) {
        refreshBegin(newtext: "Refresh",
                     refreshEnd: {(x:Int) -> () in
                        self.tableView.reloadData()
                        self.refreshControl.endRefreshing()
        })
    }
    
    func refreshBegin(newtext:String, refreshEnd: @escaping (Int) -> ()) {
        DispatchQueue.global().async {
            self.giphyService.returnTrendingGifs(completion: {(isSuccess:Bool, result:[GifModel])in
                self.gifsAreLoadedCompletionHandler(isSuccess,result)})
                refreshEnd(0)
        }
    }

    private func createAlert(title: String, message: String){

        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
                self.tableView.isHidden = false
                self.stateInfoView.isHidden = true
                self.activityIndicator.isHidden = true

        }))
        self.present(alert,animated: true, completion: nil)
    }

}

