import UIKit
import SceneKit
import MapKit
import SnapKit


class MainViewController: UIViewController, MKMapViewDelegate {

    // MARK: - Properties
    var globeSceneView: SCNView!
    var exploreButton: UIButton!
    var appNameLabel: UILabel!
    var mapView: MKMapView?
    let searchController = UISearchController(searchResultsController: nil)
    var searchResults = [MKMapItem]() // 검색 결과를 저장할 배열
    var resultsTableViewController: UITableViewController! // 검색 결과 목록을 보여줄 테이블 뷰 추가
    
    // MARK: - View Lifecycle
    
        override func viewDidLoad() {
        super.viewDidLoad()
        
        self.extendedLayoutIncludesOpaqueBars = true
        edgesForExtendedLayout = [.top, .bottom]
        
        setupGlobeView()
        setupAppNameLabel()
        setupExploreButton()

    }
    
    // MARK: - Setup Functions
    func setupGlobeView() {
        globeSceneView = SCNView()
        globeSceneView.scene = SCNScene(named: "Globe.dae")
        
        if let globeNode = globeSceneView.scene?.rootNode.childNode(withName: "Atmosphere", recursively: true) {
            let rotation = CABasicAnimation(keyPath: "rotation")
            rotation.toValue = NSValue(scnVector4: SCNVector4(x: 0, y: 1, z: 0, w: Float.pi * 2))
            rotation.duration = 30 // 15초 동안 한 바퀴 회전
            rotation.repeatCount = .greatestFiniteMagnitude
            globeNode.addAnimation(rotation, forKey: "rotation")
            
            // 지구 확대 애니메이션
            globeNode.scale = SCNVector3(0.1, 0.1, 0.1) // 초기 스케일을 0으로 설정
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 3.0 // 애니메이션 지속 시간
            globeNode.scale = SCNVector3(0.75, 0.75, 0.75) // 원래 스케일로 확대
            SCNTransaction.commit()
        }
        
        
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 5)
        globeSceneView.scene?.rootNode.addChildNode(cameraNode)
        
        globeSceneView.allowsCameraControl = true // 사용자가 카메라를 제어할 수 있게 합니다.
        
        view.addSubview(globeSceneView)
        globeSceneView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            globeSceneView.topAnchor.constraint(equalTo: view.topAnchor),
            globeSceneView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            globeSceneView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            globeSceneView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        globeSceneView.scene?.background.contents = UIImage(named: "4k-space-background")
    }
    
    func addRotationToEarth(globeNode: SCNNode) {
        let rotation = CABasicAnimation(keyPath: "rotation")
        rotation.toValue = NSValue(scnVector4: SCNVector4(x: 0, y: 1, z: 0, w: Float.pi * 2))
        rotation.duration = 45
        rotation.repeatCount = Float.greatestFiniteMagnitude // 무한 반복
        globeNode.addAnimation(rotation, forKey: "rotation")
    }
    
    func setupAppNameLabel() {
        appNameLabel = UILabel()
        appNameLabel.text = "Earth ToDoList" // 여기에 앱 이름 설정
        appNameLabel.textColor = .white
        appNameLabel.font = UIFont.systemFont(ofSize: 80, weight: .bold)
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
        
        // 글자 크기 변경 애니메이션
        UIView.animate(withDuration: 2.5, animations: {
            self.appNameLabel.transform = CGAffineTransform(scaleX: 0.65, y: 0.65) 
        })
        
    }
    
    func setupExploreButton() {
        exploreButton = UIButton(type: .system)
        exploreButton.setTitle("Explore", for: .normal)
        exploreButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        exploreButton.setTitleColor(.white, for: .normal)
        exploreButton.backgroundColor = UIColor.systemPink // 색상 변경
        exploreButton.layer.cornerRadius = 25 // 둥근 모서리
        exploreButton.addTarget(self, action: #selector(exploreButtonTapped), for: .touchUpInside)
        exploreButton.clipsToBounds = false
        
        view.addSubview(exploreButton)
        exploreButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(100) // 하단 안전 영역에서부터의 간격
            make.width.equalTo(200)
            make.height.equalTo(50)
        }
    }
    
    // MARK: - Actions
    @objc func exploreButtonTapped() {
        
        // 레이블과 버튼을 즉시 숨깁니다.
          self.appNameLabel.isHidden = true
          self.exploreButton.isHidden = true
        
        // MapViewController 전환
        let mapViewController = MapViewController()
        
        // 서울의 위치를 지도 뷰 컨트롤러에 전달합니다.
        mapViewController.initialLocation = CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780)

        self.addChild(mapViewController)
        self.view.insertSubview(mapViewController.view, aboveSubview: self.globeSceneView)
        mapViewController.view.alpha = 0 // 초기에는 투명하게 설정합니다.

        
        // 지구 뷰의 스냅샷을 만들고 화면에 추가합니다.
        let snapshotView = UIImageView(image: self.globeSceneView.snapshot())
        snapshotView.frame = self.view.bounds
        self.view.addSubview(snapshotView)
        
        // 지구 뷰를 숨깁니다.
        self.globeSceneView.isHidden = true
        
        UIView.animateKeyframes(withDuration: 1.5, delay: 0, options: [], animations: {
            
            // 첫 번째 키 프레임: 지구가 확대되면서 페이드아웃합니다.
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5) {
                snapshotView.transform = CGAffineTransform(scaleX: 5.0, y: 5.0)
                snapshotView.alpha = 0
            }
            
            // 두 번째 키 프레임: 지도 뷰가 나타납니다.
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 1) {
                mapViewController.view.alpha = 1
            }
        }) { _ in
            
            // appNameLabel과 exploreButton을 숨깁니다.
            snapshotView.removeFromSuperview() // 스냅샷 뷰를 제거합니다.
            mapViewController.didMove(toParent: self)
            
            
        }
    }
}



// MARK: - Preview


import SwiftUI
struct PreView: PreviewProvider {
    static var previews: some View {
        MainViewController().toPreview()
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
