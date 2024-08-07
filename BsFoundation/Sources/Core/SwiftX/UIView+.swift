//
//  UIView+.swift
//  BsFoundation
//
//  Created by Runze Chang on 2024/5/16.
//  Copyright © 2024 BaldStudio. All rights reserved.
//

public extension UIView {
    var isVisible: Bool {
        !isHidden
    }

    /// 截图
    var snapshot: UIImage? {
        UIGraphicsImageRenderer(bounds: bounds).image { _ in
            drawHierarchy(in: bounds, afterScreenUpdates: true)
        }
    }
    
    /// 获取nib
    static func nib(_ name: String? = nil) -> UINib {
        let nibName = name ?? "\(self)"
        let bundle = Bundle(for: self)
        return UINib(nibName: nibName, bundle: bundle)
    }
    
    /// 从xib加载视图
    static func load<T: UIView>(from nibNameOrNil: String? = nil,
                     bundle nibBundleOrNil: Bundle? = nil) -> T? {
        let nibName = nibNameOrNil ?? "\(self)"
        let bundle = nibBundleOrNil ?? Bundle(for: self)
        let objects = bundle.loadNibNamed(nibName, owner: nil, options: nil)
        return objects?.first as? T
    }
}

// MARK: - Hierarchy

public extension UIView {
    func removeSubviews() {
        subviews.forEach { $0.removeFromSuperview() }
    }
    
    func subviews<Element>(ofKind: Element.Type) -> [Element] {
        var views: [Element] = []
        for subview in subviews {
            if let view = subview as? Element {
                views.append(view)
            }
            else if !subview.subviews.isEmpty {
                views.append(contentsOf: subview.subviews(ofKind: Element.self))
            }
        }
        return views
    }
}

// MARK: - Layout

public extension UIView {
    func edgesEqual(to v: UIView, with insets: UIEdgeInsets = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            leftAnchor.constraint(equalTo: v.leftAnchor,
                                  constant: insets.left),
            rightAnchor.constraint(equalTo: v.rightAnchor,
                                   constant: -insets.right),
            topAnchor.constraint(equalTo: v.topAnchor,
                                 constant: insets.top),
            bottomAnchor.constraint(equalTo: v.bottomAnchor,
                                    constant: -insets.bottom),
        ])
    }
    
    func edgesEqualToSuperview(with insets: UIEdgeInsets = .zero) {
        guard let superview else { fatalError() }
        edgesEqual(to: superview, with: insets)
    }
    
    var safeTopAnchor: NSLayoutYAxisAnchor {
        safeAreaLayoutGuide.topAnchor
    }
    
    var safeLeftAnchor: NSLayoutXAxisAnchor {
        safeAreaLayoutGuide.leftAnchor
    }
    
    var safeRightAnchor: NSLayoutXAxisAnchor {
        safeAreaLayoutGuide.rightAnchor
    }
    
    var safeBottomAnchor: NSLayoutYAxisAnchor {
        safeAreaLayoutGuide.bottomAnchor
    }
    
    /// 设置内容拉伸的优先级
    func applyingFlex(for axis: NSLayoutConstraint.Axis? = nil) {
        if axis == nil {
            setContentHuggingPriority(.fittingSizeLevel, for: .vertical)
            setContentCompressionResistancePriority(.fittingSizeLevel, for: .vertical)
            setContentHuggingPriority(.fittingSizeLevel, for: .vertical)
            setContentCompressionResistancePriority(.fittingSizeLevel, for: .vertical)
        } else if axis == .horizontal {
            setContentHuggingPriority(.fittingSizeLevel, for: .horizontal)
            setContentCompressionResistancePriority(.fittingSizeLevel, for: .horizontal)
        } else {
            setContentHuggingPriority(.fittingSizeLevel, for: .vertical)
            setContentCompressionResistancePriority(.fittingSizeLevel, for: .vertical)
        }
    }

    func applyingFixed(for axis: NSLayoutConstraint.Axis? = nil) {
        if axis == nil {
            setContentHuggingPriority(.required, for: .horizontal)
            setContentCompressionResistancePriority(.required, for: .horizontal)
            setContentHuggingPriority(.required, for: .vertical)
            setContentCompressionResistancePriority(.required, for: .vertical)
        } else if axis == .horizontal {
            setContentHuggingPriority(.required, for: .horizontal)
            setContentCompressionResistancePriority(.required, for: .horizontal)
        } else {
            setContentHuggingPriority(.required, for: .vertical)
            setContentCompressionResistancePriority(.required, for: .vertical)
        }
    }


    /// 移除自身的所有约束
    func removeConstraints() {
        guard let superview else { return }
        let constraintsInSuperView = superview.constraints.filter {
            ($0.firstItem as? UIView) == self
        }
        superview.removeConstraints(constraintsInSuperView)
        let constraints = constraints.filter {
            ($0.firstItem as? UIView) == self
        }
        removeConstraints(constraints)
    }
}

