// ignore_for_file: constant_identifier_names

import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:eshop_multivendor/Helper/Constant.dart';

final Uri getSellerApi = Uri.parse('${baseUrl}get_sellers');
final Uri getSliderApi = Uri.parse('${baseUrl}get_slider_images');
final Uri getCatApi = Uri.parse('${baseUrl}get_categories');
final Uri getSectionApi = Uri.parse('${baseUrl}get_sections');
final Uri getSettingApi = Uri.parse('${baseUrl}get_settings');
final Uri getSubcatApi =
    Uri.parse('${baseUrl}get_subcategories_by_category_id');
final Uri getProductApi = Uri.parse('${baseUrl}get_products');
final Uri manageCartApi = Uri.parse('${baseUrl}manage_cart');
final Uri getUserLoginApi = Uri.parse('${baseUrl}login');
final Uri getUserSignUpApi = Uri.parse('${baseUrl}register_user');
final Uri getVerifyUserApi = Uri.parse('${baseUrl}verify_user');
final Uri getVerifyOtpApi = Uri.parse('${baseUrl}verify_otp');
final Uri getResendOtpApi = Uri.parse('${baseUrl}resend_otp');
final Uri setFavoriteApi = Uri.parse('${baseUrl}add_to_favorites');
final Uri removeFavApi = Uri.parse('${baseUrl}remove_from_favorites');
final Uri getRatingApi = Uri.parse('${baseUrl}get_product_rating');
final Uri getReviewImgApi = Uri.parse('${baseUrl}get_product_review_images');
final Uri getCartApi = Uri.parse('${baseUrl}get_user_cart');
final Uri getFavApi = Uri.parse('${baseUrl}get_favorites');
final Uri setRatingApi = Uri.parse('${baseUrl}set_product_rating');
final Uri getNotificationApi = Uri.parse('${baseUrl}get_notifications');
final Uri getAddressApi = Uri.parse('${baseUrl}get_address');
final Uri deleteAddressApi = Uri.parse('${baseUrl}delete_address');
final Uri getResetPassApi = Uri.parse('${baseUrl}reset_password');
final Uri getCitiesApi = Uri.parse('${baseUrl}get_cities');
final Uri getAreaByCityApi = Uri.parse('${baseUrl}get_zipcode_by_city_id');
final Uri getUpdateUserApi = Uri.parse('${baseUrl}update_user');
final Uri getAddAddressApi = Uri.parse('${baseUrl}add_address');
final Uri updateAddressApi = Uri.parse('${baseUrl}update_address');
final Uri placeOrderApi = Uri.parse('${baseUrl}place_order');
final Uri validatePromoApi = Uri.parse('${baseUrl}validate_promo_code');
final Uri getOrderApi = Uri.parse('${baseUrl}get_orders');
final Uri getOrderInvoiceApi = Uri.parse('${baseUrl}get_invoice_html');
final Uri updateOrderApi = Uri.parse('${baseUrl}update_order_status');
final Uri updateOrderItemApi = Uri.parse('${baseUrl}update_order_item_status');
final Uri paypalTransactionApi = Uri.parse('${baseUrl}get_paypal_link');
final Uri addTransactionApi = Uri.parse('${baseUrl}add_transaction');
final Uri getJwtKeyApi = Uri.parse('${baseUrl}get_jwt_key');
final Uri getOfferImageApi = Uri.parse('${baseUrl}get_offer_images');
final Uri getFaqsApi = Uri.parse('${baseUrl}get_faqs');
final Uri updateFcmApi = Uri.parse('${baseUrl}update_fcm');
final Uri getWalTranApi = Uri.parse('${baseUrl}transactions');
final Uri getPytmChecsumkApi = Uri.parse('${baseUrl}generate_paytm_txn_token');
final Uri deleteOrderApi = Uri.parse('${baseUrl}delete_order');
final Uri getTicketTypeApi = Uri.parse('${baseUrl}get_ticket_types');
final Uri addTicketApi = Uri.parse('${baseUrl}add_ticket');
final Uri editTicketApi = Uri.parse('${baseUrl}edit_ticket');
final Uri sendMsgApi = Uri.parse('${baseUrl}send_message');
final Uri getTicketApi = Uri.parse('${baseUrl}get_tickets');
final Uri validateReferalApi = Uri.parse('${baseUrl}validate_refer_code');
final Uri flutterwaveApi = Uri.parse('${baseUrl}flutterwave_webview');
final Uri getMsgApi = Uri.parse('${baseUrl}get_messages');
final Uri setBankProofApi = Uri.parse('${baseUrl}send_bank_transfer_proof');
final Uri checkDeliverableApi = Uri.parse('${baseUrl}is_product_delivarable');
final Uri checkCartDelApi =
    Uri.parse('${baseUrl}check_cart_products_delivarable');
