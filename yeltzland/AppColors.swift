//
//  AppColors.swift
//  yeltzland
//
//  Created by John Pollard on 04/05/2016.
//  Copyright © 2016 John Pollard. All rights reserved.
//

import Foundation
import UIKit

let YeltzBlueColor = UIColor(red: 6.0/255.0, green: 88.0/255.0, blue: 188.0/255.0, alpha: 1.0)
let LightBlueColor = UIColor(red: 202.0/255.0, green: 220.0/255.0, blue: 235.0/255.0, alpha: 1.0)
let FacebookBlueColor = UIColor(red: 71.0/255.0, green: 96.0/255.0, blue: 159.0/255.0, alpha: 1.0)
let StourbridgeRedColor = UIColor(red: 158.0/255.0, green: 0.0/255.0, blue: 26.0/255.0, alpha: 1.0)
let EvostickRedColor = UIColor(red: 252.0/255.0, green: 0.0/255.0, blue: 6.0/255.0, alpha: 1.0)
let BraveLocationRedColor = UIColor(red: 170.0/255.0, green: 60.0/255.0, blue: 79.0/255.0, alpha: 1.0)

let headlineDescriptor = UIFontDescriptor.preferredFontDescriptorWithTextStyle(UIFontTextStyleHeadline);
let bodyDescriptor = UIFontDescriptor.preferredFontDescriptorWithTextStyle(UIFontTextStyleBody);
let footnoteDescriptor = UIFontDescriptor.preferredFontDescriptorWithTextStyle(UIFontTextStyleFootnote);

class AppColors {
    static var AppFontName = "AmericanTypewriter"
    
    static var NavBarTextSize = headlineDescriptor.pointSize
    static var NavBarColor: UIColor = YeltzBlueColor
    static var NavBarTextColor: UIColor = UIColor.whiteColor()
    static var NavBarTintColor: UIColor = UIColor.whiteColor()
    
    static var ProgressBar: UIColor = YeltzBlueColor
    static var WebBackground: UIColor = UIColor.whiteColor()
    static var WebErrorBackground: UIColor = YeltzBlueColor

    static var TabBarTextSize = footnoteDescriptor.pointSize - 2.0
    static var TabBarTextColor: UIColor = YeltzBlueColor
    static var TabBarTintColor: UIColor = UIColor.whiteColor()
    
    static var TwitterBackground: UIColor = UIColor.whiteColor()
    static var TwitterSeparator: UIColor = UIColor.whiteColor()
    
    static var OtherBackground: UIColor = UIColor.whiteColor()
    static var OtherSectionBackground: UIColor = LightBlueColor
    static var OtherSectionText: UIColor = YeltzBlueColor
    static var OtherSeparator: UIColor = UIColor.whiteColor()
    static var OtherSectionTextSize = bodyDescriptor.pointSize
    static var OtherTextSize = bodyDescriptor.pointSize
    static var OtherDetailTextSize = footnoteDescriptor.pointSize
    
    static var Evostick: UIColor = EvostickRedColor
    static var Fantasy: UIColor = YeltzBlueColor
    static var Stour: UIColor = StourbridgeRedColor
    static var BraveLocation: UIColor = BraveLocationRedColor
    static var Facebook: UIColor = FacebookBlueColor
    
    static var SpinnerColor = YeltzBlueColor

}