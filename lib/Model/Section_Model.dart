import 'package:eshop_multivendor/Model/User.dart';
import '../Helper/String.dart';

class SectionModel {
  String? id,
      title,
      varientId,
      qty,
      productId,
      perItemTotal,
      perItemPrice,
      singleItemNetAmount,
      productType,
      singleIteamSubTotal,
      singleItemTaxAmount,
      style,
      sellerId,
      shortDesc;
  double? perItemTaxPriceOnItemsTotal,
      perItemTaxPriceOnItemAmount,
      perItemTaxPercentage = 0.0;
      
  List<Product>? productList;
  List<Promo>? promoList;
  List<Filter>? filterList;
  List<String>? selectedId = [];
  int? offset, totalItem;

  SectionModel({
    this.id,
    this.title,
    this.shortDesc,
    this.productList,
    this.varientId,
    this.qty,
    this.productId,
    this.perItemTotal,
    this.perItemPrice,
    this.style,
    this.totalItem,
    this.sellerId,
    this.offset,
    this.selectedId,
    this.filterList,
    this.singleItemTaxAmount,
    this.singleItemNetAmount,
    this.singleIteamSubTotal,
    this.promoList,
    this.productType,
  });

  factory SectionModel.fromJson(Map<String, dynamic> parsedJson) {
    List<Product> productList = (parsedJson[PRODUCT_DETAIL] as List)
        .map((data) => Product.fromJson(data))
        .toList();

    var flist = (parsedJson[FILTERS] as List?);
    List<Filter> filterList = [];
    if (flist == null || flist.isEmpty) {
      filterList = [];
    } else {
      filterList = flist.map((data) => Filter.fromJson(data)).toList();
    }
    List<String> selected = [];
    return SectionModel(
        id: parsedJson[ID],
        sellerId: parsedJson[SELLER_ID],
        title: parsedJson[TITLE],
        shortDesc: parsedJson[SHORT_DESC],
        style: parsedJson[STYLE],
        productList: productList,
        offset: 0,
        totalItem: 0,
        filterList: filterList,
        selectedId: selected);
  }

  factory SectionModel.fromCart(Map<String, dynamic> parsedJson) {
    List<Product> productList = (parsedJson[PRODUCT_DETAIL] as List)
        .map((data) => Product.fromJson(data))
        .toList();
    return SectionModel(
        id: parsedJson[ID],
        varientId: parsedJson[PRODUCT_VARIENT_ID],
        qty: parsedJson[QTY],
        sellerId: parsedJson['product_details'][0]['seller_id'].toString(),
        perItemTotal: '0',
        perItemPrice: '0',
        productList: productList,
        singleItemNetAmount: parsedJson['net_amount'].toString(),
        productType: parsedJson['type'],
        singleIteamSubTotal: parsedJson['sub_total'].toString(),
        singleItemTaxAmount: parsedJson['tax_amount'].toString());
  }

  factory SectionModel.fromFav(Map<String, dynamic> parsedJson) {
    List<Product> productList = (parsedJson[PRODUCT_DETAIL] as List)
        .map((data) => Product.fromJson(data))
        .toList();

    return SectionModel(
        id: parsedJson[ID],
        productId: parsedJson[PRODUCT_ID],
        sellerId: parsedJson[SELLER_ID],
        productList: productList);
  }

  copyWith({
    String? id,
    String? title,
    String? shortDesc,
    List<Product>? productList,
    String? varientId,
    String? qty,
    String? productId,
    String? perItemTotal,
    String? perItemPrice,
    String? style,
    int? totalItem,
    String? sellerId,
    int? offset,
    List<String>? selectedId,
    List<Filter>? filterList,
    String? singleItemTaxAmount,
    String? singleItemNetAmount,
    String? singleIteamSubTotal,
    List<Promo>? promoList,
    String? productType,
  }) {
    return SectionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      shortDesc: shortDesc ?? this.shortDesc,
      productList: productList ?? this.productList,
      varientId: varientId ?? this.varientId,
      qty: qty ?? this.qty,
      productId: productId ?? this.productId,
      perItemTotal: perItemTotal ?? this.perItemTotal,
      perItemPrice: perItemPrice ?? this.perItemPrice,
      style: style ?? this.style,
      totalItem: totalItem ?? this.totalItem,
      sellerId: sellerId ?? this.sellerId,
      offset: offset ?? this.offset,
      selectedId: selectedId ?? this.selectedId,
      filterList: filterList ?? this.filterList,
      singleItemTaxAmount: singleItemTaxAmount ?? this.singleItemTaxAmount,
      singleItemNetAmount: singleItemNetAmount ?? this.singleItemNetAmount,
      singleIteamSubTotal: singleIteamSubTotal ?? this.singleIteamSubTotal,
      promoList: promoList ?? this.promoList,
      productType: productType ?? this.productType,
    );
  }
}