final Uri getPromoCodeApi = Uri.parse('${baseUrl}get_promo_codes');
final Uri deleteUserApi = Uri.parse('${baseUrl}delete_user');
final Uri getProductFaqsApi = Uri.parse('${baseUrl}get_product_faqs');
final Uri addProductFaqsApi = Uri.parse('${baseUrl}add_product_faqs');
final Uri createRazorpayOrder = Uri.parse('${baseUrl}razorpay_create_order');
final Uri sendWithdrawalRequestApi =
    Uri.parse('${baseUrl}send_withdrawal_request');
final Uri getWithdrawalRequestApi =
    Uri.parse('${baseUrl}get_withdrawal_request');
final Uri getMidtransTransactionStatusApi =
    Uri.parse('${baseUrl}get_midtrans_transaction_status');
final Uri midtransBebhookApi = Uri.parse('${baseUrl}midtrans_webhook');
final Uri createMidtransTransactionApi =
    Uri.parse('${baseUrl}create_midtrans_transaction');
final Uri clearCartApi = Uri.parse('${baseUrl}clear_cart');
final Uri downloadLinkHashApi = Uri.parse('${baseUrl}download_link_hash');
final Uri deleteProductFrmCartApi = Uri.parse('${baseUrl}remove_from_cart');
final Uri checkShipRocketChargesOnProduct =
    Uri.parse('${baseUrl}check_shiprocket_serviceability');
final Uri signUpUserApi = Uri.parse('${baseUrl}sign_up');
final Uri deleteSocialAccApi = Uri.parse('${baseUrl}delete_social_account');
final Uri getInstamojoWebviewApi = Uri.parse('${baseUrl}instamojo_webview');

//Chat apis
final Uri getPersonalChatListApi = Uri.parse('${chatBaseUrl}get_chat_history');
final Uri readMessagesApi = Uri.parse('${chatBaseUrl}mark_msg_read');
final Uri getConverstationApi = Uri.parse('${chatBaseUrl}load_chat');
const String sendMessageApi = '${chatBaseUrl}send_msg';
final Uri searchSellerApi = Uri.parse('${chatBaseUrl}search_user');

final Uri getBrandsApi = Uri.parse('${baseUrl}get_brands_data');
final Uri getPhonePeDetailsApi = Uri.parse('${baseUrl}phonepe_app');

//
const String ISFIRSTTIME = 'isfirst$appName';
const String HISTORYLIST = '$appName+historyList';
const String isLogin = '${appName}isLogin';
const String FCMTOKEN = 'fcmtoken';

//hero tag lable
String heroTagUniqueString =
    'random unique string : ${Random().nextInt(10000)}';
String heroTagUniqueStringForMoreProductList = 'random unique string fore more product: ${Random().nextInt(10000)}';

const String ID = 'id';
const String TYPE = 'type';
const String LINK = 'link';
const String TYPE_ID = 'type_id';
const String IMAGE = 'image';
const String IMGS = 'images[]';
const String ATTACH = 'attachments[]';
const String DOCUMENT = 'documents[]';
const String NAME = 'name';
const String SUBTITLE = 'subtitle';
const String TAX = 'tax';
const String SLUG = 'slug';
const String TITLE = 'title';
const String PRODUCT_DETAIL = 'product_details';
const String DESC = 'description';
const String SUB = 'subject';
const String CATID = 'category_id';
const String CAT_NAME = 'category_name';
const String OTHER_IMAGE = 'other_images_md';
const String PRODUCT_VARIENT = 'variants';
const String PRODUCT_ID = 'product_id';
const String VARIANT_ID = 'variant_id';
const String IS_DELIVERABLE = 'is_deliverable';
const String DELIVERY_BY = 'delivery_by';
const String IS_DETAILED_DATA= 'is_detailed_data';
const String ZIPCODE = 'zipcode';
const String PRICE = 'price';
const String MEASUREMENT = 'measurement';
const String MEAS_UNIT_ID = 'measurement_unit_id';
const String SERVE_FOR = 'serve_for';
const String SHORT_CODE = 'short_code';
const String STOCK = 'stock';
const String STOCK_UNIT_ID = 'stock_unit_id';
const String DIS_PRICE = 'special_price';
const String CURRENCY = 'currency';
const String SUB_ID = 'subcategory_id';
const String SORT = 'sort';
const String PSORT = 'p_sort';
const String ORDER = 'order';
const String PORDER = 'p_order';
const String DEL_CHARGES = 'delivery_charges';
const String FREE_AMT = 'minimum_free_delivery_order_amount';
const String ISFROMBACK = 'isfrombackground$appName';

