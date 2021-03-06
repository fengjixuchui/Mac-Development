//
//  KLanguageTableVC.swift
//  KLrcCamera
//
//  Created by kongyulu on 2020/9/9.
//

import UIKit


class KLanguageCell: UITableViewCell {

    public var language: OSSVoiceEnum? {
        didSet {
            imageView?.image = language?.flag
            textLabel?.text = language?.title
            detailTextLabel?.text = language?.rawValue
        }
    }

    // MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        imageView?.contentMode = .scaleAspectFit
        imageView?.layer.masksToBounds = true
        imageView?.clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        textLabel?.text = ""
        detailTextLabel?.text = ""
        imageView?.image = nil
    }

}

class KLanguageTableVC:  UITableViewController {
    
    // MARK: - Variables
    
    private let speechKit = OSSSpeech.shared
    
    private lazy var microphoneButton: UIBarButtonItem = {
        var micImage: UIImage?
        if #available(iOS 13.0, *) {
            micImage = UIImage(systemName: "mic.fill")?.withRenderingMode(.alwaysTemplate)
        } else {
            micImage = UIImage(named: "oss-microphone-icon")?.withRenderingMode(.alwaysTemplate)
        }
        let button = UIBarButtonItem(image: micImage, style: .plain, target: self, action: #selector(recordVoice))
        button.tintColor = .black
        button.accessibilityIdentifier = "OSSSpeechKitMicButton"
        return button
    }()
    
    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Languages"
        tableView.accessibilityIdentifier = "OSSSpeechKitLanguageTableView"
        speechKit.delegate = self
        navigationItem.rightBarButtonItem = microphoneButton
        tableView.register(KLanguageCell.self,
                           forCellReuseIdentifier: KLanguageCell.reuseIdentifier)
    }
    
    // MARK: - Voice Recording
    
    @objc func recordVoice() {
        if microphoneButton.tintColor == .red {
            speechKit.endVoiceRecording()
            return
        }
        microphoneButton.tintColor = .red
        speechKit.recordVoice()
    }
}

extension KLanguageTableVC {

    // MARK: - Table View Data Source and Delegate

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return OSSVoiceEnum.allCases.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: KLanguageCell.reuseIdentifier,
                                                       for: indexPath) as? KLanguageCell else {
            return UITableViewCell(style: .subtitle, reuseIdentifier: UITableViewCell.reuseIdentifier)
        }
        cell.language = OSSVoiceEnum.allCases[indexPath.row]
        cell.isAccessibilityElement = true
        cell.accessibilityIdentifier = "OSSLanguageCell_\(indexPath.section)_\(indexPath.row)"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // NOTE: Must set the voice before requesting speech. This can be set once.
        speechKit.voice = OSSVoice(quality: .enhanced, language: OSSVoiceEnum.allCases[indexPath.item])
        speechKit.utterance?.rate = 0.45
        // Test attributed string vs normal string
        if indexPath.item % 2 == 0 {
            speechKit.speakText(OSSVoiceEnum.allCases[indexPath.item].demoMessage)
        } else {
            let attributedString = NSAttributedString(string: OSSVoiceEnum.allCases[indexPath.item].demoMessage)
            speechKit.speakAttributedText(attributedText: attributedString)
        }
    }
}

extension KLanguageTableVC: OSSSpeechDelegate {
    
    func didCompleteTranslation(withText text: String) {
        print("Translation completed: \(text)")
    }
    
    func didFailToProcessRequest(withError error: Error?) {
        guard let err = error else {
            print("Error with the request but the error returned is nil")
            return
        }
        print("Error with the request: \(err)")
    }
    
    func authorizationToMicrophone(withAuthentication type: OSSSpeechKitAuthorizationStatus) {
        print("Authorization status has returned: \(type.message).")
    }
    
    func didFailToCommenceSpeechRecording() {
        print("Failed to record speech.")
    }
    
    func didFinishListening(withText text: String) {
        weak var weakSelf = self
        OperationQueue.main.addOperation {
            weakSelf?.microphoneButton.tintColor = .black
            weakSelf?.speechKit.speakText(text)
        }
    }
}

extension UIView {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}
