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
        }
    }

    // MARK: - Utils
    func syncViewWithModel() {
        
        titleTxt.text = (model["titulo"] as! String)
        postTxt.text = (model["texto"] as! String)
        //imagePost.image = UIImage(contentsOfFile: (model["foto"] as! String))
    }
    
    

}