class Product {
  String? id,
      name,
      desc,
      image,
      catName,
      type,
      rating,
      noOfRating,
      attrIds,
      tax,
      categoryId,
      shortDescription,
      codAllowed,
      brandName,
      qtyStepSize,
      extraDesc,
      productType;
  List<String>? itemsCounter;
  List<String>? otherImage;
  List<Product_Varient>? prVarientList;
  List<Attribute>? attributeList;
  List<String>? selectedId = [];
  List<String>? tagList = [];
  int? minOrderQuntity;
  String? isFav,
      isReturnable,
      isCancelable,
      isPurchased,
      availability,
      madein,
      indicator,
      stockType,
      cancleTill,
      total,
      banner,
      totalAllow,
      video,
      videType,
      warranty,
      gurantee,
      is_attch_req;

  String? minPrice, maxPrice;
  String? totalImg;
  List<ReviewImg>? reviewList;

  bool? isFavLoading = false, isFromProd = false;
  int? offset, totalItem, selVarient;

  List<Product>? subList;
  List<Filter>? filterList;
  bool? history = false;
  String? store_description,
      seller_rating,
      noOfRatingsOnSeller,
      seller_profile,
      seller_name,
      seller_id,
      store_name,
      totalProductsOfSeller;

  Product({
    this.id,
    this.name,
    this.desc,
    this.image,
    this.catName,
    this.type,
    this.otherImage,
    this.prVarientList,
    this.attributeList,
    this.isFav,
    this.isCancelable,
    this.isReturnable,
    this.isPurchased,
    this.availability,
    this.noOfRating,
    this.attrIds,
    this.selectedId,
    this.rating,
    this.isFavLoading,
    this.indicator,
    this.madein,
    this.tax,
    this.shortDescription,
    this.total,
    this.brandName,
    this.categoryId,
    this.subList,
    this.filterList,
    this.stockType,
    this.isFromProd,
    this.cancleTill,
    this.totalItem,
    this.offset,
    this.totalAllow,
    this.banner,
    this.selVarient,
    this.video,
    this.videType,
    this.tagList,
    this.warranty,
    this.qtyStepSize,
    this.minOrderQuntity,
    this.itemsCounter,
    this.reviewList,
    this.history,
    this.minPrice,
    this.maxPrice,
    this.totalProductsOfSeller,
    this.codAllowed,
    this.gurantee,
    this.store_description,
    this.seller_rating,
    this.noOfRatingsOnSeller,
    this.seller_profile,
    this.seller_name,
    this.seller_id,
    this.store_name,
    this.is_attch_req,
    this.extraDesc,
    this.productType,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    List<Product_Varient> varientList = (json[PRODUCT_VARIENT] as List)
        .map((data) => Product_Varient.fromJson(data))
        .toList();

    List<Attribute> attList = json[ATTRIBUTES] != null
    ? (json[ATTRIBUTES] as List)
        .map((data) => Attribute.fromJson(data))
        .toList()
    : List<Attribute>.from([]);
   

    var flist = (json[FILTERS] as List?);
    List<Filter> filterList = [];
    if (flist == null || flist.isEmpty) {
      filterList = [];
    } else {
      filterList = flist.map((data) => Filter.fromJson(data)).toList();
    }

    List<String> otherImage = List<String>.from(json[OTHER_IMAGE]);
    List<String> selected = [];

    List<String> tags = List<String>.from(json[TAG]);

    List<String> items = List<String>.generate(
        json[TOTALALOOW] != ''
            ? double.parse(json[TOTALALOOW]) ~/ double.parse(json[QTYSTEP])
            : 10, (i) {
      return ((i + 1) * int.parse(json[QTYSTEP])).toString();
    });

    var reviewImg = json[REV_IMG] == null
    ? []
    : (json[REV_IMG] as List?);

    List<ReviewImg> reviewList = [];
    if (reviewImg == null || reviewImg.isEmpty) {
      reviewList = [];
    } else {
      reviewList = reviewImg.map((data) => ReviewImg.fromJson(data)).toList();
    }

    return Product(
        id: json[ID],
        name: json[NAME],
        desc: json[DESC],
        image: json[IMAGE],
        catName: json[CAT_NAME],
        rating: json[RATING],
        noOfRating: json[NO_OF_RATE],
        type: json[TYPE],
        isFav: json[FAV].toString(),
        isCancelable: json[ISCANCLEABLE],
        availability: json[AVAILABILITY].toString(),
        isPurchased: json[ISPURCHASED].toString(),
        isReturnable: json[ISRETURNABLE],
        otherImage: otherImage,
        prVarientList: varientList,
        attributeList: attList,
        filterList: filterList,
        isFavLoading: false,
        selVarient: 0,
        attrIds: json[ATTR_VALUE],
        madein: json[MADEIN],
        shortDescription: json[SHORT],
        extraDesc: json[EXTRA_DESC],
        indicator: json[INDICATOR].toString(),
        stockType: json[STOCKTYPE].toString(),
        tax: json[TAX_PER],
        total: json[TOTAL],
        categoryId: json[CATID],
        selectedId: selected,
        totalAllow: json[TOTALALOOW],
        cancleTill: json[CANCLE_TILL],
        video: json[VIDEO],
        videType: json[VIDEO_TYPE],
        tagList: tags,
        itemsCounter: items,
        warranty: json[WARRANTY],
        minOrderQuntity: int.parse(json[MINORDERQTY]),
        qtyStepSize: json[QTYSTEP],
        gurantee: json[GAURANTEE],
        reviewList: reviewList,
        history: false,
        minPrice: json[MINPRICE],
        maxPrice: json[MAXPRICE],
        seller_name: json[SELLER_NAME],
        seller_profile: json[SELLER_PROFILE],
        seller_rating: json[SELLER_RATING],
        store_description: json[STORE_DESC],
        totalProductsOfSeller: json['total_products'] ?? '',
        store_name: json[STORE_NAME],
        seller_id: json[SELLER_ID],
        is_attch_req: json[IS_ATTACH_REQ],
        codAllowed: json[COD_ALLOWED],
        brandName: json[ProductBrandName],
        noOfRatingsOnSeller: json['seller_no_of_ratings'],
        productType: json[TYPE]);
  }

  factory Product.all(String name, String img, cat) {
    return Product(name: name, catName: cat, image: img, history: false);
  }

  factory Product.history(String history) {
    return Product(name: history, history: true);
  }

  factory Product.fromSeller(Map<String, dynamic> json) {
    return Product(
      seller_name: json[SELLER_NAME],
      seller_profile: json[SELLER_PROFILE],
      seller_rating: json[SELLER_RATING],
      noOfRatingsOnSeller: json[NO_OF_RATE],
      store_description: json[STORE_DESC],
      store_name: json[STORE_NAME],
      totalProductsOfSeller: json['total_products'],
      seller_id: json[SELLER_ID],
    );
  }

  factory Product.fromCat(Map<String, dynamic> parsedJson) {
    return Product(
      id: parsedJson[ID],
      name: parsedJson[NAME],
      image: parsedJson[IMAGE],
      banner: parsedJson[BANNER],
      isFromProd: false,
      offset: 0,
      totalItem: 0,
      tax: parsedJson[TAX],
      subList: createSubList(
        parsedJson['children'],
      ),
    );
  }

  factory Product.popular(String name, String image) {
    return Product(name: name, image: image);
  }

  static List<Product>? createSubList(List? parsedJson) {
    if (parsedJson == null || parsedJson.isEmpty) return null;

    return parsedJson.map((data) => Product.fromCat(data)).toList();
  }
}

class Product_Varient {
  String? id,
      productId,
      attribute_value_ids,
      price,
      disPrice,
      type,
      attr_name,
      varient_value,
      availability,
      cartCount;
  ProductStatistics? productStatistics; //only in product details
  List<String>? images;

