import 'package:equatable/equatable.dart';

class ScoopAppModel extends Equatable {
  final String name;
  final String description;
  final String bucket;
  final DateTime updatedAt;

  const ScoopAppModel({
    required this.name,
    required this.description,
    required this.bucket,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [name, description, bucket, updatedAt];
}
