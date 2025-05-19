import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:car_rental_app/domain/usecases/get_cars.dart';
import 'package:car_rental_app/presentation/bloc/car_event.dart';
import 'package:car_rental_app/presentation/bloc/car_state.dart';

class CarBloc extends Bloc<CarEvent, CarState> {
  final GetCars getCars;

  CarBloc({required this.getCars}) : super(CarsLoading()) {
    on<LoadCars>((event, emit) async {
      emit(CarsLoading());
      print('CarBloc: Emitted CarsLoading state');
      try{
        final cars = await getCars.call();
        emit(CarsLoaded(cars));
        print('CarBloc: Emitted CarsLoaded state with ${cars.length} cars');
      }catch(e){
        emit(CarsError(e.toString()));
        print('CarBloc: Caught error: ${e.toString()}');
        print('CarBloc: Emitted CarsError state');
      }
    });
  }
}