  Product_Varient({
    this.id,
    this.productId,
    this.attr_name,
    this.varient_value,
    this.price,
    this.disPrice,
    this.attribute_value_ids,
    this.availability,
    this.cartCount,
    this.images,
    this.productStatistics,
  });

  factory Product_Varient.fromJson(Map<String, dynamic> json) {
    List<String> images = List<String>.from(json[IMAGES]);

    return Product_Varient(
      id: json[ID],
      attribute_value_ids: json[ATTRIBUTE_VALUE_ID],
      productId: json[PRODUCT_ID],
      attr_name: json[ATTR_NAME],
      varient_value: json[VARIENT_VALUE],
      disPrice: json[DIS_PRICE],
      price: json[PRICE],
      availability: json[AVAILABILITY].toString(),
      cartCount: json[CART_COUNT],
      images: images,
      productStatistics: ProductStatistics.fromJson(
          (json[STATISTICS] == null || json[STATISTICS].isEmpty)
              ? {}
              : json[STATISTICS] ?? {}),
    );
  }
}

class Attribute {
  String? id, value, name, sType, sValue;

  Attribute({this.id, this.value, this.name, this.sType, this.sValue});

  factory Attribute.fromJson(Map<String, dynamic> json) {
    return Attribute(
      id: json[IDS],
      name: json[NAME],
      value: json[VALUE],
      sType: json[STYPE],
      sValue: json[SVALUE],
    );
  }
}

class Filter {
  String? attributeValues, attributeValId, name, swatchType, swatchValue;

