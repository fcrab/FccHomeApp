/// 认证页面进入目的枚举
enum AuthPurpose {
  /// 应用启动后首次进入
  firstLaunch,

  /// 从其他页面退出登录后跳转
  logout,

  /// 游客模式点击登录
  reLogin,
}
