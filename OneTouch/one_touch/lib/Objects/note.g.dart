// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Note _$NoteFromJson(Map<String, dynamic> json) => Note(
      noteType: $enumDecode(_$NoteTypeEnumMap, json['noteType']),
      question: json['question'] as String,
      interactionTime: json['interactionTime'] == null
          ? null
          : DateTime.parse(json['interactionTime'] as String),
    );

Map<String, dynamic> _$NoteToJson(Note instance) => <String, dynamic>{
  'noteType': _$NoteTypeEnumMap[instance.noteType]!,
  'question': instance.question,
  'interactionTime': instance.interactionTime?.toIso8601String(),
};

const _$NoteTypeEnumMap = {
  NoteType.nullType: 'nullType',
  NoteType.numberScale: 'numberScale',
  NoteType.text: 'text',
  NoteType.multipleChoice: 'multipleChoice',
  NoteType.singleChoice: 'singleChoice',
};

NumberScaleNote _$NumberScaleNoteFromJson(Map<String, dynamic> json) =>
    NumberScaleNote(
        noteType: $enumDecode(_$NoteTypeEnumMap, json['noteType']),
        question: json['question'] as String,
        minValue: (json['minValue'] as num).toInt(),
        maxValue: (json['maxValue'] as num).toInt(),
        step: (json['step'] as num).toInt(),
        minLabel: json['minLabel'] as String,
        maxLabel: json['maxLabel'] as String,
        interactionTime: json['interactionTime'] == null
            ? null
            : DateTime.parse(json['interactionTime'] as String),
      )
      ..selection = (json['selection'] as num?)?.toInt()
      ..value = (json['value'] as num).toInt();

Map<String, dynamic> _$NumberScaleNoteToJson(NumberScaleNote instance) =>
    <String, dynamic>{
      'noteType': _$NoteTypeEnumMap[instance.noteType]!,
      'question': instance.question,
      'interactionTime': instance.interactionTime?.toIso8601String(),
      'minValue': instance.minValue,
      'maxValue': instance.maxValue,
      'step': instance.step,
      'minLabel': instance.minLabel,
      'maxLabel': instance.maxLabel,
      'selection': instance.selection,
      'value': instance.value,
    };

MultipleChoiceNote _$MultipleChoiceNoteFromJson(Map<String, dynamic> json) =>
    MultipleChoiceNote(
        noteType: $enumDecode(_$NoteTypeEnumMap, json['noteType']),
        question: json['question'] as String,
        options: (json['options'] as List<dynamic>)
            .map((e) => e as String)
            .toList(),
        maxSelections: (json['maxSelections'] as num).toInt(),
        interactionTime: json['interactionTime'] == null
            ? null
            : DateTime.parse(json['interactionTime'] as String),
      )
      ..selection = (json['selection'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList();

Map<String, dynamic> _$MultipleChoiceNoteToJson(MultipleChoiceNote instance) =>
    <String, dynamic>{
      'noteType': _$NoteTypeEnumMap[instance.noteType]!,
      'question': instance.question,
      'interactionTime': instance.interactionTime?.toIso8601String(),
      'options': instance.options,
      'maxSelections': instance.maxSelections,
      'selection': instance.selection,
    };

SingleChoiceNote _$SingleChoiceNoteFromJson(Map<String, dynamic> json) =>
    SingleChoiceNote(
      noteType: $enumDecode(_$NoteTypeEnumMap, json['noteType']),
      question: json['question'] as String,
      options: (json['options'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      interactionTime: json['interactionTime'] == null
          ? null
          : DateTime.parse(json['interactionTime'] as String),
    )..selection = (json['selection'] as num?)?.toInt();

Map<String, dynamic> _$SingleChoiceNoteToJson(SingleChoiceNote instance) =>
    <String, dynamic>{
      'noteType': _$NoteTypeEnumMap[instance.noteType]!,
      'question': instance.question,
      'interactionTime': instance.interactionTime?.toIso8601String(),
      'options': instance.options,
      'selection': instance.selection,
    };
