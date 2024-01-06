import UIKit
import SceneKit
import MapKit
import SnapKit


class ViewController: UIViewController {
    var globeSceneView: SCNView!
    var exploreButton: UIButton!
    var appNameLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupGlobeView()
        setupAppNameLabel()
        setupExploreButton()
    }

    func setupGlobeView() {
        globeSceneView = SCNView()
        globeSceneView.scene = SCNScene(named: "Globe.dae")

        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 5)
        globeSceneView.scene?.rootNode.addChildNode(cameraNode)
        
        globeSceneView.allowsCameraControl = true // 사용자가 카메라를 제어할 수 있게 합니다.
        
        view.addSubview(globeSceneView)
        globeSceneView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        globeSceneView.scene?.background.contents = UIImage(named: "4k-space-background") // 이미지 파일을 배경으로 설정
        }
    
    func addRotationToEarth(globeNode: SCNNode) {
        let rotation = CABasicAnimation(keyPath: "rotation")
        rotation.toValue = NSValue(scnVector4: SCNVector4(x: 0, y: 1, z: 0, w: Float.pi * 2))
        rotation.duration = 15
        rotation.repeatCount = Float.greatestFiniteMagnitude // 무한 반복
        globeNode.addAnimation(rotation, forKey: "rotation")
    }
    
    func setupAppNameLabel() {
            appNameLabel = UILabel()
            appNameLabel.text = "Earth ToDoList" // 여기에 앱 이름 설정
            appNameLabel.textColor = .white
            appNameLabel.font = UIFont.systemFont(ofSize: 40, weight: .bold)
            appNameLabel.textAlignment = .center
        
        // 그림자 효과
        appNameLabel.layer.shadowColor = UIColor.black.cgColor
        appNameLabel.layer.shadowOffset = CGSize(width: 0, height: 2)
        appNameLabel.layer.shadowRadius = 5
        appNameLabel.layer.shadowOpacity = 1

            view.addSubview(appNameLabel)
            appNameLabel.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(350) // 상단 안전 영역에서부터의 간격
            }
        }

        func setupExploreButton() {
            exploreButton = UIButton(type: .system)
            exploreButton.setTitle("Explore", for: .normal)
            exploreButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
            exploreButton.backgroundColor = UIColor.systemBlue
            exploreButton.setTitleColor(.white, for: .normal)
            exploreButton.layer.cornerRadius = 10
            exploreButton.addTarget(self, action: #selector(exploreButtonTapped), for: .touchUpInside)

            view.addSubview(exploreButton)
            exploreButton.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(100) // 하단 안전 영역에서부터의 간격
                make.width.equalTo(150)
                make.height.equalTo(50)
            }
        }

        @objc func exploreButtonTapped() {
            // 여기에 2D 지도로 전환하는 로직 추가
        }


}


//


import SwiftUI
struct PreView: PreviewProvider {
    static var previews: some View {
        ViewController().toPreview()
    }
}

#if DEBUG
extension UIViewController {
private struct Preview: UIViewControllerRepresentable {
        let viewController: UIViewController

        func makeUIViewController(context: Context) -> UIViewController {
            return viewController
        }

        func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        }
    }

    func toPreview() -> some View {
        Preview(viewController: self)
    }
}
#endif
