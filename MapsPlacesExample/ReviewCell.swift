//
//  ReviewCell.swift
//  MapsPlacesExample
//
//  Created by Ty Daniels on 4/4/17.
//  Copyright © 2017 Ty Daniels Dev. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage
import Stevia

class ReviewCell: UITableViewCell {
    
    var mainBackgroundView = UIView()
    var avatar: UIImageView = UIImageView()
    var tappableName = UILabel()
    var commentTextView = UITextView()
    var selectBtn = UIButton()
    
    var avatarString: String? = ""
    var name: String? = ""
    var commentString: String? = ""
    
    var commentItem: GoogleRating? {
        didSet{
            if let comment = self.commentItem?.review {
                if let userImg = commentItem?.usrPhotoString {
                    self.avatar.sd_setImage(with: URL(string: userImg),
                                            placeholderImage: UIImage(),
                                            options: [.refreshCached]
                    )
                }
                
                self.tappableName.text = String(format: "%.1f", (commentItem?.rating) ?? 0.0)
                self.commentTextView.text = comment
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setupView()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
    }
    
    func setupView() {
        
        self.contentView.sv(mainBackgroundView)
        mainBackgroundView.sv(avatar, tappableName, selectBtn, commentTextView)
        
        self.contentView.layout(
            0,
            |-mainBackgroundView-| ~ self.contentView.frame.height
        )
        
        mainBackgroundView.layout(
            10,
            |-avatar-tappableName-|,
            -10,
            |-44-commentTextView-| ~ 40
            
        )
        
        mainBackgroundView.backgroundColor = UIColor.white
        
        avatar.backgroundColor = UIColor.lightGray
        avatar.height(29)
        avatar.width(29)
        avatar.layer.cornerRadius = 14.5
        avatar.layer.shadowColor = UIColor.black.cgColor
        avatar.layer.shadowOpacity = 1
        avatar.layer.shadowOffset = .zero
        avatar.layer.shadowRadius = 10
        
        tappableName.height(20)
        tappableName.top(-10)
        tappableName.font = UIFont.boldSystemFont(ofSize: 22)
        tappableName.backgroundColor = UIColor.clear
        tappableName.textColor = UIColor.black
        
        commentTextView.backgroundColor = UIColor.clear
        commentTextView.isUserInteractionEnabled = false
        commentTextView.textColor = UIColor.lightGray
        commentTextView.font = UIFont.boldSystemFont(ofSize: 14)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        tappableName.text = ""
        avatar.image = nil
        avatar.isHidden = false
        avatar.sd_cancelCurrentImageLoad()
    }
}

