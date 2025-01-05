//
//  FileBrowserVc.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import UIKit

protocol FileBrowserView: AnyObject {
    var node: Node { get }
    
    var visibleIndexPaths: [IndexPath] { get }
    
    func reloadData()
    func insertRows(
        at indexPath: IndexPath,
        count: Int
    )
    func updateAccessoryViewForRows(at indexPaths: [IndexPath])
    
    func deselectCell(at indexPath: IndexPath)
}

protocol FileBrowserViewInput {
    func cellCount() -> Int
    func cellVm(at indexPath: IndexPath) -> EntryCellVm
}

protocol FileBrowserViewOutput {
    func onInit()
    func onDeinit()
    func onViewLoaded()
    func onViewAppeared()
    
    func onRightButtonItemTap()
    
    func onCellTap(at indexPath: IndexPath)
    func onCellAccessoryTap(at indexPath: IndexPath)
    
    func shouldHighlightRow(at indexPath: IndexPath) -> Bool
    
    func willDisplayCell(at indexPath: IndexPath)
}

class FileBrowserVc: UIViewController {

    var input: FileBrowserViewInput!
    var output: FileBrowserViewOutput!
    
    @IBOutlet private weak var tableView: UITableView!
    
    deinit {
        output.onDeinit()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        output.onViewAppeared()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(EntryCell.self, forCellReuseIdentifier: "Cell")
        
        output.onViewLoaded()
    }
    
    @IBAction func onRightButtonItemTap(_ sender: Any) {
        output.onRightButtonItemTap()
    }
}

extension FileBrowserVc: FileBrowserView {
    var node: Node { NodeImpl(vc: self) }
    
    var visibleIndexPaths: [IndexPath] {
        tableView?.indexPathsForVisibleRows ?? []
    }
    
    func configureCellAccessoryView(
        at indexPath: IndexPath,
        with accessoryVm: AccessoryVm
    ) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        
        configureAccessoryView(
            cell: cell,
            at: indexPath,
            with: accessoryVm
        )
    }
    
    func reloadData() {
        tableView.reloadData()
    }
    
    func insertRows(
        at indexPath: IndexPath,
        count: Int
    ) {
        tableView.performBatchUpdates { [weak self] in
            guard let self else { return }

            tableView.insertRows(
                at: (0 ..< count).map {
                    IndexPath(row: indexPath.row + $0, section: 0)
                },
                with: .automatic
            )
        }
    }
    
    func deselectCell(at indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    private func configureCell(
        cell: UITableViewCell,
        at indexPath: IndexPath,
        with cellVm: EntryCellVm
    ) {
        cell.imageView?.image = UIImage.init(systemName: cellVm.iconName)
        cell.textLabel?.text = cellVm.text
        cell.selectedBackgroundView = {
            let backgroundView = UIView(frame: cell.contentView.bounds)
            backgroundView.backgroundColor = cell.tintColor
            return backgroundView
        }()
        cell.textLabel?.highlightedTextColor = .white

        configureAccessoryView(
            cell: cell,
            at: indexPath,
            with: cellVm.accessoryVm
        )
    }
    
    @objc private func onCellAccessoryTap(_ sender: UIView) {
        output.onCellAccessoryTap(at: IndexPath(row: sender.tag, section: 0))
    }
    
    private func configureAccessoryView(
        cell: UITableViewCell,
        at indexPath: IndexPath,
        with accessoryVm: AccessoryVm
    ) {
        switch accessoryVm {
        case .spinner:
            cell.accessoryView = {
                let spinner = UIActivityIndicatorView(style: .medium)
                spinner.startAnimating()
                return spinner
            }()
            
        case .image(let systemName):
            cell.accessoryView = UIImageView(image: UIImage(systemName: systemName))
            
        case .imageButton(let systemName):
            cell.accessoryView = {
                let button = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
                
                let image = UIImage(systemName: systemName)
                button.setImage(image, for: .normal)
                button.addTarget(self, action: #selector(onCellAccessoryTap(_:)), for: .touchUpInside)
                button.tag = indexPath.row
                
                return button
            }()
        }
    }
    
    private func setDownloadingAccessoryView(cell: UITableViewCell) {
        cell.accessoryView = {
            let spinner = UIActivityIndicatorView(style: .medium)
            spinner.startAnimating()
            return spinner
        }()
    }
    
    func updateAccessoryViewForRows(at indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            guard let cell = tableView.cellForRow(at: indexPath) else { return }
            
            let cellVm = input.cellVm(at: indexPath).accessoryVm
            
            configureAccessoryView(
                cell: cell,
                at: indexPath,
                with: cellVm
            )
        }
    }
}

extension FileBrowserVc: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        input.cellCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cellVm = input.cellVm(at: indexPath)
        configureCell(cell: cell, at: indexPath, with: cellVm)

        output.willDisplayCell(at: indexPath)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        output.onCellTap(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        output.shouldHighlightRow(at: indexPath)
    }
}
