//
//  NavigateFromSearchResultProtocol.swift
//  Nomad-App
//
//  Created by yuishii on 2021/02/07.
//  Copyright © 2021 Yu Ishii. All rights reserved.
//

import UIKit

protocol NavigateFromSearchResultProtocol: class {
    func navigationControllerPush(fromSearchResult viewController: BaseViewController)
    func previewingContext(fromSearchResult previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController)
}

extension NavigateFromSearchResultProtocol{
    func previewingContext(fromSearchResult previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController){
        
    }
}

