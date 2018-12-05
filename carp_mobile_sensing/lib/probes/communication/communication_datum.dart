/*
 * Copyright 2018 Copenhagen Center for Health Technology (CACHET) at the
 * Technical University of Denmark (DTU).
 * Use of this source code is governed by a MIT-style license that can be
 * found in the LICENSE file.
 */

part of communication;

/// Holds a list of text (SMS) messages from the device.
@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class TextMessageLogDatum extends CARPDatum {
  static CARPDataFormat CARP_DATA_FORMAT =
      new CARPDataFormat(NameSpace.CARP_NAMESPACE, ProbeRegistry.TEXT_MESSAGE_LOG_MEASURE);

  List<TextMessage> textMessageLog;

  TextMessageLogDatum() : super();

  factory TextMessageLogDatum.fromJson(Map<String, dynamic> json) => _$TextMessageLogDatumFromJson(json);
  Map<String, dynamic> toJson() => _$TextMessageLogDatumToJson(this);

  CARPDataFormat getCARPDataFormat() => CARP_DATA_FORMAT;

  String toString() => "text_message_log: {size: ${textMessageLog.length}}";
}

/// Holds a single text (SMS) message as a [Datum] object.
///
/// Wraps a [TextMessage].
@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class TextMessageDatum extends CARPDatum {
  static CARPDataFormat CARP_DATA_FORMAT =
      new CARPDataFormat(NameSpace.CARP_NAMESPACE, ProbeRegistry.TEXT_MESSAGE_MEASURE);

  TextMessage textMessage;

  TextMessageDatum(this.textMessage) : super();

  factory TextMessageDatum.fromJson(Map<String, dynamic> json) => _$TextMessageDatumFromJson(json);
  Map<String, dynamic> toJson() => _$TextMessageDatumToJson(this);

  CARPDataFormat getCARPDataFormat() => CARP_DATA_FORMAT;

  String toString() => textMessage.toString();
}

/// Holds a text messages (SMS).
@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class TextMessage extends Serializable {
  int id;
  String address;
  String body;

  /// The size in bytes of the body of the message.
  int size;
  bool isRead;
  DateTime date;
  DateTime dateSent;

  /// The kind of message:
  /// - Draft
  /// - Received
  /// - Sent
  String kind;
  String state;

  TextMessage({this.id, this.address, this.body, this.isRead, this.date, this.dateSent, this.kind, this.state})
      : super();

  factory TextMessage.fromSmsMessage(SmsMessage sms) {
    TextMessage msg = new TextMessage(
        id: sms.id, address: sms.address, body: sms.body, isRead: sms.isRead, date: sms.date, dateSent: sms.dateSent);

    if (sms.body != null) msg.size = sms.body.length;

    switch (sms.kind) {
      case SmsMessageKind.Sent:
        msg.kind = 'Sent';
        break;
      case SmsMessageKind.Received:
        msg.kind = 'Received';
        break;
      case SmsMessageKind.Draft:
        msg.kind = 'Draft';
        break;
    }

    switch (sms.state) {
      case SmsMessageState.Delivered:
        msg.state = 'Delivered';
        break;
      case SmsMessageState.Fail:
        msg.state = 'Fail';
        break;
      case SmsMessageState.None:
        msg.state = 'None';
        break;
      case SmsMessageState.Sending:
        msg.state = 'Sending';
        break;
      case SmsMessageState.Sent:
        msg.state = 'Sent';
        break;
    }

    return msg;
  }

  factory TextMessage.fromJson(Map<String, dynamic> json) => _$TextMessageFromJson(json);
  Map<String, dynamic> toJson() => _$TextMessageToJson(this);

  String toString() =>
      "text_message: {id: $id, address: $address, is_read: $isRead, date: $date, date_send: $dateSent, kind: $kind, state: $state}\n$body";
}

/// Holds a phone log, i.e. a list of phone calls made on the device.
@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class PhoneLogDatum extends CARPDatum {
  static CARPDataFormat CARP_DATA_FORMAT = new CARPDataFormat(NameSpace.CARP_NAMESPACE, ProbeRegistry.PHONELOG_MEASURE);

  List<PhoneCall> phoneLog = new List<PhoneCall>();

  PhoneLogDatum() : super();

  factory PhoneLogDatum.fromJson(Map<String, dynamic> json) => _$PhoneLogDatumFromJson(json);
  Map<String, dynamic> toJson() => _$PhoneLogDatumToJson(this);

  CARPDataFormat getCARPDataFormat() => CARP_DATA_FORMAT;

  String toString() => "phone_log: {size: ${phoneLog.length}}";
}

/// Holds data regarding a phone call.
@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class PhoneCall extends Serializable {
  /// Date & Time of the call.
  DateTime timestamp;

  /// Type of call:
  /// * answered
  /// * incoming
  /// * blocked
  /// * missed
  /// * outgoing
  /// * rejected
  /// * voice_mail
  String callType;

  /// duration of call in ms.
  int duration;

  String formattedNumber;
  String number;
  String name;

  PhoneCall([this.timestamp, this.callType, this.duration, this.formattedNumber, this.number, this.name]);

  factory PhoneCall.fromCallLogEntry(CallLogEntry call) {
    DateTime _timestamp = DateTime.fromMicrosecondsSinceEpoch(call.timestamp);
    String _type = "unknown";

    switch (call.callType) {
      case CallType.answeredExternally:
        _type = 'answered_externally';
        break;
      case CallType.blocked:
        _type = 'blocked';
        break;
      case CallType.incoming:
        _type = 'incoming';
        break;
      case CallType.missed:
        _type = 'missed';
        break;
      case CallType.outgoing:
        _type = 'outgoing';
        break;
      case CallType.rejected:
        _type = 'rejected';
        break;
      case CallType.voiceMail:
        _type = 'voice_mail';
        break;
      default:
        _type = "unknown";
        break;
    }

    PhoneCall pc = new PhoneCall(_timestamp, _type, call.duration, call.formattedNumber, call.number, call.name);

    return pc;
  }

  factory PhoneCall.fromJson(Map<String, dynamic> json) => _$PhoneCallFromJson(json);
  Map<String, dynamic> toJson() => _$PhoneCallToJson(this);

  String toString() =>
      "phone_call: {timestamp: $timestamp, call_type: $callType, duration: $duration, number: $number, formatted_number: $formattedNumber, name: $name}";
}
