//
//  EntryCell.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import UIKit

final class EntryCell: UITableViewCell {
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        imageView?.tintColor = highlighted ? .white : .tintColor
        accessoryView?.tintColor = highlighted ? .white : .tintColor
    }
}
