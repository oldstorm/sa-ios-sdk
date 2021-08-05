//
//  Images.swift
//  ZhiTing
//
//  Created by iMac on 2021/2/3.
//

import UIKit

enum AssetsName: String {
    case home
    case home_sel
    case mine
    case mine_sel
    case scene
    case scene_sel
    case navigation_back
    case plus_circle
    case plus
    case icon_add_device
    case icon_family_brand
    case icon_brand
    case arrow_right
    case search
    case empty_device
    case tick_green
    case discoverBG1
    case discoverBG2
    case discoverBG3
    case exclamation_mark
    case right_arrow_gray
    case add_family_icon
    case home_bg
    case selected_tick
    case selected_tick_red
    case unselected_tick
    case close_button
    case plus_blue
    case icon_edit
    case settings
    case family_sel
    case family_unsel
    case upload_bg
    case switch_on
    case switch_off
    case showPwd
    case hidePwd
    case login_logo
    case icon_thirdParty
    case default_avatar
    case default_avatar_rounded
    case icon_noNetwork
    case default_device
    case loading
    case icon_scan
    case nav_back_white
    case icon_professional
    case icon_fail
    case icon_launch
    case icon_role
    case icon_warning
    case history_button
    case scene_time
    case scene_status
    case scene_connect
    case noScene
    case course_bg
    case plus_gray
    case plus_blue_circle
    case icon_condition_manual
    case icon_condition_timer
    case icon_condition_state
    case icon_smart_device
    case icon_control_scene
    case arrow_up
    case arrow_down
    case selected_tick_square
    case unselected_tick_square
    case icon_noAuth
    case icon_developing
    case icon_noContent
    case icon_noList
    case icon_noRoom
    case icon_noHistory
    case icon_nav_minimize
    case icon_nav_account
    case guide_img1
    case guide_img2
    case guide_img3
    case guide_img4
    case guide_img5
    case guide_img6
    case guide_img7
    case guide_img8
    case guide_token_1
    case guide_token_2
    case guide_token_3
    case sliderThumb
    case icon_delay
    case icon_update
    case icon_update_orange
    case refreshing_white
    case refreshing_orange
    case icon_alert_warning
    case homekit_icon
    case icon_wifi
    case icon_lock
    case icon_about_us
    case app_logo
    case icon_wifi_blue
    case icon_resetDevice

    var assetName: String {
        return self.rawValue
    }
}

extension UIImage {
    static func assets(_ asset: AssetsName) -> UIImage? {
        return UIImage(named: asset.assetName)
    }
}
