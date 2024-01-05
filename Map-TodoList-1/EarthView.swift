import SceneKit
import UIKit

class EarthView: SCNView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupEarth()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupEarth()
    }

    private func setupEarth() {
        let scene = SCNScene()
        self.scene = scene

        // 지구본 생성 및 설정
        let earth = SCNSphere(radius: 1.0)
        let earthMaterial = SCNMaterial()
        earthMaterial.diffuse.contents = UIImage(named: "earth_texture") // 지구본 텍스처 이미지
        earth.firstMaterial = earthMaterial

        let earthNode = SCNNode(geometry: earth)
        scene.rootNode.addChildNode(earthNode)

        // 카메라 설정
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 5)
        scene.rootNode.addChildNode(cameraNode)
    }
}
