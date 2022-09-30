import AVFoundation
import SwiftUI
import SwiftUISugar

#if targetEnvironment(simulator)
extension CameraView {
    public class Controller: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate{
        var delegate: Coordinator?
    }
}

extension CameraView.Controller {
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
}

#endif
