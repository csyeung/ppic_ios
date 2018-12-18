//
// Created by Jonathan YEUNG on 2018/07/11.
// ppic_ios

// 

import UIKit

final class DirectMessageListController : UIViewController {
    @IBOutlet weak var tableView : UITableView!
    
    private let viewModel = DirectMessageListViewModel()
    private let cellHeight : CGFloat = 75

    enum TargetPage : TransitionInformation {
        case chatDetails(picId: String)
        case dismiss
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupTableView()
        bindData()
        viewModel.removeBadge()
    }
}

// MARK: Main
extension DirectMessageListController {
    private func setupNavigationBar() {
        guard let navigationBar = self.navigationController?.navigationBar else {
            return
        }

        navigationBar.barTintColor = UIColor.white
        navigationBar.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 17, weight: .regular)
        ]
        
        let backButton = UIBarButtonItem(image: UIImage(named: "btn_back_white"), style: .plain, target: self, action: #selector(doBack))
        navigationBar.topItem?.leftBarButtonItem = backButton
    }
    
    private func setupTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        // 登録
        self.tableView.register(UINib(nibName: "DirectMessageListCell", bundle: nil), forCellReuseIdentifier: "DirectMessageListCell")
        
        // 余った部分の線を消す
        self.tableView.tableFooterView = UIView()
    }
    
    private func bindData() {
        self.viewModel.observe { [weak self] chatList in
            AnalyticsEventUtility.shared.send(name: .openChatList, picId: nil, picOwnerUid: nil, optionalParameters: [
                "total_count": chatList.data.count,
                "unread_count": chatList.data.filter({ (data) -> Bool in
                    guard let unread = data.unread else {
                        return false
                    }
                    
                    return unread
                }).count
            ])

            self?.tableView.reloadData()
        }
    }
}

// MARK: ボタンアクション
extension DirectMessageListController {
    @IBAction func doBack() {
        self.transitionDelegate?.viewController(self, needsTransitionWith: TargetPage.dismiss)
    }
}

// MARK: UITableViewDelegate
extension DirectMessageListController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let row = indexPath.row
        let message = viewModel.messageThreads[row]
        
        if let picId = message.picId {
            self.transitionDelegate?.viewController(self, needsTransitionWith: TargetPage.chatDetails(picId: picId))
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
}

// MARK: UITableViewDataSource
extension DirectMessageListController : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.messageThreads.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let message = viewModel.messageThreads[row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DirectMessageListCell", for: indexPath) as! DirectMessageListCell
        cell.configure(data: message)
        return cell
    }
}
