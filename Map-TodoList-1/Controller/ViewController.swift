import UIKit
import SceneKit
import MapKit
import SnapKit


class ViewController: UIViewController {
    
    var globeSceneView: SCNView!
    var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupGlobeView()
    }

    func setupGlobeView() {
        globeSceneView = SCNView()
        globeSceneView.scene = SCNScene()
        globeSceneView.backgroundColor = .black
        
        let globe = SCNSphere(radius: 1.20)
        
        let earthMaterial = SCNMaterial()
        earthMaterial.diffuse.contents = UIImage(named: "earth_diffuse_4k")
        earthMaterial.emission.contents = UIImage(named: "earth_cloud")
        earthMaterial.specular.contents = UIImage(named: "earth_specular_1k")
        earthMaterial.normal.contents = UIImage(named: "earth_normal_4k")
        earthMaterial.transparent.contents = UIImage(named: "clouds_transparent_2k")
        
        globe.materials = [earthMaterial]
        
        let globeNode = SCNNode(geometry: globe)
        globeNode.position = SCNVector3(x: 0, y: 0, z: 0)
        globeSceneView.scene?.rootNode.addChildNode(globeNode)
        
        addRotationToEarth(globeNode: globeNode) // 지구에 애니메이션 추가

        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 5)
        globeSceneView.scene?.rootNode.addChildNode(cameraNode)
        
        globeSceneView.allowsCameraControl = true // 사용자가 카메라를 제어할 수 있게 합니다.
        
        view.addSubview(globeSceneView)
        globeSceneView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func addRotationToEarth(globeNode: SCNNode) {
        let rotation = CABasicAnimation(keyPath: "rotation")
        rotation.toValue = NSValue(scnVector4: SCNVector4(x: 0, y: 1, z: 0, w: Float.pi * 2))
        rotation.duration = 15 // 30초 동안 한 바퀴 회전
        rotation.repeatCount = Float.greatestFiniteMagnitude // 무한 반복
        globeNode.addAnimation(rotation, forKey: "rotation")
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
