#if os(iOS)
import UIKit

final class PanModalChildTransitionController: UIViewController {
    
    init(panModal: PanModalPresentable.LayoutType) {
        self.panModal = panModal
        
        panModal.modalPresentationStyle = .custom
        panModal.modalPresentationCapturesStatusBarAppearance = true
        panModal.transitioningDelegate = PanModalPresentationDelegate.child
        
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let panModal: PanModalPresentable.LayoutType
    
    private lazy var fakeBottomSheet: UIViewController = {
        let result = FakeBottomSheet()
        result.modalPresentationStyle = .custom
        result.modalPresentationCapturesStatusBarAppearance = false
        result.transitioningDelegate = self
        return result
    }()
    
    private(set) lazy var controller: PanModalCommonPresentationController = {
        let result = PanModalCommonPresentationController(
            presentedViewController: panModal,
            presentingViewController: parent ?? self
        )
        result.delegate = self
        return result
    }()
    
    func attach(to parent: UIViewController, animated: Bool, completion: (() -> Void)?) {
        parent.addChild(self)
        view.frame = parent.view.bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        parent.view.addSubview(view)
        didMove(toParent: parent)
        
        parent.present(fakeBottomSheet, animated: animated) {
            self.fakeBottomSheet.dismiss(animated: false)
        }
        
        let transitionContext = TransitionContext(
            animated: animated,
            containerView: view,
            fromViewController: parent,
            toViewController: panModal
        )
        
        addChild(panModal)
        panModal.beginAppearanceTransition(true, animated: animated)
        
        controller.presentationTransitionWillBegin()
        
        let animation: () -> Void = {
            self.panModal.transitioningDelegate?
                .animationController?(forPresented: self.panModal, presenting: parent, source: parent)?
                .animateTransition(using: transitionContext)
        }
        
        if animated {
            animation()
        } else {
            UIView.performWithoutAnimation(animation)
        }
        
        let completion: (Bool) -> Void = { completed in
            self.controller.presentationTransitionDidEnd(completed)
            
            if completed {
                self.panModal.endAppearanceTransition()
                self.panModal.didMove(toParent: self)
            }
            
            completion?()
        }
        if let coordinator = fakeBottomSheet.transitionCoordinator {
            coordinator.animate(alongsideTransition: nil) { context in
                completion(!context.isCancelled)
            }
        } else {
            completion(true)
        }
    }
    
    override func loadView() {
        super.loadView()
        
        let view = TouchPassView(frame: self.view.frame)
        view.allowTouchesOnSelf = !panModal.passesTouchesThroughDimmedView
        self.view = view
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        controller.containerViewWillLayoutSubviews()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        controller.viewWillTransition(to: size, with: coordinator)
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        parent?.present(fakeBottomSheet, animated: false, completion: {
            DispatchQueue.main.async {
                self.fakeBottomSheet.dismiss(animated: flag)
                
                self.panModal.willMove(toParent: nil)
                self.panModal.beginAppearanceTransition(false, animated: flag)
                self.controller.dismissalTransitionWillBegin()
                
                let transitionContext = TransitionContext(
                    animated: flag,
                    containerView: self.view,
                    fromViewController: self.panModal,
                    toViewController: self.parent ?? self
                )
                
                let animation: () -> Void = {
                    self.panModal.transitioningDelegate?
                        .animationController?(forDismissed: self.panModal)?
                        .animateTransition(using: transitionContext)
                }
                
                if flag {
                    animation()
                } else {
                    UIView.performWithoutAnimation(animation)
                }
                
                let completion: (Bool) -> Void = { completed in
                    self.controller.dismissalTransitionDidEnd(completed)
                    if completed {
                        self.panModal.endAppearanceTransition()
                        self.panModal.removeFromParent()
                        
                        self.willMove(toParent: nil)
                        self.view.removeFromSuperview()
                        self.removeFromParent()
                    }
                    
                    completion?()
                }
                
                if let coordinator = self.fakeBottomSheet.transitionCoordinator {
                    coordinator.animate(alongsideTransition: nil) { context in
                        completion(!context.isCancelled)
                    }
                } else {
                    completion(true)
                }
            }
        })
    }
}

extension PanModalChildTransitionController: UIViewControllerTransitioningDelegate {
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        panModal.transitioningDelegate?.animationController?(forDismissed: dismissed)
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        panModal.transitioningDelegate?.animationController?(forPresented: presented, presenting: presenting, source: source)
    }
}

extension PanModalChildTransitionController: PanModalCommonPresentationControllerDelegate {
    
    func containerView(for controller: PanModalCommonPresentationController) -> UIView? {
        view
    }
    
    func transitionCoordinator(for controller: PanModalCommonPresentationController) -> PanModalTransitionCoordinator? {
        fakeBottomSheet.transitionCoordinator.map(TransitionCoordinatorWrapper.init)
    }
    
    func controllerNeedDismiss(_ controller: PanModalCommonPresentationController) {
        dismiss(animated: true)
    }
}

private final class FakeBottomSheet: UIViewController, PanModalPresentable {
    var panScrollable: UIScrollView? { nil }
}

private final class TouchPassView: UIView {
    var allowTouchesOnSelf = true
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        if !allowTouchesOnSelf, hitView === self {
            return nil
        }
        return hitView
    }
}

private final class TransitionContext: NSObject, UIViewControllerContextTransitioning {
    let containerView: UIView
    let isAnimated: Bool
    let isInteractive: Bool = false
    let transitionWasCancelled: Bool = false
    let presentationStyle: UIModalPresentationStyle = .custom
    let targetTransform: CGAffineTransform = .identity
    
    func updateInteractiveTransition(_ percentComplete: CGFloat) {}
    func finishInteractiveTransition() {}
    func cancelInteractiveTransition() {}
    func pauseInteractiveTransition() {}
    
    func completeTransition(_ didComplete: Bool) {}
    
    func viewController(forKey key: UITransitionContextViewControllerKey) -> UIViewController? {
        switch key {
        case .from: return fromViewController
        case .to: return toViewController
        default: return nil
        }
    }
    
    func view(forKey key: UITransitionContextViewKey) -> UIView? {
        switch key {
        case .from: return fromViewController.view
        case .to: return toViewController.view
        default: return nil
        }
    }
    
    func initialFrame(for vc: UIViewController) -> CGRect {
        if vc == fromViewController {
            return vc.view.frame
        }
        return .zero
    }
    
    func finalFrame(for vc: UIViewController) -> CGRect {
        if vc == fromViewController {
            return vc.view.frame
        }
        if vc == toViewController {
            return fromViewController.view.frame
        }
        return .zero
    }
    
    init(animated: Bool, containerView: UIView, fromViewController: UIViewController, toViewController: UIViewController) {
        self.isAnimated = animated
        self.containerView = containerView
        self.fromViewController = fromViewController
        self.toViewController = toViewController
    }
    
    private let fromViewController: UIViewController
    private let toViewController: UIViewController
}

#endif
