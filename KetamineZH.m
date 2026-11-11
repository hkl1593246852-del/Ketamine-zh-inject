#import <UIKit/UIKit.h>
#import <objc/runtime.h>

// 运行时把英文标签替换成中文。
// 不改 app 的任何字符串常量，只在 UILabel.setText: 出口做映射。

static NSDictionary<NSString *, NSString *> *gMap;

static IMP gOrigSetText;

static void mySetText(id self, SEL _cmd, NSString *text) {
    NSString *mapped = text ? gMap[text] : nil;
    ((void (*)(id, SEL, NSString *))gOrigSetText)(self, _cmd, mapped ?: text);
}

__attribute__((constructor))
static void eroHook(void) {
    gMap = @{
        // Display
        @"Dynamic Island":            @"灵动岛",
        @"Always-On Display":         @"常亮显示",
        @"AOD Vibrancy":              @"息屏动态",
        @"Pulse Width Modulation":    @"脉宽调制",
        // Device
        @"Device Model Name":         @"机型名称",
        @"Device Artwork Subtype":    @"机型子类型",
        @"Device Spoof (ProductType)":@"设备伪装",
        // System
        @"Boot Chime":                @"开机音效",
        @"Charge Limit":              @"充电上限",
        @"Collision SOS":             @"碰撞检测",
        @"Tap to Wake":               @"轻点唤醒",
        @"iPhone 16 Settings":        @"iPhone 16 设置",
        @"Disable Wallpaper Parallax":@"关闭壁纸视差",
        @"Stage Manager":             @"台前调度",
        @"Region Restrictions":       @"地区限制",
        @"Apple Pencil Settings":     @"Apple Pencil 设置",
        @"Action Button Settings":    @"操作按钮设置",
        @"Internal Storage":          @"内部存储",
        @"Internal Install":          @"内部安装",
        @"Internal Features":         @"内部功能",
        @"Security Research Device":  @"安全研究设备",
        @"ProRes Video":              @"ProRes 录制",
        @"Landscape Face ID":         @"横屏 Face ID",
        @"External Display Output":   @"外接显示输出",
        @"Wi-Fi Calling":             @"Wi-Fi 通话",
        // Liquid Glass
        @"Liquid Glass Low Power":    @"液态玻璃省电",
        @"Liquid Glass Full Fidelity":@"液态玻璃完整",
        // iPad
        @"iPadOS Mode":               @"iPadOS 模式",
        @"Allow iPad Apps":           @"允许安装 iPad 应用",
        // 分区标题
        @"Display":                   @"显示",
        @"Device":                    @"设备",
        @"System":                    @"系统",
        @"Intelligence":              @"智能",
        @"Liquid Glass":              @"液态玻璃",
        // 描述
        @"Force the Dynamic Island capability bit directly.": @"直接强制开启灵动岛能力位。",
        @"Enable Always-On Display support.": @"启用常亮显示支持。",
        @"Enable the Always-On Display vibrancy effect.": @"启用常亮显示的动态色彩效果。",
        @"Advertise PWM display support.": @"声明支持 PWM 调光。",
        @"Change the model name shown in Settings.": @"修改「设置」里显示的机型名称。",
        @"Report a different device model for artwork/UI behavior.": @"上报不同的机型，影响图片与界面表现。",
        @"Spoof the reported model for Apple Intelligence eligibility.": @"伪装上报的机型，以满足 Apple 智能资格。",
        @"Enable the macOS-style boot chime on startup.": @"开机时启用 macOS 风格提示音。",
        @"Enable the 80% charge limit setting.": @"启用 80% 充电上限。",
        @"Enable the Crash Detection menu.": @"启用碰撞检测菜单。",
        @"Enable Tap to Wake (useful on iPhone SE).": @"启用轻点唤醒（iPhone SE 上很实用）。",
        @"Reveal the Camera Control settings panes.": @"显示相机控制设置面板。",
        @"Turn off the wallpaper depth/parallax effect.": @"关闭壁纸景深与视差效果。",
        @"Advertise Stage Manager support.": @"声明支持台前调度。",
        @"Spoof region to lift shutter-sound restrictions.": @"伪装地区以解除快门声限制。",
        @"Reveal the Apple Pencil settings tab.": @"显示 Apple Pencil 设置标签页。",
        @"Reveal the Action Button settings tab.": @"显示操作按钮设置标签页。",
        @"Expose internal storage capacity.": @"显示内部存储容量。",
        @"Mark the build as internal (Metal HUD anywhere).": @"把系统标记为内部版本（任意界面可开 Metal HUD）。",
        @"Expose internal settings and build flags via CacheData.": @"通过 CacheData 暴露内部设置与构建标志。",
        @"Enable Security Research Device mode.": @"启用安全研究设备模式。",
        @"Advertise software ProRes recording support.": @"声明支持软件 ProRes 录制。",
        @"Unlock Face ID authentication in landscape orientation.": @"在横屏方向解锁 Face ID。",
        @"Advertise DisplayPort support over USB-C.": @"声明支持 USB-C 上的 DisplayPort。",
        @"Advertise Wi-Fi Calling capability support.": @"声明支持 Wi-Fi 通话。",
        @"Force low-power mode for Liquid Glass.": @"强制液态玻璃进入省电模式。",
        @"Disable Liquid Glass low-power mode.": @"关闭液态玻璃省电模式。",
        @"Spoof iPadOS capabilities and patch CacheData.": @"伪装 iPadOS 能力并改写 CacheData。",
        @"Spoof iOS capabilities and patch CacheData.": @"伪装 iOS 能力并改写 CacheData。",
        @"Allow iPad apps to install on iPhone.": @"允许在 iPhone 上安装 iPad 应用。",
    };
    Method m = class_getInstanceMethod([UILabel class], @selector(setText:));
    if (m) {
        gOrigSetText = method_getImplementation(m);
        method_setImplementation(m, (IMP)mySetText);
    }
}
