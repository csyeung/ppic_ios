//
// Created by Jonathan YEUNG on 2018/07/09.
// ppic_ios

// 

import UIKit
import JSQMessagesViewController
import UserNotifications

final class DirectMessageController: JSQMessagesViewController {
    private(set) var viewModel = DirectMessageViewModel()

    var incomingBubble: JSQMessagesBubbleImage!
    var outgoingBubble: JSQMessagesBubbleImage!

    var picId = ""

    private var picOwnerUid: String?

    // TODO: ViewModelを介したい
    private let userUsecase = UserUsecase()
    private let picUsecase = PicUsecase()
    private var avatarImageCache = Dictionary<String, JSQMessagesAvatarImage>()
    private var isFirstLoad = true

    // 定数
    let avatarSize: CGSize = CGSize(width: 40, height: 40)

    enum TargetPage: TransitionInformation {
        case profile(uid: String)
        case picDetail(id: String)
        case dismiss
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigation()
        setupMessageView()
        setupNotifications()
    }

    override func viewWillAppear(_ animated: Bool) {
        // https://qiita.com/ichiroc@github/items/b3c6154ac4551bcf1f48
        // 表示時に最下部に移動する
        super.viewWillAppear(animated)
        scrollToBottom()
    }
}

// MARK: Main function
extension DirectMessageController {
    private func setupNavigation() {
        let backButton = UIBarButtonItem(image: UIImage(named: "btn_back_white"), style: .plain, target: self, action: #selector(onBack))
        navigationItem.leftBarButtonItem = backButton

        let buttonImage = UIImage(named: "btn_more")?.withRenderingMode(.alwaysOriginal)
        let moreButton = UIBarButtonItem(image: buttonImage, style: .plain, target: self, action: #selector(onMore))
        navigationItem.rightBarButtonItem = moreButton

        // TODO: ViewModelに移す
        self.senderId = ""
        userUsecase.getMyProfile { (user) in
            self.senderId = user.uid
        }

        // TODO: ViewModelに移す
        self.senderDisplayName = ""
        picUsecase.get(id: picId) { (pic) in
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(DirectMessageController.tappedNavigationTitle(gesture:)))

            let label = UILabel()
            label.text = "\(pic.title) \(AppUtility.makeDMCountString(count: pic.participantsNumber))"
            label.sizeToFit()
            label.isUserInteractionEnabled = true
            label.addGestureRecognizer(tapGesture)

            self.navigationItem.titleView = label

            self.picOwnerUid = pic.owner?.uid
            AnalyticsEventUtility.shared.send(name: .openChatMessage, picId: self.picId, picOwnerUid: self.picOwnerUid)
        }
    }

    @objc private func tappedNavigationTitle(gesture: UIGestureRecognizer) {
        self.transitionDelegate?.viewController(self, needsTransitionWith: TargetPage.picDetail(id: picId))
    }

    private func setupMessageView() {
        // 文言の日本語設定
        self.inputToolbar.contentView.textView.placeHolder = "メッセージを作成"
        self.inputToolbar.contentView.textView.returnKeyType = .done

        // メッセージの見た目設定
        incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImage(with: UIColor.lightGray)
        outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())

        // アバターサイズの設定
        collectionView?.collectionViewLayout.incomingAvatarViewSize = avatarSize
        collectionView?.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero

        // 添付ファイル機能を隠す
        self.inputToolbar.contentView.leftBarButtonItem = nil

        // その他の設定
        collectionView?.collectionViewLayout.springinessEnabled = false
        // スクロール時に最新メッセージに移動する　https://qiita.com/ryotakodaira/items/b234d1d51ae6b1110e8b
        automaticallyScrollsToMostRecentMessage = true

        // データ整理
        viewModel.observe(picId: picId) { () in
            self.collectionView?.reloadData()
            self.collectionView?.setNeedsLayout()
            self.scrollToBottom()
        }
    }

    @objc private func onBack() {
        viewModel.read(picId: picId)

        self.transitionDelegate?.viewController(self, needsTransitionWith: TargetPage.dismiss)
    }

    @objc private func onMore() {
        self.transitionDelegate?.viewController(self, needsTransitionWith: TargetPage.picDetail(id: picId))
    }

