class TencentCloudDeskCustomerDemoConfig{
  // The sdkAppID of the current Tencent Cloud Chat application, obtained from console.
  static int sdkAppID = 0;

  // The secret of the current Tencent Cloud Chat application, obtained from console.
  // [Warning]: Specifying the `secret` for generating userSig here is for testing purpose only, please use your server to generate userSig rather than by client side on your published app.
  // Refer to: https://trtc.io/document/34385
  static String secret = "";
}
