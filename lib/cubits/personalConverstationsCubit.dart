import 'package:eshop_multivendor/Model/personalChatHistory.dart';
import 'package:eshop_multivendor/repository/chatRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class PersonalConverstationsState {}

class PersonalConverstationsInitial extends PersonalConverstationsState {}

class PersonalConverstationsFetchInProgress
    extends PersonalConverstationsState {}

class PersonalConverstationsFetchSuccess extends PersonalConverstationsState {
  final List<PersonalChatHistory> personalConverstations;

  PersonalConverstationsFetchSuccess({required this.personalConverstations});
}

class PersonalConverstationsFetchFailure extends PersonalConverstationsState {
  final String errorMessage;

  PersonalConverstationsFetchFailure(this.errorMessage);
}

class PersonalConverstationsCubit extends Cubit<PersonalConverstationsState> {
  final ChatRepository _chatRepository;

  PersonalConverstationsCubit(this._chatRepository)
      : super(PersonalConverstationsInitial());

  void fetchConverstations({required String currentUserId}) async {
    emit(PersonalConverstationsFetchInProgress());
    try {
      final result = await _chatRepository
          .getConverstationList(parameter: {});
      result.removeWhere((e) => e.id == null);
      emit(PersonalConverstationsFetchSuccess(personalConverstations: result));
    } catch (e) {
      emit(PersonalConverstationsFetchFailure(e.toString()));
    }
  }

  void updateUnreadMessageCounter({required String userId}) {
    if (state is PersonalConverstationsFetchSuccess) {
      List<PersonalChatHistory> personalConverstations =
          (state as PersonalConverstationsFetchSuccess).personalConverstations;
      final index = personalConverstations
          .indexWhere((element) => element.opponentUserId == userId);
      if (index != -1) {
        final chatHistory = personalConverstations[index];
        personalConverstations[index] = chatHistory.copyWith(
            unreadMsg:
                (int.parse(chatHistory.unreadMsg ?? '0') + 1).toString());

        emit(PersonalConverstationsFetchSuccess(
            personalConverstations: personalConverstations));
      }
    }
  }

  void updatePersonalChatHistory(
      {required PersonalChatHistory personalChatHistory}) {
    if (state is PersonalConverstationsFetchSuccess) {
      List<PersonalChatHistory> personalConverstations =
          (state as PersonalConverstationsFetchSuccess).personalConverstations;
      final index = personalConverstations.indexWhere((element) =>
          element.opponentUserId == personalChatHistory.opponentUserId);
      if (index != -1) {
        personalConverstations[index] = personalChatHistory;
        emit(PersonalConverstationsFetchSuccess(
            personalConverstations: personalConverstations));
      }
    }
  }

  void addPersonalChatHistory(
      {required PersonalChatHistory personalChatHistory}) {
    if (state is PersonalConverstationsFetchSuccess) {
      List<PersonalChatHistory> personalConverstations =
          (state as PersonalConverstationsFetchSuccess).personalConverstations;
      personalConverstations.add(personalChatHistory);
      emit(PersonalConverstationsFetchSuccess(
          personalConverstations: personalConverstations));
    }
  }
}
