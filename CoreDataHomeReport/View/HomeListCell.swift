//
//  HomeListCell.swift
//  CoreDataHomeReport
//
//  Created by Igor Korshunov on 27/12/2019.
//  Copyright © 2019 Igor Korshunov. All rights reserved.
//

import UIKit

class HomeListCell: UITableViewCell {
    
    
    @IBOutlet weak var homeImageView: UIImageView!
    
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var bedLabel: UILabel!
    @IBOutlet weak var bathLabel: UILabel!
    @IBOutlet weak var sqftLabel: UILabel!
    
    weak var home: Home? {
        didSet{
            if let home = home {
                cityLabel.text = home.city
                categoryLabel.text = home.homeType
                bedLabel.text = String(home.bed)
                bathLabel.text = String(home.bath)
                sqftLabel.text = String(home.sqft)
                priceLabel.text = home.price.currencyFormatter
                
                if let data = home.image {
                    let image = UIImage(data: data)
                    imageView?.image = image
                }
            }
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
