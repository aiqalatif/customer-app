import 'package:intl/intl.dart';
import '../Helper/String.dart';

class OrderModel {
  String? id,
      name,
      mobile,
      delCharge,
      email,
      walBal,
      promo,
      promoDis,
      payMethod,
      total,
      subTotal,
      taxAmount,
      payable,
      address,
      taxPer,
      orderDate,
      dateTime,
      isCancleable,
      isReturnable,
      isAlrCancelled,
      isAlrReturned,
      rtnReqSubmitted,
      activeStatus,
      otp,
      deliveryBoyId,
      delDate,
      delTime,
      userAddressName,
      note;

  List<Attachment>? attachList = [];
  List<OrderItem>? itemList;
  List<String> listStatus = [];
  List<String?>? listDate = [];

  OrderModel({
    this.id,
    this.name,
    this.mobile,
    this.delCharge,
    this.walBal,
    this.promo,
    this.promoDis,
    this.payMethod,
    this.total,
    this.subTotal,
    this.email,
    this.taxAmount,
    this.payable,
    this.address,
    this.taxPer,
    this.orderDate,
    this.dateTime,
    this.itemList,
    required this.listStatus,
    this.listDate,
    this.isReturnable,
    this.isCancleable,
    this.isAlrCancelled,
    this.isAlrReturned,
    this.rtnReqSubmitted,
    this.activeStatus,
    this.otp,
    this.delDate,
    this.delTime,
    this.deliveryBoyId,
    this.attachList,
    this.userAddressName,
    this.note,
  });

  factory OrderModel.fromJson(Map<String, dynamic> parsedJson) {
    List<OrderItem> itemList = [];
    var order = (parsedJson[ORDER_ITEMS] as List?);

    if (order!.isEmpty) {
      itemList = [];
    } else {
      itemList = order.map((data) => OrderItem.fromJson(data)).toList();
    }
    String date = parsedJson[DATE_ADDED];
    date = DateFormat('dd-MM-yyyy').format(DateTime.parse(date));

    List<Attachment> attachmentList = [];
    List attachments = [];
    if (parsedJson[ATTACHMENTS] != '') attachments = parsedJson[ATTACHMENTS];

    attachmentList =
        attachments.map((data) => Attachment.fromJson(data)).toList();

    return OrderModel(
      id: parsedJson[ID],
      name: parsedJson[USERNAME],
      mobile: parsedJson[MOBILE],
      delCharge: parsedJson[DEL_CHARGE],
      walBal: parsedJson[WAL_BAL],
      promo: parsedJson[PROMOCODE],
      promoDis: parsedJson[PROMO_DIS],
      email: parsedJson['email'],
      payMethod: parsedJson[PAYMENT_METHOD],
      total: parsedJson[FINAL_TOTAL],
      subTotal: parsedJson[TOTAL],
      taxAmount: parsedJson['total_tax_amount'],
      payable: parsedJson[TOTAL_PAYABLE],
      address: parsedJson[ADDRESS] ?? '',
      taxPer: parsedJson[TOTAL_TAX_PER],
      dateTime: parsedJson[DATE_ADDED],
      isCancleable: parsedJson[ISCANCLEABLE],
      isReturnable: parsedJson[ISRETURNABLE],
      isAlrCancelled: parsedJson[ISALRCANCLE],
      isAlrReturned: parsedJson[ISALRRETURN],
      rtnReqSubmitted: parsedJson[ISRTNREQSUBMITTED],
      orderDate: date,
      itemList: itemList,
      activeStatus: parsedJson[ACTIVE_STATUS],
      otp: parsedJson[OTP],
      delDate: parsedJson[DEL_DATE] != ''
          ? DateFormat('dd-MM-yyyy')
              .format(DateTime.parse(parsedJson[DEL_DATE]))
          : '',
      delTime: parsedJson[DEL_TIME] != '' ? parsedJson[DEL_TIME] : '',
      deliveryBoyId: parsedJson[DELIVERY_BOY_ID],
      attachList: attachmentList,
      listStatus: [],
      userAddressName: parsedJson[orderRecipientName],
      note: parsedJson[NOTE],
    );
  }
}

