//
//  PanModalPresentationController.swift
//  PanModal
//
//  Copyright © 2019 Tiny Speck, Inc. All rights reserved.
//

#if os(iOS)
import UIKit

/**
 The PanModalPresentationController is the middle layer between the presentingViewController
 and the presentedViewController.

 It controls the coordination between the individual transition classes as well as
 provides an abstraction over how the presented view is presented & displayed.

 For example, we add a drag indicator view above the presented view and
 a background overlay between the presenting & presented view.

 The presented view's layout configuration & presentation is defined using the PanModalPresentable.

 By conforming to the PanModalPresentable protocol & overriding values
 the presented view can define its layout configuration & presentation.
 */
open class PanModalPresentationController: UIPresentationController {

    public override var presentedView: UIView {
        controller.presentedView
    }
    
    private(set) lazy var controller: PanModalCommonPresentationController = {
        let result = PanModalCommonPresentationController(
            presentedViewController: presentedViewController,
            presentingViewController: presentingViewController
        )
        result.delegate = self
        return result
    }()

    // MARK: - Lifecycle

    override public func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        
        controller.containerViewWillLayoutSubviews()
    }

    override public func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        
        controller.presentationTransitionWillBegin()
    }

    override public func presentationTransitionDidEnd(_ completed: Bool) {
        super.presentationTransitionDidEnd(completed)
        
        controller.presentationTransitionDidEnd(completed)
    }

    override public func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()
        
        controller.dismissalTransitionWillBegin()
    }

    override public func dismissalTransitionDidEnd(_ completed: Bool) {
        super.dismissalTransitionDidEnd(completed)
        
        controller.dismissalTransitionDidEnd(completed)
    }

    override public func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        controller.viewWillTransition(to: size, with: coordinator)
    }
}

extension PanModalPresentationController: PanModalCommonPresentationControllerDelegate {
    
    func containerView(for controller: PanModalCommonPresentationController) -> UIView? {
        containerView
    }
    
    func transitionCoordinator(for controller: PanModalCommonPresentationController) -> PanModalTransitionCoordinator? {
        presentedViewController.transitionCoordinator.map(TransitionCoordinatorWrapper.init)
    }
    
    func controllerNeedDismiss(_ controller: PanModalCommonPresentationController) {
        presentedViewController.dismiss(animated: true)
    }
}

final class TransitionCoordinatorWrapper: PanModalTransitionCoordinator {
    init(transitionCoordinator: UIViewControllerTransitionCoordinator) {
        self.transitionCoordinator = transitionCoordinator
    }
    
    func animate(alongsideTransition animations: @escaping () -> Void, completion: ((Bool) -> Void)?) {
        transitionCoordinator.animate { _ in
            animations()
        } completion: { context in
            completion?(!context.isCancelled)
        }
    }
    
    private let transitionCoordinator: UIViewControllerTransitionCoordinator
}
#endif
