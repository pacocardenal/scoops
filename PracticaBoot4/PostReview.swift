//
//  PostReview.swift
//  PracticaBoot4
//
//  Created by Juan Antonio Martin Noguera on 23/03/2017.
//  Copyright © 2017 COM. All rights reserved.
//

import UIKit

class PostReview: UIViewController {

    @IBOutlet weak var rateSlider: UISlider!
    @IBOutlet weak var imagePost: UIImageView!
    @IBOutlet weak var postTxt: UITextField!
    @IBOutlet weak var titleTxt: UITextField!
    @IBOutlet weak var sliderValueLabel: UILabel!
    @IBOutlet weak var averageLabel: UILabel!
    
    var model: Dictionary<String, Any>!
    let stepValue: Float = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        syncViewWithModel()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func rateAction(_ sender: Any) {
        let newStep = roundf(rateSlider.value / self.stepValue)
        
        // Convert "steps" back to the context of the sliders values.
        self.rateSlider.value = newStep * self.stepValue;
        print("\((sender as! UISlider).value)")
        self.sliderValueLabel.text = "\(Int(self.rateSlider.value))"
    }

    @IBAction func ratePost(_ sender: Any) {
        print(rateSlider.value)
        let client = MSClient(applicationURLString: "https://boot4camplabpaco.azurewebsites.net")
        let posts = client.table(withName: "valoracion")
        let noticiaId = (model["id"] as! String)
        let nota = self.sliderValueLabel.text
        
        posts.insert([ "noticiaId" : noticiaId, "nota" : nota ]) { (result, error) in
            if let _ = error {
                print("\(error)")
                return
            }
            print(result!)
            self.navigationController?.popViewController(animated: true)
        }
    }

    // MARK: - Utils
    func syncViewWithModel() {
        
        titleTxt.text = (model["titulo"] as! String)
        postTxt.text = (model["texto"] as! String)
        //imagePost.image = UIImage(contentsOfFile: (model["foto"] as! String))
        syncAverage()
        syncPhoto()
    }
    
    func syncAverage() {
        let noticiaId = (model["id"] as! String)
        let paramsToCloud = ["noticia" : noticiaId]
        let client = MSClient(applicationURLString: "https://boot4camplabpaco.azurewebsites.net")
        //let reviews = client.table(withName: "valoracion")
        
        client.invokeAPI("GetReviewsAverage", body: nil, httpMethod: "GET", parameters: paramsToCloud, headers: nil) { (result, response, error) in
            if let _ = error {
                print("\(error?.localizedDescription)")
            }
            print("\(result)")
            var model: [Any] = []
            model = result as! [Any]
            let averageModel = model[0] as! [String : AnyObject]
            
            if let average = averageModel["media"] as? NSNumber {
                let averageDouble = Double(average)
                self.averageLabel.text = "Avg.: \(String(format: "%.2f", averageDouble))"
            }
            
        }
    }
    
    func syncPhoto() {
        let baseUrlString = "https://pacoboot4.blob.core.windows.net/fotos/"
        if let urlFotoString = (model["foto"] as? String) {
            let linkUrlString = baseUrlString + urlFotoString
            imagePost.downloadedFrom(link: linkUrlString)
        }
    }

}

extension UIImageView {
    func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { () -> Void in
                self.image = image
            }
            }.resume()
    }
    func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode)
    }
}
