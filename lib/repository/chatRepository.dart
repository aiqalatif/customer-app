import 'package:dio/dio.dart';
import 'package:eshop_multivendor/Model/message.dart';
import 'package:eshop_multivendor/Model/personalChatHistory.dart';
import 'package:eshop_multivendor/widgets/security.dart';
import 'package:flutter/foundation.dart';

import '../Helper/ApiBaseHelper.dart';
import '../Helper/Constant.dart';
import '../Helper/String.dart';

class ChatRepository {
  ///SetSave For Latter Product .
  static Future<Map<String, dynamic>> getMsgAPi({
    required Map<String, dynamic> parameter,
  }) async {
    try {
      var result = await ApiBaseHelper().postAPICall(getMsgApi, parameter);

      return result;
    } on Exception catch (e) {
      throw ApiException('$errorMesaage${e.toString()}');
    }
  }

  Future<List<PersonalChatHistory>> getConverstationList({
    required Map<String, dynamic> parameter,
  }) async {
    try {
      var result =
          await ApiBaseHelper().postAPICall(getPersonalChatListApi, parameter);

      if (result['error']) {
        throw ApiException(
            result['error_msg'] ?? 'Failed to load converstations');
      }

      return ((result['data'] ?? []) as List)
          .map((personalChat) =>
              PersonalChatHistory.fromJson(Map.from(personalChat ?? {})))
          .toList();
    } on Exception catch (e) {
      throw ApiException(e.toString());
    }
  }

  static Future<void> readMessages(
      {required bool isGroup,
      required String fromId,
      required String userId}) async {
    try {
      if (kDebugMode) {
        print({
          'type': isGroup ? 'group' : 'person',
          'from_id': fromId,
          'user_id': userId
        });
      }
      final result = await ApiBaseHelper().postAPICall(readMessagesApi, {
        'type': isGroup ? 'group' : 'person',
        'from_id': fromId,
        // 'user_id': userId
      });
      if (kDebugMode) {
        print('Result of the read message : $result');
      }
    } on Exception catch (e) {
      throw ApiException('$errorMesaage${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> getConverstation({
    required Map<String, dynamic> parameter,
  }) async {
    try {
      final result =
          await ApiBaseHelper().postAPICall(getConverstationApi, parameter);

      if (result['error']) {
        throw ApiException(result['error_msg'] ?? 'Failed to load messages');
      }

      return {
        'total': int.parse((result['data']['total_msg'] ?? '0').toString()),
        'messages': ((result['data']['msg'] ?? []) as List)
            .map((message) => Message.fromJson(Map.from(message ?? {})))
            .toList()
      };
    } on Exception catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<Message> sendMessage({
    required Map<String, dynamic> parameter,
  }) async {
    try {
      if (kDebugMode) {
        print('Api : $sendMessageApi');
        print(parameter);
      }
      final result = await Dio().post(sendMessageApi,
          options: Options(headers: headers),
          data: FormData.fromMap(parameter, ListFormat.multiCompatible));
      if (result.data['error']) {
        throw ApiException('Failed to send message');
      }

      return Message.fromJson(
          Map.from((result.data['new_msg'] as List).first ?? {}));
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) {
        throw ApiException('No Internet connection');
      }

      throw ApiException('Failed to send message');
    } on Exception catch (e) {
      throw ApiException(e.toString());
    }
  }
}
