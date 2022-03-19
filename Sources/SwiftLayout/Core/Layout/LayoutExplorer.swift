//
//  LayoutExplorer.swift
//  
//
//  Created by aiden_h on 2022/03/19.
//

import UIKit

enum LayoutExplorer {
    struct Component {
        var superView: UIView? = nil
        var view: UIView
        var anchors: Anchors? = nil
    }
    
    typealias TraversalHandler = (_ layout: Layout, _ superview: UIView?) -> Void
    
    static func components(layout: Layout) -> [Component] {
        var elements: [Component] = []
        
        traversal(layout: layout, superview: nil) { layout, superview in
            if let view = layout.view {
                elements.append(Component(superView: superview, view: view, anchors: layout.anchors))
            }
        }
        
        return elements
    }
    
    static func traversal(layout: Layout, superview: UIView?, handler: TraversalHandler) {
        handler(layout, superview)
        
        let nextSuperview = layout.view ?? superview
        layout.sublayouts.forEach { layout in
            traversal(layout: layout, superview: nextSuperview, handler: handler)
        }
    }
}

extension LayoutExplorer {
    static func debugLayoutStructure(layout: Layout, withAnchors: Bool = false, _ indent: String = "", _ sublayoutIndent: String = "") -> [String] {
        var result = ["\(indent)\(layout.description)"]
        
        if withAnchors {
            let anchorsIndent: String
            if layout.sublayouts.isEmpty {
                anchorsIndent = sublayoutIndent + "      "
            } else {
                anchorsIndent = sublayoutIndent + "│     "
            }
            let items = layout.anchors.items
            if !items.isEmpty {
                result.append(contentsOf: items.map({ item in "\(anchorsIndent)\(item.description)" }))
            }
        }
        
        var sublayouts = layout.sublayouts
        if sublayouts.isEmpty {
            return result
        } else {
            let last = sublayouts.removeLast()
            for sublayout in sublayouts {
                result.append(contentsOf: debugLayoutStructure(layout: sublayout, withAnchors: withAnchors,sublayoutIndent + "├─ ", sublayoutIndent + "│  "))
            }
            result.append(contentsOf: debugLayoutStructure(layout: last, withAnchors: withAnchors, sublayoutIndent + "└─ ", sublayoutIndent + "   "))
        }
        
        return result
    }
}
