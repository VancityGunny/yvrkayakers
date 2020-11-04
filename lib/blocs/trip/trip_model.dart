import 'package:equatable/equatable.dart';

/// generate by https://javiercbk.github.io/json_to_dart/
class AutogeneratedTrip {
  final List<TripModel> results;

  AutogeneratedTrip({this.results});

  factory AutogeneratedTrip.fromJson(Map<String, dynamic> json) {
    List<TripModel> temp;
    if (json['results'] != null) {
      temp = <TripModel>[];
      json['results'].forEach((v) {
        temp.add(TripModel.fromJson(v as Map<String, dynamic>));
      });
    }
    return AutogeneratedTrip(results: temp);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (results != null) {
      data['results'] = results.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class TripModel extends Equatable {
  final int id;
  final String name;

  TripModel(this.id, this.name);

  @override
  List<Object> get props => [id, name];

  factory TripModel.fromJson(Map<String, dynamic> json) {
    return TripModel(json['id'] as int, json['name'] as String);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    return data;
  }
  
}