    private func setupNotifications() {
        if #available(iOS 10.0, *) {
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                    options: authOptions,
                    completionHandler: { _, _ in })
        } else {
            // TODO: 以下をAppDelegateで行っている。どちらでやるのが正しい？
//            let settings: UIUserNotificationSettings =
//                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
//            application.registerUserNotificationSettings(settings)
        }
    }

    private func scrollToBottom(){
        if !isFirstLoad{
            return
        }
        guard let collectionView = self.collectionView else {return}
        let item = self.collectionView(collectionView, numberOfItemsInSection: 0) - 1
        // 落ちる対策
        if item < 0 {
            return
        }
        print("=== idx: \(item)")
        isFirstLoad = false
        let lastItemIndex = IndexPath(item: item, section: 0)
        collectionView.scrollToItem(at: lastItemIndex,at: .bottom, animated: false)
    }
}

// MARK: JSQMessageViewController overrides
extension DirectMessageController {
    override func didPressSend(_ button: UIButton, withMessageText text: String, senderId: String, senderDisplayName: String, date: Date) {
        /**
         *  Sending a message. Your implementation of this method should do *at least* the following:
         *
         *  1. Play sound (optional)
         *  2. Add new id<JSQMessageData> object to your data source
         *  3. Call `finishSendingMessage`
         */

        viewModel.send(picId: picId, content: text) {
            self.inputToolbar.contentView.textView.text = ""
            self.inputToolbar.contentView.textView.resignFirstResponder()
//            self.finishSendingMessage(animated: true)

            AnalyticsEventUtility.shared.send(name: .completeSendMessage, picId: self.picId, picOwnerUid: self.picOwnerUid)
        }
    }

