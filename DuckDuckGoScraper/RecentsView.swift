//
//  RecentsView.swift
//  DuckDuckGoScraper
//
//  Created by Alejandro Silva Fernandez on 09/09/2017.
//  Copyright © 2017 Alex Silva. All rights reserved.
//

import UIKit

protocol RecentsDelegate {
    func removeAll()
}

class RecentsView: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var removeAllButton: UIButton!

    var delegate: RecentsDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)

        customInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        customInit()
    }

    func customInit() {
        Bundle.main.loadNibNamed("RecentsView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.layer.borderColor = UIColor.lightGray.cgColor
        contentView.layer.borderWidth = 1.0
        contentView.autoresizingMask = [ .flexibleWidth, .flexibleHeight ]
    }

    @IBAction func removeButtonTouched(sender: AnyObject) {
        delegate?.removeAll()
    }
}
