import UIKit

class MainTimeLine: UITableViewController {

    var model: [Any] = []
    let cellIdentier = "POSTSCELL"
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.refreshControl?.addTarget(self, action: #selector(handleRefresh(_:)), for: UIControlEvents.valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        pullModel()
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if model.isEmpty {
            return 0
        }
        return model.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentier, for: indexPath)

        //cell.textLabel?.text = model[indexPath.row]
        let item = model[indexPath.row] as! Dictionary<String, Any>
        cell.textLabel?.text = item["titulo"] as! String

        return cell
    }
    
    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "ShowRatingPost", sender: indexPath)
    }
    
    // MARK: - Utils
    func pullModel() {
        
        let client = MSClient(applicationURLString: "https://boot4camplabpaco.azurewebsites.net")
        client.invokeAPI("GetAllPublishPosts", body: nil, httpMethod: "GET", parameters: nil, headers: nil) { (result, response, error) in
            if let _ = error {
                print("\(error?.localizedDescription)")
            }
            print("\(result)")
            self.model = result as! [Any]
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }

    }
    
    func handleRefresh(_ refreshControl: UIRefreshControl) {
        refreshControl.endRefreshing()
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "ShowRatingPost" {
            let vc = segue.destination as! PostReview
            let indexpath = sender as! IndexPath
            let item = model[indexpath.row] as! Dictionary<String, Any>

            vc.model = item
            // aqui pasamos el item selecionado
        }
    }


}
