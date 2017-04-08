import UIKit

class NewPostController: UIViewController, UINavigationControllerDelegate {

    @IBOutlet weak var titlePostTxt: UITextField!
    @IBOutlet weak var textPostTxt: UITextField!
    @IBOutlet weak var imagePost: UIImageView!
    
    var isReadyToPublish: Bool = false
    var imageCaptured: UIImage! {
        didSet {
            imagePost.image = imageCaptured
        }
    }
    
    var client: MSClient!
    let tableName = "noticia"
    let azureAppServicesEndpoint = "https://boot4camplabpaco.azurewebsites.net"
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAzureAppService()
    }
    
    // MARK: - User actions
    @IBAction func takePhoto(_ sender: Any) {
        self.present(pushAlertCameraLibrary(), animated: true, completion: nil)
    }
    @IBAction func publishAction(_ sender: Any) {
        isReadyToPublish = (sender as! UISwitch).isOn
    }

    @IBAction func savePostInCloud(_ sender: Any) {
        guard let postImage = imagePost.image else {
            newPostInService(titlePostTxt.text!, textPostTxt.text!, isReadyToPublish, imgData: nil)
            return
        }
        newPostInService(titlePostTxt.text!, textPostTxt.text!, isReadyToPublish, imgData: UIImageJPEGRepresentation(postImage, 0.50))
    }

    // MARK: - Camera functions
    internal func pushAlertCameraLibrary() -> UIAlertController {
        let actionSheet = UIAlertController(title: NSLocalizedString("Selecciona la fuente de la imagen", comment: ""), message: NSLocalizedString("", comment: ""), preferredStyle: .actionSheet)
        
        let libraryBtn = UIAlertAction(title: NSLocalizedString("Usar la libreria", comment: ""), style: .default) { (action) in
            self.takePictureFromCameraOrLibrary(.photoLibrary)
            
        }
        let cameraBtn = UIAlertAction(title: NSLocalizedString("Usar la camara", comment: ""), style: .default) { (action) in
            self.takePictureFromCameraOrLibrary(.camera)
            
        }
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
        
        actionSheet.addAction(libraryBtn)
        actionSheet.addAction(cameraBtn)
        actionSheet.addAction(cancel)
        
        return actionSheet
    }
    
    internal func takePictureFromCameraOrLibrary(_ source: UIImagePickerControllerSourceType) {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        switch source {
        case .camera:
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
                picker.sourceType = UIImagePickerControllerSourceType.camera
            } else {
                return
            }
        case .photoLibrary:
            picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        case .savedPhotosAlbum:
            picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        }
        
        self.present(picker, animated: true, completion: nil)
    }

}

// MARK: - Delegates

// UIImagePickerControllerDelegate
extension NewPostController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imageCaptured = (info[UIImagePickerControllerOriginalImage] as? UIImage)!
        self.dismiss(animated: false, completion: {
        })
    }
    
}

// MARK: - Appservice methods
extension NewPostController {
    
    func setupAzureAppService() {
        client = MSClient(applicationURLString: azureAppServicesEndpoint)
    }
    
    func uploadDataPost(data: Data, completionHandler: @escaping (String?) -> Void) {
        // Credenciales
        let credential = AZSStorageCredentials(accountName: "pacoboot4", accountKey: "/XJTFKPk/hgjK7AAnUreXXqUFOqmM3BHLgbrIOI1IRUIvqFFRK+ujVzRUxVI8qGX0+lWLRupa64KUUNA/ZBjyg==")
        
        do {
            let account = try AZSCloudStorageAccount(credentials: credential, useHttps: true)
            let blobClient = account.getBlobClient()
            let container = blobClient?.containerReference(fromName: "fotos")
            let blobBlock = container?.blockBlobReference(fromName: String("\(UUID().uuidString).jpg"))
            blobBlock?.upload(from: data, completionHandler: { (error) in
                if (error == nil) {
                    completionHandler(blobBlock?.blobName)
                } else {
                    completionHandler(nil)
                }
            })
        } catch {
            
        }
    }
    
    func newPostInService(_ title: String, _ description: String, _ status: Bool, imgData: Data?) {
        let posts = client.table(withName: tableName)
        
        posts.insert([ "titulo" : title, "texto" : description, "publicada" : status ]) { (result, error) in
            if let _ = error {
                print("\(error)")
                return
            }
            if let _ = imgData {
                self.uploadDataPost(data: imgData!, completionHandler: { (blobname) in
                    let item = [ "id" : (result?["id"] as! String), "foto" : blobname ]
                    posts.update(item, completion: { (result, error) in
                        if let _ = error {
                            print("\(error?.localizedDescription)")
                        }
                        print("\(result)")
                    })
                })
            }
        }
    }
    
}