class OrderItem {
  String? id,
      name,
      qty,
      price,
      subTotal,
      status,
      image,
      varientId,
      isCancle,
      isReturn,
      isAlrCancelled,
      isAlrReturned,
      rtnReqSubmitted,
      varient_values,
      attr_name,
      productId,
      productType,
      item_otp,
      store_description,
      seller_rating,
      seller_no_of_ratings,
      seller_profile,
      seller_name,
      seller_id,
      store_name,
      courier_agency,
      tracking_id,
      tracking_url,
      downloadAllowed,
      downloadLink,
      userReviewRating,
      userReviewComment,
      canclableTill;

  List<String>? listStatus = [];
  List<String>? listDate = [];
  bool isExpanded;

  OrderItem(
      {this.qty,
      this.id,
      this.name,
      this.price,
      this.subTotal,
      this.status,
      this.image,
      this.varientId,
      this.listDate,
      this.listStatus,
      this.isCancle,
      this.productType,
      this.isReturn,
      this.isAlrReturned,
      this.isAlrCancelled,
      this.rtnReqSubmitted,
      this.attr_name,
      this.productId,
      this.item_otp,
      this.varient_values,
      this.store_description,
      this.seller_rating,
      this.seller_no_of_ratings,
      this.seller_profile,
      this.seller_name,
      this.downloadAllowed,
      this.downloadLink,
      this.seller_id,
      this.store_name,
      this.courier_agency,
      this.tracking_id,
      this.tracking_url,
      this.userReviewComment,
      this.userReviewRating,
      this.isExpanded = true,
      this.canclableTill});

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    List<String>? lStatus = [];
    List<String>? lDate = [];

    var allSttus = json[STATUS];
    for (var curStatus in allSttus) {
      lStatus.add(curStatus[0]);
      lDate.add(curStatus[1]);
    }
    return OrderItem(
      id: json[ID],
      qty: json[QUANTITY],
      name: json[NAME],
      image: json[IMAGE],
      price: json[PRICE],
      subTotal: json[SUB_TOTAL],
      varientId: json[PRODUCT_VARIENT_ID],
      listStatus: lStatus,
      status: json[ACTIVE_STATUS],
      listDate: lDate,
      isCancle: json[ISCANCLEABLE],
      isReturn: json[ISRETURNABLE],
      isAlrCancelled: json[ISALRCANCLE],
      isAlrReturned: json[ISALRRETURN],
      rtnReqSubmitted: json[ISRTNREQSUBMITTED],
      attr_name: json[ATTR_NAME],
      productId: json[PRODUCT_ID],
      varient_values: json[VARIENT_VALUE],
      item_otp: json[OTP],
      seller_name: json[SELLER_NAME],
      seller_profile: json[SELLER_PROFILE],
      seller_rating: json[SELLER_RATING],
      seller_no_of_ratings: json['seller_no_of_ratings'] ?? '',
      store_description: json[STORE_DESC],
      store_name: json[STORE_NAME],
      seller_id: json[SELLER_ID],
      courier_agency: json[COURIER_AGENCY] ?? '',
      tracking_id: json[TRACKING_ID] ?? '',
      tracking_url: json[TRACKING_URL] ?? '',
      userReviewComment: json[userRatingComment],
      userReviewRating: json[userRating],
      productType: json['type'],
      downloadAllowed: json['download_allowed'],
      downloadLink: json['download_link'],
      canclableTill: json[CANCLE_TILL],
    );
  }
}

class Attachment {
  String? id, attachment, bankTranStatus;

  Attachment({
    this.id,
    this.attachment,
    this.bankTranStatus,
  });

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      id: json[ID],
      attachment: json[ATTACHMENT],
      bankTranStatus: json[BANK_STATUS],
    );
  }
}
