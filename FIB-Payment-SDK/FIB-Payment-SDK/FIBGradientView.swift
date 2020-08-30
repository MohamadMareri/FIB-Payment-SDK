//
//  FIBGradientView.swift
//  FIB-Payment-SDK
//
//  Created by Mohamad Mareri on 30.08.20.
//  Copyright © 2020 Mohamad Mareri. All rights reserved.
//

import UIKit

@IBDesignable
final public class FIBGradientView: UIView {

    @IBInspectable public var beginColor: UIColor = UIColor(red: 0.337, green: 0.722, blue: 0.616, alpha: 1) {
        didSet {
            updateGradientLayer()
        }
    }

    @IBInspectable public var endColor: UIColor = UIColor(red: 0.012, green: 0.592, blue: 0.62, alpha: 1) {
        didSet {
            updateGradientLayer()
        }
    }

    private var gradientLayer: CAGradientLayer {
        guard let layer = layer as? CAGradientLayer else {
            fatalError("layerClass must be of type CAGradientLayer")
        }
        return layer
    }

    override public class var layerClass: AnyClass {
        return CAGradientLayer.self
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        updateGradientLayer()
    }

    private func updateGradientLayer() {
        gradientLayer.colors = [
            beginColor.cgColor,
            endColor.cgColor
        ]
        gradientLayer.locations = [0, 1]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        gradientLayer.position = self.center
        gradientLayer.cornerRadius = 8
    }
}