const String LIMIT = 'limit';
const String OFFSET = 'offset';
const String PRIVACY_POLLICY = 'privacy_policy';
const String TERM_COND = 'terms_conditions';
const String CONTACT_US = 'contact_us';
const String shippingPolicy = 'shipping_policy';
const String returnPolicy = 'return_policy';
const String ABOUT_US = 'about_us';
const String BANNER = 'banner';
const String CAT_FILTER = 'has_child_or_item';
const String PRODUCT_FILTER = 'has_empty_products';
const String RATING = 'rating';
const String IDS = 'ids';
const String VALUE = 'value';
const String ATTRIBUTES = 'attributes';
const String ATTRIBUTE_VALUE_ID = 'attribute_value_ids';
const String IMAGES = 'images';
const String NO_OF_RATE = 'no_of_ratings';
const String ATTR_NAME = 'attr_name';
const String VARIENT_VALUE = 'variant_values';
const String COMMENT = 'comment';
const String MESSAGE = 'message';
const String DATE = 'date_sent';
const String TRN_DATE = 'transaction_date';
const String SEARCH = 'search';
const String PAYMENT_METHOD = 'payment_method';
const String ISWALLETBALUSED = 'is_wallet_used';
const String WALLET_BAL_USED = 'wallet_balance_used';
const String USERDATA = 'user_data';
const String DATE_ADDED = 'date_added';
const String ORDER_ITEMS = 'order_items';
const String TOP_RETAED = 'top_rated_product';
const String WALLET = 'wallet';
const String CREDIT = 'credit';
const String REV_IMG = 'review_images';

const String USER_NAME = 'user_name';
const String USERNAME = 'username';
const String ADDRESS = 'address';
const String EMAIL = 'email';
const String MOBILE = 'mobile';
const String CITY = 'city';
const String DOB = 'dob';
const String AREA = 'area';
const String PASSWORD = 'password';
const String STREET = 'street';
const String PINCODE = 'pincode';
const String FCM_ID = 'fcm_id';
const String LATITUDE = 'latitude';
const String LONGITUDE = 'longitude';
//TODO remove USER_ID
const String USER_ID = 'user_id';
const String userProfileField = 'user_profile';
const String FAV = 'is_favorite';
const String ISRETURNABLE = 'is_returnable';
const String ISCANCLEABLE = 'is_cancelable';
const String ISPURCHASED = 'is_purchased';
const String ISOUTOFSTOCK = 'out_of_stock';
const String PRODUCT_VARIENT_ID = 'product_variant_id';
const String QTY = 'qty';
const String CART_COUNT = 'cart_count';
const String DEL_CHARGE = 'delivery_charge';
const String SUB_TOTAL = 'sub_total';
const String TAX_AMT = 'tax_amount';
const String TAX_PER = 'tax_percentage';
const String CANCLE_TILL = 'cancelable_till';
const String ALT_MOBNO = 'alternate_mobile';
const String STATE = 'state';
const String COUNTRY = 'country';
const String ISDEFAULT = 'is_default';
const String LANDMARK = 'landmark';
const String CITY_ID = 'city_id';
//const String AREA_ID = 'area_id';
const String HOME = 'Home';
const String OFFICE = 'Office';
const String OTHER = 'Other';
const String FINAL_TOTAL = 'final_total';
const String PROMOCODE = 'promo_code';
const String NEWPASS = 'new';
const String OLDPASS = 'old';
const String MOBILENO = 'mobile_no';
const String DELIVERY_TIME = 'delivery_time';
const String DELIVERY_DATE = 'delivery_date';
const String LOCAL_PICKUP = 'local_pickup';
const String QUANTITY = 'quantity';
const String PROMO_DIS = 'promo_discount';
const String WAL_BAL = 'wallet_balance';
const String TOTAL = 'total';
const String TOTAL_PAYABLE = 'total_payable';
const String STATUS = 'status';
const String TOTAL_TAX_PER = 'total_tax_percent';
const String TOTAL_TAX_AMT = 'total_tax_amount';
const String PRODUCT_LIMIT = 'p_limit';
const String PRODUCT_OFFSET = 'p_offset';
const String SEC_ID = 'section_id';
const String COUNTRY_CODE = 'country_code';
const String ATTR_VALUE = 'attr_value_ids';
const String MSG = 'message';
const String ORDER_ID = 'order_id';
const String IS_SIMILAR = 'is_similar_products';
const String ALL = 'all';
const String PLACED = 'received';

