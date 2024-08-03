import 'package:eshop_multivendor/Model/searchedSeller.dart';
import 'package:eshop_multivendor/repository/sellerDetailRepositry.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class SearchSellerState {}

class SearchSellerInitial extends SearchSellerState {}

class SearchSellerInProgress extends SearchSellerState {}

class SearchSellerSuccess extends SearchSellerState {
  final List<SearchedSeller> sellers;

  SearchSellerSuccess({required this.sellers});
}

class SearchSellerFailure extends SearchSellerState {
  final String errorMessage;

  SearchSellerFailure(this.errorMessage);
}

class SearchSellerCubit extends Cubit<SearchSellerState> {
  final SellerDetailRepository _sellerDetailRepository;

  SearchSellerCubit(this._sellerDetailRepository)
      : super(SearchSellerInitial());

  void searchSeller({required String search}) async {
    emit(SearchSellerInProgress());
    try {
      emit(SearchSellerSuccess(
          sellers: await _sellerDetailRepository
              .searchSeller(parameter: {'search': search})));
    } catch (e) {
      emit(SearchSellerFailure(e.toString()));
    }
  }
}