  Filter({
    this.attributeValues,
    this.attributeValId,
    this.name,
    this.swatchType,
    this.swatchValue,
  });

  factory Filter.fromJson(Map<String, dynamic> json) {
    return Filter(
      attributeValId: json[ATT_VAL_ID],
      name: json[NAME],
      attributeValues: json[ATT_VAL],
      swatchType: json[STYPE],
      swatchValue: json[SVALUE],
    );
  }
}

class ReviewImg {
  String? totalImg;
  List<User>? productRating;

  ReviewImg({this.totalImg, this.productRating});

  factory ReviewImg.fromJson(Map<String, dynamic> json) {
    var reviewImg = (json[PRODUCTRATING] as List?);
    List<User> reviewList = [];
    if (reviewImg == null || reviewImg.isEmpty) {
      reviewList = [];
    } else {
      reviewList = reviewImg.map((data) => User.forReview(data)).toList();
    }

    return ReviewImg(
      totalImg: json[TOTALIMG],
      productRating: reviewList,
    );
  }
}

class Promo {
  String? id,
      promoCode,
      message,
      image,
      remainingDays,
      status,
      noOfRepeatUsage,
      maxDiscountAmt,
      discountType,
      noOfUsers,
      minOrderAmt,
      repeatUsage,
      discount,
      endDate,
      isInstantCashback,
      startDate;
  bool isExpanded;

  Promo({
    this.id,
    this.promoCode,
    this.message,
    this.startDate,
    this.endDate,
    this.discount,
    this.repeatUsage,
    this.minOrderAmt,
    this.noOfUsers,
    this.discountType,
    this.maxDiscountAmt,
    this.image,
    this.noOfRepeatUsage,
    this.status,
    this.remainingDays,
    this.isInstantCashback,
    this.isExpanded = false,
  });

  factory Promo.fromJson(Map<String, dynamic> json) {
    return Promo(
      id: json[ID],
      promoCode: json[PROMO_CODE],
      message: json[MESSAGE],
      image: json[IMAGE],
      remainingDays: json[REMAIN_DAY],
      discount: json[DISCOUNT],
      discountType: json[DISCOUNT_TYPE],
      endDate: json[END_DATE],
      maxDiscountAmt: json[MAX_DISCOUNT_AMOUNT],
      minOrderAmt: json[MIN_ORDER_AMOUNT],
      noOfRepeatUsage: json[NO_OF_REPEAT_USAGE],
      noOfUsers: json[NO_OF_USERS],
      repeatUsage: json[REPEAT_USAGE],
      startDate: json[START_DATE],
      isInstantCashback: json[INSTANT_CASHBACK],
      status: json[STATUS],
    );
  }
}

//statistics for product details
class ProductStatistics {
  final String totalOrders;
  final String totalFavourites;
  final String totalInCart;

  ProductStatistics(
      {required this.totalOrders,
      required this.totalFavourites,
      required this.totalInCart});

  factory ProductStatistics.fromJson(Map<String, dynamic> json) {
    return ProductStatistics(
        totalOrders: json[TOTAL_ORDERS]?.toString() ?? '0',
        totalFavourites: json[TOTAL_FAVOURITES]?.toString() ?? '0',
        totalInCart: json[TOTAL_IN_CART]?.toString() ?? '0');
  }
}