const String SHIPED = 'shipped';
const String PROCESSED = 'processed';
const String DELIVERD = 'delivered';
const String CANCLED = 'cancelled';
const String RETURNED = 'returned';
const String RETURN_REQ_PENDING = 'return_request_pending';
const String RETURN_REQ_APPROVED = 'return_request_approved';
const String RETURN_REQ_DECLINE = 'return_request_decline';
const String awaitingPayment = 'Awaiting Payment';
const String ITEM_RETURN = 'Item Return';
const String ITEM_CANCEL = 'Item Cancel';
const String ADD_ID = 'address_id';
const String STYLE = 'style';
const String SHORT_DESC = 'short_description';
const String DEFAULT = 'default';
const String STYLE1 = 'style_1';
const String STYLE2 = 'style_2';
const String STYLE3 = 'style_3';
const String STYLE4 = 'style_4';
const String ORDERID = 'order_id';
const String OTP = 'otp';
const String NOTE = 'notes';
const String TRACKING_ID = 'tracking_id';
const String TRACKING_URL = 'url';
const String COURIER_AGENCY = 'courier_agency';
const String DELIVERY_BOY_ID = 'delivery_boy_id';
const String ISALRCANCLE = 'is_already_cancelled';
const String ISALRRETURN = 'is_already_returned';
const String ISRTNREQSUBMITTED = 'return_request_submitted';
const String OVERALL = 'overall_amount';
const String AVAILABILITY = 'availability';
const String MADEIN = 'made_in';
const String INDICATOR = 'indicator';
const String STOCKTYPE = 'stock_type';
const String SAVE_LATER = 'is_saved_for_later';
const String ATT_VAL = 'attribute_values';
const String ATT_VAL_ID = 'attribute_values_id';
const String FILTERS = 'filters';
const String TOTALALOOW = 'total_allowed_quantity';
const String KEY = 'key';
const String AMOUNT = 'amount';
const String CONTACT = 'contact';
const String TXNID = 'txn_id';
const String SUCCESS = 'Success';
const String ACTIVE_STATUS = 'active_status';
const String WAITING = 'awaiting';
const String TRANS_TYPE = 'transaction_type';
const String QUESTION = 'question';
const String ANSWER = 'answer';
const String INVOICE = 'invoice_html';
const String APP_THEME = 'App Theme';
const String SHORT = 'short_description';
const String FROMTIME = 'from_time';
const String TOTIME = 'last_order_time';
const String REFERCODE = 'referral_code';
const String FRNDCODE = 'friends_code';
const String VIDEO = 'video';
const String VIDEO_TYPE = 'video_type';
const String WARRANTY = 'warranty_period';
const String GAURANTEE = 'guarantee_period';
const String TAG = 'tags';
const String CITYNAME = 'cityName';
const String AREANAME = 'areaName';
const String LAGUAGE_CODE = 'languageCode';
const String MINORDERQTY = 'minimum_order_quantity';
const String QTYSTEP = 'quantity_step_size';
const String DEL_DATE = 'delivery_date';
const String orderRecipientName = 'order_recipient_person';

const String DEL_TIME = 'delivery_time';
const String TOTALIMG = 'total_images';
const String TOTALIMGREVIEW = 'total_reviews_with_images';
const String PRODUCTRATING = 'product_rating';
const String TICKET_TYPE = 'ticket_type_id';
const String DATE_CREATED = 'date_created';
const String DEFAULT_SYSTEM = 'System default';
const String LIGHT = 'Light';
const String DARK = 'Dark';
const String TIC_TYPE = 'ticket_type';
const String TICKET_ID = 'ticket_id';
const String USER_TYPE = 'user_type';
const String USER = 'user';
const String MEDIA = 'media';
const String ICON = 'type';
const String STYPE = 'swatche_type';
const String SVALUE = 'swatche_value';
const String orderAttachments = 'order_attachments';
const String userRating = 'user_rating';
const String userRatingComment = 'user_rating_comment';

const String MINPRICE = 'min_price';
const String MAXPRICE = 'max_price';
const String ZIPCODEID = 'zipcode_id';
const String PROMO_CODE = 'promo_code';
const String REMAIN_DAY = 'remaining_day';
const String PROMO_CODES = 'promo_codes';
const String START_DATE = 'start_date';
const String INSTANT_CASHBACK = 'is_cashback';
const String END_DATE = 'end_date';
const String DISCOUNT = 'discount';
const String MIN_ORDER_AMOUNT = 'min_order_amt';
const String NO_OF_USERS = 'no_of_users';
const String DISCOUNT_TYPE = 'discount_type';
const String NO_OF_REPEAT_USAGE = 'no_of_repeat_usage';
const String REMAINING_DAYS = 'remaining_days';
const String MAX_DISCOUNT_AMOUNT = 'max_discount_amt';

