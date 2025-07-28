// This is a generated file - do not edit.
//
// Generated from auth.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'auth.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'auth.pbenum.dart';

/// ================================
/// 📦 登录
/// ================================
/// 登录请求
class LoginReqMsg extends $pb.GeneratedMessage {
  factory LoginReqMsg({
    $fixnum.Int64? messageId,
    $core.String? username,
    $core.String? password,
    DeviceType? deviceType,
    $core.String? appKey,
  }) {
    final result = create();
    if (messageId != null) result.messageId = messageId;
    if (username != null) result.username = username;
    if (password != null) result.password = password;
    if (deviceType != null) result.deviceType = deviceType;
    if (appKey != null) result.appKey = appKey;
    return result;
  }

  LoginReqMsg._();

  factory LoginReqMsg.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory LoginReqMsg.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LoginReqMsg', package: const $pb.PackageName(_omitMessageNames ? '' : 'protocol.auth'), createEmptyInstance: create)
    ..a<$fixnum.Int64>(1, _omitFieldNames ? '' : 'messageId', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(2, _omitFieldNames ? '' : 'username')
    ..aOS(3, _omitFieldNames ? '' : 'password')
    ..e<DeviceType>(4, _omitFieldNames ? '' : 'deviceType', $pb.PbFieldType.OE, defaultOrMaker: DeviceType.DEVICE_UNKNOWN, valueOf: DeviceType.valueOf, enumValues: DeviceType.values)
    ..aOS(5, _omitFieldNames ? '' : 'appKey')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoginReqMsg clone() => LoginReqMsg()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoginReqMsg copyWith(void Function(LoginReqMsg) updates) => super.copyWith((message) => updates(message as LoginReqMsg)) as LoginReqMsg;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LoginReqMsg create() => LoginReqMsg._();
  @$core.override
  LoginReqMsg createEmptyInstance() => create();
  static $pb.PbList<LoginReqMsg> createRepeated() => $pb.PbList<LoginReqMsg>();
  @$core.pragma('dart2js:noInline')
  static LoginReqMsg getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LoginReqMsg>(create);
  static LoginReqMsg? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get messageId => $_getI64(0);
  @$pb.TagNumber(1)
  set messageId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMessageId() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessageId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get username => $_getSZ(1);
  @$pb.TagNumber(2)
  set username($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUsername() => $_has(1);
  @$pb.TagNumber(2)
  void clearUsername() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get password => $_getSZ(2);
  @$pb.TagNumber(3)
  set password($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPassword() => $_has(2);
  @$pb.TagNumber(3)
  void clearPassword() => $_clearField(3);

  @$pb.TagNumber(4)
  DeviceType get deviceType => $_getN(3);
  @$pb.TagNumber(4)
  set deviceType(DeviceType value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasDeviceType() => $_has(3);
  @$pb.TagNumber(4)
  void clearDeviceType() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get appKey => $_getSZ(4);
  @$pb.TagNumber(5)
  set appKey($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasAppKey() => $_has(4);
  @$pb.TagNumber(5)
  void clearAppKey() => $_clearField(5);
}

/// ================================
/// 📦 登录返回
/// ================================
/// 登录返回
class LoginRespMsg extends $pb.GeneratedMessage {
  factory LoginRespMsg({
    $fixnum.Int64? messageId,
    $core.String? token,
    $fixnum.Int64? expiresAt,
    $core.bool? success,
  }) {
    final result = create();
    if (messageId != null) result.messageId = messageId;
    if (token != null) result.token = token;
    if (expiresAt != null) result.expiresAt = expiresAt;
    if (success != null) result.success = success;
    return result;
  }

  LoginRespMsg._();

  factory LoginRespMsg.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory LoginRespMsg.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LoginRespMsg', package: const $pb.PackageName(_omitMessageNames ? '' : 'protocol.auth'), createEmptyInstance: create)
    ..a<$fixnum.Int64>(1, _omitFieldNames ? '' : 'messageId', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(2, _omitFieldNames ? '' : 'token')
    ..a<$fixnum.Int64>(3, _omitFieldNames ? '' : 'expiresAt', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOB(4, _omitFieldNames ? '' : 'success')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoginRespMsg clone() => LoginRespMsg()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoginRespMsg copyWith(void Function(LoginRespMsg) updates) => super.copyWith((message) => updates(message as LoginRespMsg)) as LoginRespMsg;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LoginRespMsg create() => LoginRespMsg._();
  @$core.override
  LoginRespMsg createEmptyInstance() => create();
  static $pb.PbList<LoginRespMsg> createRepeated() => $pb.PbList<LoginRespMsg>();
  @$core.pragma('dart2js:noInline')
  static LoginRespMsg getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LoginRespMsg>(create);
  static LoginRespMsg? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get messageId => $_getI64(0);
  @$pb.TagNumber(1)
  set messageId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMessageId() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessageId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get token => $_getSZ(1);
  @$pb.TagNumber(2)
  set token($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasToken() => $_has(1);
  @$pb.TagNumber(2)
  void clearToken() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get expiresAt => $_getI64(2);
  @$pb.TagNumber(3)
  set expiresAt($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasExpiresAt() => $_has(2);
  @$pb.TagNumber(3)
  void clearExpiresAt() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get success => $_getBF(3);
  @$pb.TagNumber(4)
  set success($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSuccess() => $_has(3);
  @$pb.TagNumber(4)
  void clearSuccess() => $_clearField(4);
}

/// ========================================
///  退出请求
class LogoutReqMsg extends $pb.GeneratedMessage {
  factory LogoutReqMsg({
    $fixnum.Int64? messageId,
  }) {
    final result = create();
    if (messageId != null) result.messageId = messageId;
    return result;
  }

  LogoutReqMsg._();

  factory LogoutReqMsg.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory LogoutReqMsg.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LogoutReqMsg', package: const $pb.PackageName(_omitMessageNames ? '' : 'protocol.auth'), createEmptyInstance: create)
    ..a<$fixnum.Int64>(1, _omitFieldNames ? '' : 'messageId', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LogoutReqMsg clone() => LogoutReqMsg()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LogoutReqMsg copyWith(void Function(LogoutReqMsg) updates) => super.copyWith((message) => updates(message as LogoutReqMsg)) as LogoutReqMsg;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LogoutReqMsg create() => LogoutReqMsg._();
  @$core.override
  LogoutReqMsg createEmptyInstance() => create();
  static $pb.PbList<LogoutReqMsg> createRepeated() => $pb.PbList<LogoutReqMsg>();
  @$core.pragma('dart2js:noInline')
  static LogoutReqMsg getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LogoutReqMsg>(create);
  static LogoutReqMsg? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get messageId => $_getI64(0);
  @$pb.TagNumber(1)
  set messageId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMessageId() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessageId() => $_clearField(1);
}

/// 退出返回
class LogoutRespMsg extends $pb.GeneratedMessage {
  factory LogoutRespMsg({
    $fixnum.Int64? messageId,
  }) {
    final result = create();
    if (messageId != null) result.messageId = messageId;
    return result;
  }

  LogoutRespMsg._();

  factory LogoutRespMsg.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory LogoutRespMsg.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LogoutRespMsg', package: const $pb.PackageName(_omitMessageNames ? '' : 'protocol.auth'), createEmptyInstance: create)
    ..a<$fixnum.Int64>(1, _omitFieldNames ? '' : 'messageId', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LogoutRespMsg clone() => LogoutRespMsg()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LogoutRespMsg copyWith(void Function(LogoutRespMsg) updates) => super.copyWith((message) => updates(message as LogoutRespMsg)) as LogoutRespMsg;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LogoutRespMsg create() => LogoutRespMsg._();
  @$core.override
  LogoutRespMsg createEmptyInstance() => create();
  static $pb.PbList<LogoutRespMsg> createRepeated() => $pb.PbList<LogoutRespMsg>();
  @$core.pragma('dart2js:noInline')
  static LogoutRespMsg getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LogoutRespMsg>(create);
  static LogoutRespMsg? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get messageId => $_getI64(0);
  @$pb.TagNumber(1)
  set messageId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMessageId() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessageId() => $_clearField(1);
}

/// ========================================
/// 📩 发送验证码请求
/// ========================================
/// 客户端请求发送验证码（短信、邮件等）用于登录或注册
class SendVerificationCodeReqMsg extends $pb.GeneratedMessage {
  factory SendVerificationCodeReqMsg({
    $fixnum.Int64? messageId,
    $core.String? receiver,
    $core.String? channel,
    $core.String? scene,
    $core.String? uid,
  }) {
    final result = create();
    if (messageId != null) result.messageId = messageId;
    if (receiver != null) result.receiver = receiver;
    if (channel != null) result.channel = channel;
    if (scene != null) result.scene = scene;
    if (uid != null) result.uid = uid;
    return result;
  }

  SendVerificationCodeReqMsg._();

  factory SendVerificationCodeReqMsg.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory SendVerificationCodeReqMsg.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SendVerificationCodeReqMsg', package: const $pb.PackageName(_omitMessageNames ? '' : 'protocol.auth'), createEmptyInstance: create)
    ..a<$fixnum.Int64>(1, _omitFieldNames ? '' : 'messageId', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(2, _omitFieldNames ? '' : 'receiver')
    ..aOS(3, _omitFieldNames ? '' : 'channel')
    ..aOS(4, _omitFieldNames ? '' : 'scene')
    ..aOS(5, _omitFieldNames ? '' : 'uid')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendVerificationCodeReqMsg clone() => SendVerificationCodeReqMsg()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendVerificationCodeReqMsg copyWith(void Function(SendVerificationCodeReqMsg) updates) => super.copyWith((message) => updates(message as SendVerificationCodeReqMsg)) as SendVerificationCodeReqMsg;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SendVerificationCodeReqMsg create() => SendVerificationCodeReqMsg._();
  @$core.override
  SendVerificationCodeReqMsg createEmptyInstance() => create();
  static $pb.PbList<SendVerificationCodeReqMsg> createRepeated() => $pb.PbList<SendVerificationCodeReqMsg>();
  @$core.pragma('dart2js:noInline')
  static SendVerificationCodeReqMsg getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SendVerificationCodeReqMsg>(create);
  static SendVerificationCodeReqMsg? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get messageId => $_getI64(0);
  @$pb.TagNumber(1)
  set messageId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMessageId() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessageId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get receiver => $_getSZ(1);
  @$pb.TagNumber(2)
  set receiver($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasReceiver() => $_has(1);
  @$pb.TagNumber(2)
  void clearReceiver() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get channel => $_getSZ(2);
  @$pb.TagNumber(3)
  set channel($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasChannel() => $_has(2);
  @$pb.TagNumber(3)
  void clearChannel() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get scene => $_getSZ(3);
  @$pb.TagNumber(4)
  set scene($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasScene() => $_has(3);
  @$pb.TagNumber(4)
  void clearScene() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get uid => $_getSZ(4);
  @$pb.TagNumber(5)
  set uid($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasUid() => $_has(4);
  @$pb.TagNumber(5)
  void clearUid() => $_clearField(5);
}

/// ========================================
/// ✅ 发送验证码响应
/// ========================================
/// 服务端对验证码发送请求的响应
class SendVerificationCodeRepMsg extends $pb.GeneratedMessage {
  factory SendVerificationCodeRepMsg({
    $fixnum.Int64? messageId,
    $core.bool? success,
    $core.String? message,
    $fixnum.Int64? expiredIn,
  }) {
    final result = create();
    if (messageId != null) result.messageId = messageId;
    if (success != null) result.success = success;
    if (message != null) result.message = message;
    if (expiredIn != null) result.expiredIn = expiredIn;
    return result;
  }

  SendVerificationCodeRepMsg._();

  factory SendVerificationCodeRepMsg.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory SendVerificationCodeRepMsg.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SendVerificationCodeRepMsg', package: const $pb.PackageName(_omitMessageNames ? '' : 'protocol.auth'), createEmptyInstance: create)
    ..a<$fixnum.Int64>(1, _omitFieldNames ? '' : 'messageId', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOB(2, _omitFieldNames ? '' : 'success')
    ..aOS(3, _omitFieldNames ? '' : 'message')
    ..aInt64(4, _omitFieldNames ? '' : 'expiredIn')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendVerificationCodeRepMsg clone() => SendVerificationCodeRepMsg()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendVerificationCodeRepMsg copyWith(void Function(SendVerificationCodeRepMsg) updates) => super.copyWith((message) => updates(message as SendVerificationCodeRepMsg)) as SendVerificationCodeRepMsg;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SendVerificationCodeRepMsg create() => SendVerificationCodeRepMsg._();
  @$core.override
  SendVerificationCodeRepMsg createEmptyInstance() => create();
  static $pb.PbList<SendVerificationCodeRepMsg> createRepeated() => $pb.PbList<SendVerificationCodeRepMsg>();
  @$core.pragma('dart2js:noInline')
  static SendVerificationCodeRepMsg getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SendVerificationCodeRepMsg>(create);
  static SendVerificationCodeRepMsg? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get messageId => $_getI64(0);
  @$pb.TagNumber(1)
  set messageId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMessageId() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessageId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get success => $_getBF(1);
  @$pb.TagNumber(2)
  set success($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSuccess() => $_has(1);
  @$pb.TagNumber(2)
  void clearSuccess() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get message => $_getSZ(2);
  @$pb.TagNumber(3)
  set message($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMessage() => $_has(2);
  @$pb.TagNumber(3)
  void clearMessage() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get expiredIn => $_getI64(3);
  @$pb.TagNumber(4)
  set expiredIn($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasExpiredIn() => $_has(3);
  @$pb.TagNumber(4)
  void clearExpiredIn() => $_clearField(4);
}

/// =======================================
/// 🟢 用户上线消息（OnlineStatus）
/// =======================================
/// 表示某个用户刚刚上线，服务端可用于广播通知。
class OnlineStatusMsg extends $pb.GeneratedMessage {
  factory OnlineStatusMsg({
    $fixnum.Int64? messageId,
    $core.String? uid,
    DeviceType? deviceType,
    $core.String? clientId,
    $fixnum.Int64? loginTime,
  }) {
    final result = create();
    if (messageId != null) result.messageId = messageId;
    if (uid != null) result.uid = uid;
    if (deviceType != null) result.deviceType = deviceType;
    if (clientId != null) result.clientId = clientId;
    if (loginTime != null) result.loginTime = loginTime;
    return result;
  }

  OnlineStatusMsg._();

  factory OnlineStatusMsg.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory OnlineStatusMsg.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'OnlineStatusMsg', package: const $pb.PackageName(_omitMessageNames ? '' : 'protocol.auth'), createEmptyInstance: create)
    ..a<$fixnum.Int64>(1, _omitFieldNames ? '' : 'messageId', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(2, _omitFieldNames ? '' : 'uid')
    ..e<DeviceType>(3, _omitFieldNames ? '' : 'deviceType', $pb.PbFieldType.OE, defaultOrMaker: DeviceType.DEVICE_UNKNOWN, valueOf: DeviceType.valueOf, enumValues: DeviceType.values)
    ..aOS(4, _omitFieldNames ? '' : 'clientId')
    ..aInt64(5, _omitFieldNames ? '' : 'loginTime')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OnlineStatusMsg clone() => OnlineStatusMsg()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OnlineStatusMsg copyWith(void Function(OnlineStatusMsg) updates) => super.copyWith((message) => updates(message as OnlineStatusMsg)) as OnlineStatusMsg;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static OnlineStatusMsg create() => OnlineStatusMsg._();
  @$core.override
  OnlineStatusMsg createEmptyInstance() => create();
  static $pb.PbList<OnlineStatusMsg> createRepeated() => $pb.PbList<OnlineStatusMsg>();
  @$core.pragma('dart2js:noInline')
  static OnlineStatusMsg getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<OnlineStatusMsg>(create);
  static OnlineStatusMsg? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get messageId => $_getI64(0);
  @$pb.TagNumber(1)
  set messageId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMessageId() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessageId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get uid => $_getSZ(1);
  @$pb.TagNumber(2)
  set uid($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUid() => $_has(1);
  @$pb.TagNumber(2)
  void clearUid() => $_clearField(2);

  @$pb.TagNumber(3)
  DeviceType get deviceType => $_getN(2);
  @$pb.TagNumber(3)
  set deviceType(DeviceType value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasDeviceType() => $_has(2);
  @$pb.TagNumber(3)
  void clearDeviceType() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get clientId => $_getSZ(3);
  @$pb.TagNumber(4)
  set clientId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasClientId() => $_has(3);
  @$pb.TagNumber(4)
  void clearClientId() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get loginTime => $_getI64(4);
  @$pb.TagNumber(5)
  set loginTime($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasLoginTime() => $_has(4);
  @$pb.TagNumber(5)
  void clearLoginTime() => $_clearField(5);
}

/// =======================================
/// 🔴 用户下线消息（OfflineStatus）
/// =======================================
/// 表示某个用户从某设备下线，服务端可用于状态同步或通知。
class OfflineStatueMsg extends $pb.GeneratedMessage {
  factory OfflineStatueMsg({
    $fixnum.Int64? messageId,
    $core.String? uid,
    DeviceType? deviceType,
    $core.String? clientId,
    $fixnum.Int64? logoutTime,
    $core.String? reason,
  }) {
    final result = create();
    if (messageId != null) result.messageId = messageId;
    if (uid != null) result.uid = uid;
    if (deviceType != null) result.deviceType = deviceType;
    if (clientId != null) result.clientId = clientId;
    if (logoutTime != null) result.logoutTime = logoutTime;
    if (reason != null) result.reason = reason;
    return result;
  }

  OfflineStatueMsg._();

  factory OfflineStatueMsg.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory OfflineStatueMsg.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'OfflineStatueMsg', package: const $pb.PackageName(_omitMessageNames ? '' : 'protocol.auth'), createEmptyInstance: create)
    ..a<$fixnum.Int64>(1, _omitFieldNames ? '' : 'messageId', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(2, _omitFieldNames ? '' : 'uid')
    ..e<DeviceType>(3, _omitFieldNames ? '' : 'deviceType', $pb.PbFieldType.OE, defaultOrMaker: DeviceType.DEVICE_UNKNOWN, valueOf: DeviceType.valueOf, enumValues: DeviceType.values)
    ..aOS(4, _omitFieldNames ? '' : 'clientId')
    ..aInt64(5, _omitFieldNames ? '' : 'logoutTime')
    ..aOS(6, _omitFieldNames ? '' : 'reason')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OfflineStatueMsg clone() => OfflineStatueMsg()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OfflineStatueMsg copyWith(void Function(OfflineStatueMsg) updates) => super.copyWith((message) => updates(message as OfflineStatueMsg)) as OfflineStatueMsg;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static OfflineStatueMsg create() => OfflineStatueMsg._();
  @$core.override
  OfflineStatueMsg createEmptyInstance() => create();
  static $pb.PbList<OfflineStatueMsg> createRepeated() => $pb.PbList<OfflineStatueMsg>();
  @$core.pragma('dart2js:noInline')
  static OfflineStatueMsg getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<OfflineStatueMsg>(create);
  static OfflineStatueMsg? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get messageId => $_getI64(0);
  @$pb.TagNumber(1)
  set messageId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMessageId() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessageId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get uid => $_getSZ(1);
  @$pb.TagNumber(2)
  set uid($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUid() => $_has(1);
  @$pb.TagNumber(2)
  void clearUid() => $_clearField(2);

  @$pb.TagNumber(3)
  DeviceType get deviceType => $_getN(2);
  @$pb.TagNumber(3)
  set deviceType(DeviceType value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasDeviceType() => $_has(2);
  @$pb.TagNumber(3)
  void clearDeviceType() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get clientId => $_getSZ(3);
  @$pb.TagNumber(4)
  set clientId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasClientId() => $_has(3);
  @$pb.TagNumber(4)
  void clearClientId() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get logoutTime => $_getI64(4);
  @$pb.TagNumber(5)
  set logoutTime($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasLogoutTime() => $_has(4);
  @$pb.TagNumber(5)
  void clearLogoutTime() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get reason => $_getSZ(5);
  @$pb.TagNumber(6)
  set reason($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasReason() => $_has(5);
  @$pb.TagNumber(6)
  void clearReason() => $_clearField(6);
}


const $core.bool _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
