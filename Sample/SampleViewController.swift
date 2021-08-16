//
//  SampleViewController.swift
//  PanModal
//
//  Created by Stephen Sowole on 10/9/18.
//  Copyright © 2018 PanModal. All rights reserved.
//

import UIKit

class SampleViewController: UITableViewController {

    private var childPanModal: PanModalPresentable.LayoutType?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    private func setupView() {
        title = "PanModal"

        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont(name: "Lato-Bold", size: 17)!
        ]

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: String(describing: UITableViewCell.self))
        tableView.tableFooterView = UIView()
        tableView.separatorInset = .zero
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return RowType.allCases.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UITableViewCell.self), for: indexPath)

        guard let rowType = RowType(rawValue: indexPath.row) else {
            return cell
        }
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.text = rowType.presentable.string
        cell.textLabel?.font = UIFont(name: "Lato-Regular", size: 17.0)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let rowType = RowType(rawValue: indexPath.row) else {
            return
        }
        
        let showHandler: () -> Void
        if rowType == .child {
            showHandler = {
                let vc = rowType.presentable.rowVC
                self.childPanModal = vc
                self.addPanModalChild(vc, animated: true)
            }
        } else {
            showHandler = { self.presentPanModal(rowType.presentable.rowVC) }
        }
        
        if let childPanModal = childPanModal {
            self.childPanModal = nil
            childPanModal.removePanModalFromParent(animated: true, completion: showHandler)
        } else {
            dismiss(animated: true, completion: showHandler)
        }
    }
}

protocol RowPresentable {
    var string: String { get }
    var rowVC: UIViewController & PanModalPresentable { get }
}

private extension SampleViewController {

    enum RowType: Int, CaseIterable {
        case child
        case basic
        case fullScreen
        case alert
        case transientAlert
        case userGroups
        case stacked
        case navController


        var presentable: RowPresentable {
            switch self {
            case .child: return Child()
            case .basic: return Basic()
            case .fullScreen: return FullScreen()
            case .alert: return Alert()
            case .transientAlert: return TransientAlert()
            case .userGroups: return UserGroup()
            case .stacked: return Stacked()
            case .navController: return Navigation()
            }
        }

        struct Child: RowPresentable {
            let string: String = "Child"
            let rowVC: PanModalPresentable.LayoutType = BasicViewController()
        }
        
        struct Basic: RowPresentable {
            let string: String = "Basic"
            let rowVC: PanModalPresentable.LayoutType = BasicViewController()
        }

        struct FullScreen: RowPresentable {
            let string: String = "Full Screen"
            let rowVC: PanModalPresentable.LayoutType = FullScreenNavController()
        }

        struct Alert: RowPresentable {
            let string: String = "Alert"
            let rowVC: PanModalPresentable.LayoutType = AlertViewController()
        }

        struct TransientAlert: RowPresentable {
            let string: String = "Alert (Transient)"
            let rowVC: PanModalPresentable.LayoutType = TransientAlertViewController()
        }

        struct UserGroup: RowPresentable {
            let string: String = "User Groups"
            let rowVC: PanModalPresentable.LayoutType = UserGroupViewController()
        }

        struct Navigation: RowPresentable {
            let string: String = "User Groups (NavigationController)"
            let rowVC: PanModalPresentable.LayoutType = NavigationController()
        }

        struct Stacked: RowPresentable {
            let string: String = "User Groups (Stacked)"
            let rowVC: PanModalPresentable.LayoutType = UserGroupStackedViewController()
        }
    }
}