// MARK: - Responder

public extension UIView {
    var viewController: UIViewController? {
        nearest(ofKind: UIViewController.self) ?? BsApp.rootViewController
    }

    var navigationController: UINavigationController? {
        viewController?.navigationController
    }
}

// MARK: - Render

/// convert UIRectCorner to CACornerMask
private extension UIRectCorner {
    var asCACornerMask: CACornerMask {
        var cornersMask = CACornerMask()
        if contains(.topLeft) {
            cornersMask.insert(.layerMinXMinYCorner)
        }
        if contains(.topRight) {
            cornersMask.insert(.layerMaxXMinYCorner)
        }
        if contains(.bottomLeft) {
            cornersMask.insert(.layerMinXMaxYCorner)
        }
        if contains(.bottomRight) {
            cornersMask.insert(.layerMaxXMaxYCorner)
        }
        return cornersMask
    }
}

public extension UIView {
    func applying(rounded radius: CGFloat,
                  corners: UIRectCorner = .allCorners,
                  masksToBounds: Bool = true) {
        layer.cornerRadius = radius
        layer.maskedCorners = corners.asCACornerMask
        layer.masksToBounds = masksToBounds
        if #available(iOS 13.0, *) {
            layer.cornerCurve = .continuous
        }
    }

    func applying(border color: UIColor, width: CGFloat = 1) {
        layer.borderColor = color.cgColor
        layer.borderWidth = width
    }
}

// MARK: - Gestures

private enum RuntimeKey {
    static var gestureEvents = 0
}

public extension UIView {
    @discardableResult
    func addGestureTarget<T: AnyObject, Gesture: UIGestureRecognizer>(_ target: T,
                                                                      action: @escaping Action<T, Gesture>) -> Gesture {
        let gesture = Gesture(target: self.target, action: #selector(UIView.bs_onGestureEvent(_:)))
        addGestureRecognizer(gesture)
        let event = UIView.GestureEvent(target: target, gesture: gesture) { [weak target] gesture in
            guard let target, let gesture = gesture as? Gesture else { return }
            action(target)(gesture)
        }
        bs_gestureEvents.append(event)
        return gesture
    }
    
    func removeGestureTarget<T: AnyObject, Gesture: UIGestureRecognizer>(_ target: T,
                                                                         gesture: Gesture? = nil) {
        if let gesture {
            bs_gestureEvents.removeAll {
                if $0.target === target, $0.gesture == gesture {
                    removeGestureRecognizer(gesture)
                    return true
                }
                return false
            }
        } else {
            bs_gestureEvents.removeAll()
        }
    }

    // MARK: - single tap
    
    func onSingleTap(_ action: @escaping BlockT<UITapGestureRecognizer>) {
        addGestureTarget(self) { (v: UIView) -> BlockT<UITapGestureRecognizer> in { action($0) } }
    }
}

private extension UIView {
    struct GestureEvent {
        let target: AnyObject
        let gesture: UIGestureRecognizer
        let action: BlockT<UIGestureRecognizer>
    }

    var bs_gestureEvents: [GestureEvent] {
        get {
            if let value: [GestureEvent] = value(forAssociated: &RuntimeKey.gestureEvents) { return value }
            let value: [GestureEvent] = []
            set(associate: value, for: &RuntimeKey.gestureEvents)
            return value
        }
        set {
            set(associate: newValue, for: &RuntimeKey.gestureEvents)
        }
    }
    
    @objc
    func bs_onGestureEvent(_ sender: UIGestureRecognizer) {
        for event in bs_gestureEvents where event.gesture == sender {
            event.action(sender)
        }
    }
}
