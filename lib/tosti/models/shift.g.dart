// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shift.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TostiShift _$TostiShiftFromJson(Map<String, dynamic> json) => TostiShift(
      json['id'] as int,
      json['venue'] as int,
      json['venue_name'] as String,
      DateTime.parse(json['start'] as String),
      DateTime.parse(json['end'] as String),
      json['can_order'] as bool,
      json['is_active'] as bool,
      json['finalized'] as bool,
      json['amount_of_orders'] as int,
      json['max_orders_per_user'] as int,
      json['max_orders_total'] as int,
      (json['assignees'] as List<dynamic>)
          .map((e) => TostiUser.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TostiShiftToJson(TostiShift instance) =>
    <String, dynamic>{
      'id': instance.id,
      'venue': instance.venue,
      'venue_name': instance.venueName,
      'start': instance.start.toIso8601String(),
      'end': instance.end.toIso8601String(),
      'can_order': instance.canOrder,
      'is_active': instance.isActive,
      'finalized': instance.finalized,
      'amount_of_orders': instance.amountOfOrders,
      'max_orders_per_user': instance.maxOrdersPerUser,
      'max_orders_total': instance.maxOrdersTotal,
      'assignees': instance.assignees,
    };
