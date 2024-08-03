import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Provider/CartProvider.dart';

cartTotalClear(BuildContext context) {
  //removebecaus issue in cart
  //context.read<CartProvider>().totalPrice = 0;
  context.read<CartProvider>().taxPer = 0;
  context.read<CartProvider>().deliveryCharge = 0;
  context.read<CartProvider>().addressList.clear();
  context.read<CartProvider>().promoAmt = 0;
  context.read<CartProvider>().remWalBal = 0;
  context.read<CartProvider>().usedBalance = 0;
  context.read<CartProvider>().payMethod = null;
  context.read<CartProvider>().isPromoValid = false;
  context.read<CartProvider>().isPromoLen = false;
  context.read<CartProvider>().isUseWallet = false;
  context.read<CartProvider>().isPayLayShow = true;
  context.read<CartProvider>().selectedMethod = null;
  context.read<CartProvider>().selectedTime = null;
  context.read<CartProvider>().selectedDate = null;
  context.read<CartProvider>().selAddress = '';
  context.read<CartProvider>().selTime = '';
  context.read<CartProvider>().selDate = '';
  context.read<CartProvider>().promocode = '';

}
