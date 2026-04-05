abstract class Api {
  /// server url
  static const baseUrl = "https://talkin.notisboard.com/";
  static const secretKey = "Eb6ek8wbjlrR3fiK36IXsUw";

  // >>>>> >>>>> Login Page Api <<<<< <<<<<
  static const checkUserExit = "${baseUrl}api/user/verifyUserExistence?";
  static const login = "${baseUrl}api/user/authenticateOrRegisterUser";

  static const getFirebaseUidByDeviceUuid = "${baseUrl}api/user/getfirebaseIdByDeviceId";
  static const getFirebaseCustomToken = "${baseUrl}api/user/generateFirebaseCustomToken";

  // >>>>> >>>>> Login User Profile Api <<<<< <<<<<
  static const loginUserProfile = "${baseUrl}api/user/getUserProfile";

  // >>>>> >>>>>  User  Api <<<<< <<<<<
  static const editProfile = "${baseUrl}api/user/updateUserProfile";
  static const faq = "${baseUrl}api/user/faq/listFaqs?";
  static const identityProofs = "${baseUrl}api/user/identityProof/listIdentityProofs";
  static const getTalkTopics = "${baseUrl}api/user/talkTopic/getTalkTopics";
  static const becomeHost = "${baseUrl}api/user/expert/initiateExpertRequest";
  static const listenersRequestCheck = "${baseUrl}api/user/expert/verifyExpertRequestStatus";
  static const settingAPi = "${baseUrl}api/user/setting/fetchAppSettingsData";
  static const forgotPassword = "${baseUrl}api/user/resetPassword?";
  static const topListeners = "${baseUrl}api/user/expert/top?";
  static const allListeners = "${baseUrl}api/user/expert/list?";
  static const listenerProfile = "${baseUrl}api/user/expert/profile?";
  static const callingHistory = "${baseUrl}api/user/history/getCallRecords?";
  static const chatListApi = "${baseUrl}api/user/chatTopic/getUserChatList?";
  static const personalChatApi = "${baseUrl}api/user/chat/retrieveChatHistory?";
  static const sendImageAudioApi = "${baseUrl}api/user/chat/sendChatMessage";
  static const purchasedCoinPlan = "${baseUrl}api/user/coinplan/recordPurchasedCoinPlan?";
  static const paymentHistory = "${baseUrl}api/user/history/getCoinPackagePurchaseHistory?";
  static const coinHistory = "${baseUrl}api/user/history/getCoinWalletRecords?";
  static const userCoin = "${baseUrl}api/user/retrieveUserCoinBalance";
  static const userNotification = "${baseUrl}api/user/notification/getNotificationHistory?";
  static const updateUserNotificationPermission = "${baseUrl}api/user/modifyNotificationPermission";

  static const submitCallRate = "${baseUrl}api/user/rating/submitExpertReview?";
  static const searchChatUser = "${baseUrl}api/user/chatTopic/findChattedExpertsBySearch?";
  static const notificationClear = "${baseUrl}api/user/notification/clearNotifications";
  static const deleteUserAccount = "${baseUrl}api/user/deleteSelfAccount";
  static const listenerReviewApi = "${baseUrl}api/user/rating/fetchExpertReviews?";
  static const appConfigurationApi = "${baseUrl}api/user/setting/getAppConfiguration";
  static const expertCategories = "${baseUrl}api/v2/categories/list";

  static const groupSessionCreate = "${baseUrl}api/v2/sessions/group/create";
  static const groupSessionList = "${baseUrl}api/v2/sessions/group/list?";
  static const groupSessionParticipants = "${baseUrl}api/v2/sessions/group/participants?";
  static const groupSessionJoin = "${baseUrl}api/v2/sessions/group/join";
  static const groupSessionLeave = "${baseUrl}api/v2/sessions/group/leave";
  static const groupSessionCancel = "${baseUrl}api/v2/sessions/group/cancel";
  static const sessionGetAvailableSlots = "${baseUrl}api/v2/sessions/getAvailableSlots?";
  static const sessionBookSession = "${baseUrl}api/v2/sessions/bookSession";
  static const sessionCancelBooking = "${baseUrl}api/v2/sessions/cancelSessionBooking";
  static const sessionAccessCheck = "${baseUrl}api/v2/sessions/getSessionAccess";
  static const sessionReportCallOutcome = "${baseUrl}api/v2/sessions/reportSessionCallOutcome";
  static const sessionGetUserSessions = "${baseUrl}api/v2/sessions/getUserSessions?";
  static const sessionGetExpertSessions = "${baseUrl}api/v2/sessions/getExpertSessions?";
  static const expertSetAvailability = "${baseUrl}api/v2/experts/setAvailability";
  static const expertGetAvailability = "${baseUrl}api/v2/experts/getAvailability?";

  static const feedPostsCreate = "${baseUrl}api/v2/feed/posts/create";
  static const feedPostsFeed = "${baseUrl}api/v2/feed/posts/feed?";
  static const feedPostsLike = "${baseUrl}api/v2/feed/posts/like";
  static const feedPostsDeletePrefix = "${baseUrl}api/v2/feed/posts/";

  static const moderationReportUser = "${baseUrl}api/v2/moderation/reports/user";
  static const moderationReportChatMessage = "${baseUrl}api/v2/moderation/reports/chat-message";
  static const moderationReportSession = "${baseUrl}api/v2/moderation/reports/session";
  static const moderationReportFeedPost = "${baseUrl}api/v2/moderation/reports/create";

  // >>>>> >>>>>  Listener  Api <<<<< <<<<<

  static const loginListenerProfile = "${baseUrl}api/expert/fetchExpertProfile?";
  static const listenerEditProfile = "${baseUrl}api/expert/modifyExpertProfile?";
  static const listenerChatListApi = "${baseUrl}api/expert/chatTopic/getChatList?";
  static const listenerPersonalChatListApi = "${baseUrl}api/expert/chat/getChatHistory?";
  static const listenerSendImageAudioApi = "${baseUrl}api/expert/chat/dispatchChatMessage";
  static const listenerCallingHistory = "${baseUrl}api/expert/history/retrieveCallHistory?";
  static const listenerCoinHistory = "${baseUrl}api/expert/history/fetchCoinWalletHistory?";
  static const paymentOptions = "${baseUrl}api/expert/paymentOption/getAvailablePaymentOptions";
  static const withdrawalRecord = "${baseUrl}api/expert/withdrawalRecord/getPayoutRecords?";
  static const addWithdrawalRecord = "${baseUrl}api/expert/withdrawalRecord/addWithdrawalRecord";
  static const updateExpertCallStatus = "${baseUrl}api/expert/toggleExpertAvailability?";
  static const listenerCoin = "${baseUrl}api/expert/getExpertCoinBalance?";
  static const updateNotifyPermission = "${baseUrl}api/expert/updateNotifyPermission?";
  static const searchChatListener = "${baseUrl}api/expert/chatTopic/searchChattedUsers?";
  static const notificationListener = "${baseUrl}api/expert/notification/fetchNotifications?";
  static const clearNotificationListener = "${baseUrl}api/expert/notification/resetNotificationHistory?";
  static const deleteListenerAccount = "${baseUrl}api/expert/deleteExpertAccount?";
  static const userProfileApi = "${baseUrl}api/expert/getProfileByUserId?";

  static const ipApi = "http://ip-api.com/json";

  // >>>>> >>>>>  Subscription Plan <<<<< <<<<<

  static const fetchCoinPlan = "${baseUrl}api/user/coinplan/getAvailableCoinPackage";
}
