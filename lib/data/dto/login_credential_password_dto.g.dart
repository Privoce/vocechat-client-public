// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_credential_password_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginCredentialPasswordDto _$LoginCredentialPasswordDtoFromJson(
        Map<String, dynamic> json) =>
    LoginCredentialPasswordDto(
      email: json['email'] as String?,
      password: json['password'] as String?,
    );

Map<String, dynamic> _$LoginCredentialPasswordDtoToJson(
        LoginCredentialPasswordDto instance) =>
    <String, dynamic>{
      'email': instance.email,
      'password': instance.password,
    };