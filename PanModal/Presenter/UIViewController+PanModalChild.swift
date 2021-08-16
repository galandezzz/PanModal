#if os(iOS)
import UIKit

extension UIViewController {
    
    public func addPanModalChild(_ viewController: PanModalPresentable.LayoutType, animated: Bool, completion: (() -> Void)? = nil) {
        let wrapper = PanModalChildTransitionController(panModal: viewController)
        wrapper.attach(to: self, animated: animated, completion: completion)
    }
}

extension PanModalPresentable where Self: UIViewController {
    
    public func removePanModalFromParent(animated: Bool, completion: (() -> Void)? = nil) {
        if let transitionController = parent as? PanModalChildTransitionController {
            transitionController.dismiss(animated: animated, completion: completion)
        } else {
            completion?()
        }
    }
}
#endif
