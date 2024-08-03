import 'package:eshop_multivendor/Model/brandModel.dart';
import 'package:eshop_multivendor/repository/brandsRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class BrandsListState {}

class BrandsListInitial extends BrandsListState {}

class BrandsListInProgress extends BrandsListState {}

class BrandsListSuccess extends BrandsListState {
  final List<BrandData> brands;

  BrandsListSuccess({required this.brands});
}

class BrandsListFailure extends BrandsListState {
  final String errorMessage;

  BrandsListFailure(this.errorMessage);
}

class BrandsListCubit extends Cubit<BrandsListState> {
  final BrandsRepository brandsRepository;
  BrandsListCubit({required this.brandsRepository})
      : super(BrandsListInitial());

  void getBrandsList() async {
    emit(BrandsListInProgress());
    try {
      emit(BrandsListSuccess(brands: await brandsRepository.getAllBrands()));
    } catch (e) {
      emit(BrandsListFailure(e.toString()));
    }
  }
}