    override func didPressAccessoryButton(_ sender: UIButton) {
        self.inputToolbar.contentView!.textView!.resignFirstResponder()

        let sheet = UIAlertController(title: "Media messages", message: nil, preferredStyle: .actionSheet)

        let photoAction = UIAlertAction(title: "Send photo", style: .default) { (action) in
            /**
             *  Create fake photo
             */
            let photoItem = JSQPhotoMediaItem(image: UIImage(named: "goldengate"))
            self.addMedia(photoItem!)
        }

        let locationAction = UIAlertAction(title: "Send location", style: .default) { (action) in
            /**
             *  Add fake location
             */
            let locationItem = self.buildLocationItem()

            self.addMedia(locationItem)
        }

        let videoAction = UIAlertAction(title: "Send video", style: .default) { (action) in
            /**
             *  Add fake video
             */
            let videoItem = self.buildVideoItem()

            self.addMedia(videoItem)
        }

        let audioAction = UIAlertAction(title: "Send audio", style: .default) { (action) in
            /**
             *  Add fake audio
             */
            let audioItem = self.buildAudioItem()

            self.addMedia(audioItem)
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        sheet.addAction(photoAction)
        sheet.addAction(locationAction)
        sheet.addAction(videoAction)
        sheet.addAction(audioAction)
        sheet.addAction(cancelAction)

        self.present(sheet, animated: true, completion: nil)
    }

    func buildVideoItem() -> JSQVideoMediaItem {
        let videoURL = URL(fileURLWithPath: "file://")

        let videoItem = JSQVideoMediaItem(fileURL: videoURL, isReadyToPlay: true)

        return videoItem!
    }

    func buildAudioItem() -> JSQAudioMediaItem {
        let sample = Bundle.main.path(forResource: "jsq_messages_sample", ofType: "m4a")
        let audioData = try? Data(contentsOf: URL(fileURLWithPath: sample!))

        let audioItem = JSQAudioMediaItem(data: audioData)

        return audioItem
    }

    func buildLocationItem() -> JSQLocationMediaItem {
        let ferryBuildingInSF = CLLocation(latitude: 37.795313, longitude: -122.393757)

        let locationItem = JSQLocationMediaItem()
        locationItem.setLocation(ferryBuildingInSF) {
            self.collectionView!.reloadData()
        }

        return locationItem
    }

    func addMedia(_ media: JSQMediaItem) {
        let message = JSQMessage(senderId: self.senderId, displayName: self.senderDisplayName, media: media)
        self.viewModel.messages.append(message!)

        self.finishSendingMessage(animated: true)
    }
}

// MARK: JSQMessages DataSource
extension DirectMessageController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel.messages.count
    }

    override func collectionView(_ collectionView: JSQMessagesCollectionView, messageDataForItemAt indexPath: IndexPath) -> JSQMessageData {
        return self.viewModel.messages[indexPath.item]
    }

    override func collectionView(_ collectionView: JSQMessagesCollectionView, messageBubbleImageDataForItemAt indexPath: IndexPath) -> JSQMessageBubbleImageDataSource {

        return self.viewModel.messages[indexPath.item].senderId == self.senderId ? outgoingBubble : incomingBubble
    }

    override func collectionView(_ collectionView: JSQMessagesCollectionView, avatarImageDataForItemAt indexPath: IndexPath) -> JSQMessageAvatarImageDataSource? {
        let message = self.viewModel.messages[indexPath.item]

        if message.senderId == self.senderId {
            return nil
        }

        // https://github.com/jessesquires/JSQMessagesViewController/issues/1264#issuecomment-151726932
        // avatarImage がメモリキャッシュにあれば流用する
        if let cache = avatarImageCache[message.senderId]{
            return cache
        }
        let url = URL(string: UserEntity.thumbnailPhotoURL(uid: message.senderId))
        // https://stackoverflow.com/questions/44063314/convert-url-to-uiimage-swift3
        if let data = try? Data(contentsOf: url!) {
            let img = JSQMessagesAvatarImageFactory.avatarImage(
                    with: UIImage(data: data),
                    diameter: UInt(avatarSize.width))
            // avatarImage がキャッシュにないので、保存する
            avatarImageCache[message.senderId] = img
            return img
        }

        return nil
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell

        let tapGesture = MyTapGestureRecognizer(target: self, action: #selector(DirectMessageController.tappedAvatarImage(gesture:)))

        tapGesture.uid = self.viewModel.messages[indexPath.item].senderId
        cell.avatarImageView.isUserInteractionEnabled = true
        cell.avatarImageView.addGestureRecognizer(tapGesture)

        return cell
    }

    override func collectionView(_ collectionView: JSQMessagesCollectionView, attributedTextForCellTopLabelAt indexPath: IndexPath) -> NSAttributedString? {
        /**
         *  This logic should be consistent with what you return from `heightForCellTopLabelAtIndexPath:`
         *  The other label text delegate methods should follow a similar pattern.
         *
         *  Show a timestamp for every 3rd message
         */

        // TODO: figmaには時刻が表示されていないので、一旦コメントアウト。要、仕様確認
//        if (indexPath.item % 3 == 0) {
//            let message = self.viewModel.messages[indexPath.item]
//            return JSQMessagesTimestampFormatter.shared().attributedTimestamp(for: message.date)
//        }

        return nil
    }

    override func collectionView(_ collectionView: JSQMessagesCollectionView, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath) -> NSAttributedString? {
        let message = self.viewModel.messages[indexPath.item]

        if message.senderId == self.senderId {
            return nil
        }

        return NSAttributedString(string: message.senderDisplayName)
    }

//    override func collectionView(_ collectionView: JSQMessagesCollectionView, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout, heightForCellTopLabelAt indexPath: IndexPath) -> CGFloat {
//        /**
//         *  Each label in a cell has a `height` delegate method that corresponds to its text dataSource method
//         */
//
//        /**
//         *  This logic should be consistent with what you return from `attributedTextForCellTopLabelAtIndexPath:`
//         *  The other label height delegate methods should follow similarly
//         *
//         *  Show a timestamp for every 3rd message
//         */
//        if indexPath.item % 3 == 0 {
//            return kJSQMessagesCollectionViewCellLabelHeightDefault
//        }
//
//        return 0.0
//    }

    override func collectionView(_ collectionView: JSQMessagesCollectionView, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout, heightForMessageBubbleTopLabelAt indexPath: IndexPath) -> CGFloat {
        let currentMessage = self.viewModel.messages[indexPath.item]

        if currentMessage.senderId == self.senderId {
            return 0.0
        }

        if indexPath.item - 1 > 0 {
            let previousMessage = self.viewModel.messages[indexPath.item - 1]
            if previousMessage.senderId == currentMessage.senderId {
                return 0.0
            }
        }

        return kJSQMessagesCollectionViewCellLabelHeightDefault
    }

    @objc func tappedAvatarImage(gesture: MyTapGestureRecognizer) {
        self.transitionDelegate?.viewController(self, needsTransitionWith: TargetPage.profile(uid: gesture.uid!))
    }
}

extension DirectMessageController {
    override func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            viewModel.send(picId: picId, content: textView.text) {
                textView.resignFirstResponder()
                textView.text = ""
            }
        }

        return true
    }
}

class MyTapGestureRecognizer: UITapGestureRecognizer {
    var uid: String?
}
