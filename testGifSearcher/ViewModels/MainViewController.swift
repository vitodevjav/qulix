import UIKit
import Alamofire
import SDWebImage

class MainViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource{

    private let searchSegueIdentifier = "searchSegue"

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
        super.viewWillAppear(animated)
        prepareView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let localisedString = NSLocalizedString("Loading", comment: "")

        refreshControl.attributedTitle = NSAttributedString(string: localisedString)
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl)

        stateInfoView.text = NSLocalizedString("Loading", comment: "")

        stateInfoView.isHidden = false

        giphyService.returnTrendingGifs(completion: {(isSuccess:Bool, result:[GifModel])in
            self.trendedGifsAreLoadedCompletionHandler(isSuccess,result)})
        
        let width = UIScreen.main.bounds.width
        tableView.rowHeight = width*0.7
    }

    func prepareView(){
        tableView.isHidden = false
        stateInfoView.isHidden = true
        activityIndicator.isHidden = true
        searchBar.isHidden = false
    }
    
    func prepareForTransition(){
        stateInfoView.isHidden = false
        tableView.isHidden = true
        activityIndicator.isHidden = false
    }
    
    private func trendedGifsAreLoadedCompletionHandler(_ isSuccess:Bool,_ result:[GifModel]){
        if isSuccess {
            trendingGifs = result
            self.tableView.reloadData()
            prepareView()
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
        prepareForTransition()
        stateInfoView.text = NSLocalizedString("Loading", comment: "")
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
    
    func gifsWillLoad(){
        loadStatus = true
        loadMoreView.isHidden = false
        stateInfoView.isHidden =  false
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        let deltaOffset = maximumOffset - currentOffset
        
        if deltaOffset <= -10 {
            guard self.gifsOnScreenCount < self.trendingGifs.count else {
                createAlert(title: NSLocalizedString("WarningTitle", comment: ""), message: NSLocalizedString("WarningMessage", comment: ""))
                return
            }
            if !loadStatus {
                gifsWillLoad()
                loadMore(completion: {() in
                    self.gifsDidLoadOntoScreen()
                })
            }
        }
    }
    
    func loadMore(completion: @escaping ()->Void) {
        DispatchQueue.global().async {
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
                     refreshEnd: {() -> () in
                        self.tableView.reloadData()
                        self.refreshControl.endRefreshing()
        })
    }
    
    func refreshBegin(newtext:String, refreshEnd: @escaping () -> Void) {
        DispatchQueue.global().async {
            self.giphyService.returnTrendingGifs(completion: {(isSuccess:Bool, result:[GifModel])in
                self.trendedGifsAreLoadedCompletionHandler(isSuccess,result)})
                refreshEnd()
        }
    }

    private func createAlert(title: String, message: String){

        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: ""), style: UIAlertActionStyle.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
                self.prepareView()
        }))
        self.present(alert,animated: true, completion: nil)
    }

}