const String REPEAT_USAGE = 'repeat_usage';
const String ORDER_NOTE = 'order_note';

const String SELLER_ID = 'seller_id';
const String SELLER_NAME = 'seller_name';
const String SELLER_PROFILE = 'seller_profile';
const String SELLER_RATING = 'seller_rating';
const String STORE_DESC = 'store_description';
const String STORE_NAME = 'store_name';
const String TOTAL_PRODUCTS = 'total_products';

const String MIN_CART_AMT = 'minimum_cart_amt';

const String ATTACHMENTS = 'attachments';

const String ATTACHMENT = 'attachment';
const String BANK_STATUS = 'banktransfer_status';
const String ALLOW_ATTACH = 'allow_order_attachments';
const String UPLOAD_LIMIT = 'upload_limit';
const String IS_ATTACH_REQ = 'is_attachment_required';
const String COD_ALLOWED = 'cod_allowed';
const String PAYMENT_ADD = 'payment_address';
const String PAYMERNT_TYPE = 'payment_type';
const String AMOUNT_REQUEST = 'amount_requested';
const String Remark = 'remarks';
const String PENDINg = 'Pending';
const String ACCEPTEd = 'Accepted';
const String REJECTEd = 'Rejected';
const String ProductBrandName = 'brand';
const String EXTRA_DESC = 'extra_description';
const String ONLY_DEL_CHARGE = 'only_delivery_charge';
const String DEL_PINCODE = 'delivery_pincode';
const String GOOGLE_TYPE = 'google';
const String APPLE_TYPE = 'apple';
const String PHONE_TYPE = 'phone';
const String GOOGLE_LOGIN = 'google_login';
const String APPLE_LOGIN = 'apple_login';
const String GEN_AREA_NAME = 'general_area_name';
const String SYSTEM_PINCODE = 'system_pincode';
const String tryAgainLabelKey = 'tryAgain';
String personalChatLabelKey = 'PERSONAL_CHAT';
String groupChatLabelKey = 'GROUP_CHAT';

//for product statestics
const String TOTAL_ORDERS = 'total_ordered';
const String TOTAL_FAVOURITES = 'total_favorites';
const String TOTAL_IN_CART = 'total_in_cart';
const String STATISTICS = 'statistics';

//for user's token storage
const String TOKEN = 'token';

String ISDARK = '';
const String PAYPAL_RESPONSE_URL = '$baseUrl' 'app_payment_status';
const String FLUTTERWAVE_RES_URL = '${baseUrl}flutterwave-payment-response';
const String MidTrashAppPaymentStatus = '${baseUrl}app_payment_status';
String? CUR_CURRENCY = '';
String? DECIMAL_POINTS = '2';

//String? CUR_USERID;

String? RETURN_DAYS = '';
String? MAX_ITEMS = '';
//String? REFER_CODE = '';
String? MIN_AMT = '';
String? CUR_DEL_CHR = '';
String? MIN_ALLOW_CART_AMT = '';
String? Is_APP_IN_MAINTANCE = '';
String? MAINTENANCE_MESSAGE = '';
String IS_SHIPROCKET_ON = '';
String IS_LOCAL_ON = '';

String? CUR_TICK_ID = '';
String? ALLOW_ATT_MEDIA = '';
String UP_MEDIA_LIMIT = '';

// for single seller system
String CurrentSellerID = '';
bool singleSellerOrderSystem = false;
bool forLoginPageSingleSellerSystem = false;
bool homePageSingleSellerMessage = false;

bool ISFLAT_DEL = true;
bool extendImg = true;
bool cartBtnList = true;
bool refer = true;

double? deviceHeight;
double? deviceWidth;

String? supportedLocale;

/// EncodingExtensions
extension EncodingExtensions on String {
  /// To Base64
  /// This is used to convert the string to base64
  String get toBase64 {
    return base64.encode(toUtf8);
  }

  /// To Utf8
  /// This is used to convert the string to utf8
  List<int> get toUtf8 {
    return utf8.encode(this);
  }

  /// To Sha256
  /// This is used to convert the string to sha256
  String get toSha256 {
    return sha256.convert(toUtf8).toString();
  }
}
