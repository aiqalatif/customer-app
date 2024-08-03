import 'package:eshop_multivendor/Helper/Constant.dart';
import 'package:eshop_multivendor/Model/message.dart';
import 'package:eshop_multivendor/repository/chatRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ConverstationState {}

class ConverstationInitial extends ConverstationState {}

class ConverstationFetchInProgress extends ConverstationState {}

class ConverstationFetchSuccess extends ConverstationState {
  final int total;
  final List<Message> messages;
  final bool fetchMoreError;
  final bool fetchMoreInProgress;

  ConverstationFetchSuccess(
      {required this.messages,
      required this.fetchMoreError,
      required this.fetchMoreInProgress,
      required this.total});

  ConverstationFetchSuccess copyWith(
      {bool? fetchMoreError,
      bool? fetchMoreInProgress,
      int? total,
      List<Message>? messages}) {
    return ConverstationFetchSuccess(
      total: total ?? this.total,
      messages: messages ?? this.messages,
      fetchMoreError: fetchMoreError ?? this.fetchMoreError,
      fetchMoreInProgress: fetchMoreInProgress ?? this.fetchMoreInProgress,
    );
  }
}

class ConverstationFetchFailure extends ConverstationState {
  final String errorMessage;

  ConverstationFetchFailure(this.errorMessage);
}

class ConverstationCubit extends Cubit<ConverstationState> {
  final ChatRepository _chatRepository;

  ConverstationCubit(this._chatRepository) : super(ConverstationInitial());

  void fetchConverstation(
      {required bool isGroup,
      required String fromUserId,
      required String toId //This will be user's id or current user id
      }) async {
    emit(ConverstationFetchInProgress());
    try {
      final result = await _chatRepository.getConverstation(parameter: {
        'type': isGroup ? 'group' : 'person',
        'to_id': toId,
        'from_id': fromUserId,
        'limit': messagesLoadLimit
      });

      emit(ConverstationFetchSuccess(
          messages: List.from(result['messages']),
          fetchMoreError: false,
          fetchMoreInProgress: false,
          total: result['total'] as int));
    } catch (e) {
      emit(ConverstationFetchFailure(e.toString()));
    }
  }

  bool hasMore() {
    if (state is ConverstationFetchSuccess) {
      return (state as ConverstationFetchSuccess).messages.length <
          (state as ConverstationFetchSuccess).total;
    }
    return false;
  }

  void fetchMore({
    required bool isGroup,
    required String fromUserId,
    required String toId, //This will be user's id or current user id
  }) async {
    //
    if (state is ConverstationFetchSuccess) {
      if ((state as ConverstationFetchSuccess).fetchMoreInProgress) {
        return;
      }
      try {
        emit((state as ConverstationFetchSuccess)
            .copyWith(fetchMoreInProgress: true));

        final moreMessages = await _chatRepository.getConverstation(parameter: {
          'type': isGroup ? 'group' : 'person',
          'to_id': toId,
          'from_id': fromUserId,
          'limit': messagesLoadLimit,
          'offset':
              (state as ConverstationFetchSuccess).messages.length.toString()
        });

        final currentState = (state as ConverstationFetchSuccess);
        List<Message> messages = currentState.messages;
        for (var message in moreMessages['messages'] as List<Message>) {
          if (messages.indexWhere((element) => element.id == message.id) ==
              -1) {
            messages.add(message);
          }
        }

        emit(ConverstationFetchSuccess(
          fetchMoreError: false,
          fetchMoreInProgress: false,
          total: moreMessages['total'] as int,
          messages: messages,
        ));
      } catch (e) {
        emit((state as ConverstationFetchSuccess)
            .copyWith(fetchMoreInProgress: false, fetchMoreError: true));
      }
    }
  }

  List<Message> getMessages() {
    if (state is ConverstationFetchSuccess) {
      List<Message> chatMessages =
          (state as ConverstationFetchSuccess).messages;
      chatMessages.sort((a, b) => DateTime.parse(b.dateCreated!)
          .compareTo(DateTime.parse(a.dateCreated!)));

      return chatMessages;
    }
    return [];
  }

  List<String> getMessageDates() {
    if (state is ConverstationFetchSuccess) {
      List<String> dates = getMessages()
          .map((e) =>
              formatDateYYMMDD(dateTime: DateTime.parse(e.dateCreated ?? '')))
          .toList();

      dates = dates.toSet().toList();

      return dates;
    }
    return [];
  }

  

  List<Message> getMessagesByDate({required String dateTime}) {
    if (state is ConverstationFetchSuccess) {
      List<Message> messages = getMessages()
          .where((element) => isSameDay(
              dateTime: DateTime.parse(element.dateCreated!),
              takeCurrentDate: false,
              givenDate: DateTime.parse(dateTime)))
          .toList();

      return messages.reversed.toList();
    }
    return [];
  }

  void addMessage({required Message message}) {
    if (state is ConverstationFetchSuccess) {
      List<Message> messages = (state as ConverstationFetchSuccess).messages;

      messages.insert(0, message);
      emit((state as ConverstationFetchSuccess).copyWith(messages: messages));
    }
  }
}
