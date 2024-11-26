//
//  ViewController.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import UIKit
import AWSS3
import AWSSDKIdentity
import ClientRuntime

class FileBrowserViewController: UIViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    
    var path: String = ""
    
    var repositoryFactory: BucketRepositoryFactory = BucketRepositoryFactoryImpl.shared
    lazy var repository: BucketRepository = try! repositoryFactory.createBucketRepository()!
    
    var pageIterator: EntryPageSequence.AsyncIterator? = nil
    
    var entries: [Entry] = []
    var currentTask: Task<Void, Never>? = nil
    
    var hasLoaded = false
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        subscribe()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        subscribe()
    }
    
    deinit {
        unsubscribe()
    }
    
    private func subscribe() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(willEnterForeground(_:)),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
    
    private func unsubscribe() {
        NotificationCenter.default.removeObserver(
            self,
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
    
    private func syncEntriesLocally() {
        entries = entries.map {
            Entry(
                name: $0.name,
                path: $0.path,
                localUrl: $0.localUrl,
                isFolder: $0.isFolder,
                isDownloaded: FileManager.default.fileExists(atPath: $0.localUrl.path(percentEncoded: false))
            )
        }
        tableView?.visibleCells.forEach { cell in
            guard let indexPath = tableView.indexPath(for: cell),
                  indexPath.row < entries.count else { return }
            updateAccessoryView(cell: cell, indexPath: indexPath, entry: entries[indexPath.row])
        }

    }
    
    @objc private func willEnterForeground(_ notification: Notification) {
        syncEntriesLocally()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        syncEntriesLocally()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(EntryCell.self, forCellReuseIdentifier: "Cell")
        
        let result = repository.getContent(path: path)
        pageIterator = result.makeAsyncIterator()
        
        loadMore()
    }
    
    private func loadMore() {
        if (hasLoaded || currentTask != nil) { return }
        
        currentTask = Task { [weak self] in
            guard let self else {
                return
            }
            
            var page: [Entry]? = nil
            
            do { page = try await pageIterator?.next() }
            catch { print(error) }
            
            await MainActor.run { [weak self] in
                guard let self else { return }
                
                currentTask = nil
                
                guard let page,
                      page.count > 0
                else {
                    hasLoaded = true
                    return
                }
                
                let firstIndex = entries.count
                entries.append(contentsOf: page)
                
                guard firstIndex > 0 else {
                    tableView.reloadData()
                    return
                }

                tableView.performBatchUpdates { [weak self] in
                    guard let self else { return }

                    tableView.insertRows(
                        at: (firstIndex ..< entries.count).map {
                            IndexPath(row: $0, section: 0)
                        },
                        with: .automatic
                    )
                }
            }
        }
    }
    
    @IBAction func didTapSettings(_ sender: Any) {
        guard let vc = storyboard?.instantiateViewController(identifier: "SettingsViewController") else { return }
        
        let navVC = UINavigationController(rootViewController: vc)
        navVC.modalPresentationStyle = .fullScreen
        navVC.modalTransitionStyle = .flipHorizontal
        
        showDetailViewController(navVC, sender: sender)
    }
}

extension FileBrowserViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        entries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (indexPath.row != 0 && indexPath.row == entries.count - 1) {
            loadMore()
        }

        let entry = entries[indexPath.row]
        
        cell.imageView?.image = UIImage.init(systemName: entry.isFolder ? "folder" : "doc")
        cell.textLabel?.text = entry.name
        cell.selectedBackgroundView = {
            let backgroundView = UIView(frame: cell.contentView.bounds)
            backgroundView.backgroundColor = cell.tintColor
            return backgroundView
        }()
        cell.textLabel?.highlightedTextColor = .white
        
        updateAccessoryView(cell: cell, indexPath: indexPath, entry: entry)
    }
    
    private func updateAccessoryView(cell: UITableViewCell, indexPath: IndexPath, entry: Entry) {
        if entry.isFolder {
            cell.accessoryView = UIImageView(image: UIImage(systemName: "chevron.forward"))
        } else if repository.isDownloadingFile(path: entry.path) {
            setDownloadingAccessoryView(cell: cell)
        } else {
            cell.accessoryView = {
                let button = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
                
                let image = UIImage(
                    systemName: entry.isDownloaded ? "arrow.clockwise.circle" : "arrow.down.circle"
                )
                button.setImage(image, for: .normal)
                button.addTarget(self, action: #selector(onDownloadAction), for: .touchUpInside)
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
    
    @objc private func onDownloadAction(_ sender: UIView) {
        let index = sender.tag
        
        guard entries.indices.contains(index) else { return }
        
        let entry = entries[sender.tag]
        let indexPath = IndexPath(row: index, section: 0)

        guard let cell = tableView.cellForRow(at: indexPath) else { return }

        setDownloadingAccessoryView(cell: cell)
        
        Task { [weak self] in
            let entry = try? await self?.repository.downloadFile(path: entry.path)
            
            await MainActor.run { [weak self] in
                if let entry {
                    self?.entries[index] = entry
                }
                
                guard let self,
                      let cell = self.tableView.cellForRow(at: indexPath)
                else { return }
                                    
                updateAccessoryView(cell: cell, indexPath: indexPath, entry: entry ?? entries[index])
            }
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let entry = entries[indexPath.row]

        if entry.isFolder {
            let vc = storyboard?.instantiateViewController(withIdentifier: "FileBrowserViewController") as! FileBrowserViewController
            vc.title = entry.name
            vc.path = entry.path
            
            show(vc, sender: tableView.cellForRow(at: indexPath))
        } else if entry.isDownloaded {
            let urlString = entry.localUrl.absoluteString.replacingOccurrences(of: "file://", with: "shareddocuments://")
            
            guard let url = URL(string: urlString) else { return }
            
            UIApplication.shared.open(url)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        let entry = entries[indexPath.row]
        
        return entry.isFolder || entry.isDownloaded
    }
}

final class EntryCell: UITableViewCell {
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        imageView?.tintColor = highlighted ? .white : .tintColor
        accessoryView?.tintColor = highlighted ? .white : .tintColor
    }
}
