//
//  ViewController.swift
//  Map-TodoList-1
//
//  Created by t2023-m0031 on 1/4/24.
//

import SwiftUI
import UIKit
import SnapKit

class ViewController: UIViewController {


    override func viewDidLoad() {
        super.viewDidLoad()
    }


}


struct PreView: PreviewProvider {
    static var previews: some View {
        ViewController().toPreview()
    }
}


// MARK: - PrewView

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
