
import 'package:equatable/equatable.dart';
import 'supplication.dart';

class AudioCategory extends Equatable {
  final String name;
  final List<Supplication> supplications;

  const AudioCategory({
    required this.name,
    required this.supplications,
  });

  @override
  List<Object?> get props => [name, supplications];
}
