import UIKit

class AuthorPostList: UITableViewController {

    let cellIdentifier = "POSTAUTOR"
    
    var model: [Any] = []
    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        //cell.textLabel?.text = model[indexPath.row]
        let item = model[indexPath.row] as! Dictionary<String, Any>
        cell.textLabel?.text = (item["titulo"] as! String)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let publish = UITableViewRowAction(style: .normal, title: "Publicar") { (action, indexPath) in
            let item = self.model[indexPath.row] as! Dictionary<String, Any>
            let paramsToCloud = ["id" : item["id"], "estado" : true]
            
            let client = MSClient(applicationURLString: "https://boot4camplabpaco.azurewebsites.net")
            client.invokeAPI("publishPosts", body: nil, httpMethod: "PUT", parameters: paramsToCloud, headers: nil) { (result, response, error) in
                if let _ = error {
                    print("\(error?.localizedDescription)")
                    return
                }
                self.pullModel()
            }
        }
        publish.backgroundColor = UIColor.green
        let deleteRow = UITableViewRowAction(style: .destructive, title: "Eliminar") { (action, indexPath) in
            // codigo para eliminar
        }
        return [publish, deleteRow]
    }

    // MARK: - Utils
    func pullModel() {
        
        let client = MSClient(applicationURLString: "https://boot4camplabpaco.azurewebsites.net")
        client.invokeAPI("GetAllMyPosts", body: nil, httpMethod: "GET", parameters: nil, headers: nil) { (result, response, error) in
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
   
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
