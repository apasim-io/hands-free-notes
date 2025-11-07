// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'template.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Template _$TemplateFromJson(Map<String, dynamic> json) => Template(
  notes: (json['notes'] as List<dynamic>?)
      ?.map((e) => Note.fromJson(e as Map<String, dynamic>))
      .toList(),
  name: json['name'] as String?,
);

Map<String, dynamic> _$TemplateToJson(Template instance) => <String, dynamic>{
  'name': instance.name,
  'notes': instance.notes,
};
