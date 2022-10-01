import AVFoundation
import SwiftUI
import SwiftUISugar

#if targetEnvironment(simulator)
extension CameraView {
    public class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
        var config: CameraConfiguration
        var delegate: Coordinator?
        
        init(config: CameraConfiguration = CameraConfiguration(), delegate: Coordinator? = nil) {
            self.config = config
            self.delegate = delegate
            super.init(nibName: nil, bundle: nil)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

extension CameraView.CameraViewController {
    override public func loadView() {
        view = UIView()
        view.isUserInteractionEnabled = true
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        
        label.text = "You're running in the simulator, which means the camera isn't available."
        label.textAlignment = .center
        
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 50
        stackView.addArrangedSubview(label)
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    func configUpdated(with config: CameraConfiguration) {
    }
}

#endif
