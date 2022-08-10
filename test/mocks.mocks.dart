// Mocks generated by Mockito 5.2.0 from annotations
// in reaxit/test/mocks.dart.
// Do not manually edit this file.

import 'dart:async' as _i16;

import 'package:flutter_bloc/flutter_bloc.dart' as _i17;
import 'package:mockito/mockito.dart' as _i1;
import 'package:reaxit/api/api_repository.dart' as _i14;
import 'package:reaxit/blocs/auth_cubit.dart' as _i2;
import 'package:reaxit/blocs/detail_state.dart' as _i15;
import 'package:reaxit/blocs/payment_user_cubit.dart' as _i24;
import 'package:reaxit/models/album.dart' as _i11;
import 'package:reaxit/models/device.dart' as _i12;
import 'package:reaxit/models/event.dart' as _i3;
import 'package:reaxit/models/event_registration.dart' as _i5;
import 'package:reaxit/models/food_event.dart' as _i7;
import 'package:reaxit/models/food_order.dart' as _i8;
import 'package:reaxit/models/frontpage_article.dart' as _i22;
import 'package:reaxit/models/list_response.dart' as _i4;
import 'package:reaxit/models/member.dart' as _i10;
import 'package:reaxit/models/payable.dart' as _i6;
import 'package:reaxit/models/payment.dart' as _i19;
import 'package:reaxit/models/payment_user.dart' as _i9;
import 'package:reaxit/models/product.dart' as _i20;
import 'package:reaxit/models/push_notification_category.dart' as _i23;
import 'package:reaxit/models/registration_field.dart' as _i18;
import 'package:reaxit/models/sales_order.dart' as _i13;
import 'package:reaxit/models/slide.dart' as _i21;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types

class _FakeAuthState_0 extends _i1.Fake implements _i2.AuthState {}

class _FakeEvent_1 extends _i1.Fake implements _i3.Event {}

class _FakeListResponse_2<T> extends _i1.Fake implements _i4.ListResponse<T> {}

class _FakeEventRegistration_3 extends _i1.Fake
    implements _i5.EventRegistration {}

class _FakeAdminEventRegistration_4 extends _i1.Fake
    implements _i5.AdminEventRegistration {}

class _FakePayable_5 extends _i1.Fake implements _i6.Payable {}

class _FakeFoodEvent_6 extends _i1.Fake implements _i7.FoodEvent {}

class _FakeFoodOrder_7 extends _i1.Fake implements _i8.FoodOrder {}

class _FakePaymentUser_8 extends _i1.Fake implements _i9.PaymentUser {}

class _FakeMember_9 extends _i1.Fake implements _i10.Member {}

class _FakeFullMember_10 extends _i1.Fake implements _i10.FullMember {}

class _FakeAlbum_11 extends _i1.Fake implements _i11.Album {}

class _FakeDevice_12 extends _i1.Fake implements _i12.Device {}

class _FakeSalesOrder_13 extends _i1.Fake implements _i13.SalesOrder {}

class _FakeApiRepository_14 extends _i1.Fake implements _i14.ApiRepository {}

class _FakeDetailState_15<E> extends _i1.Fake implements _i15.DetailState<E> {}

/// A class which mocks [AuthCubit].
///
/// See the documentation for Mockito's code generation for more information.
class MockAuthCubit extends _i1.Mock implements _i2.AuthCubit {
  MockAuthCubit() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.AuthState get state => (super.noSuchMethod(Invocation.getter(#state),
      returnValue: _FakeAuthState_0()) as _i2.AuthState);
  @override
  _i16.Stream<_i2.AuthState> get stream =>
      (super.noSuchMethod(Invocation.getter(#stream),
              returnValue: Stream<_i2.AuthState>.empty())
          as _i16.Stream<_i2.AuthState>);
  @override
  bool get isClosed =>
      (super.noSuchMethod(Invocation.getter(#isClosed), returnValue: false)
          as bool);
  @override
  _i16.Future<void> load() => (super.noSuchMethod(Invocation.method(#load, []),
      returnValue: Future<void>.value(),
      returnValueForMissingStub: Future<void>.value()) as _i16.Future<void>);
  @override
  _i16.Future<void> logIn() => (super.noSuchMethod(
      Invocation.method(#logIn, []),
      returnValue: Future<void>.value(),
      returnValueForMissingStub: Future<void>.value()) as _i16.Future<void>);
  @override
  _i16.Future<void> logOut() => (super.noSuchMethod(
      Invocation.method(#logOut, []),
      returnValue: Future<void>.value(),
      returnValueForMissingStub: Future<void>.value()) as _i16.Future<void>);
  @override
  void emit(_i2.AuthState? state) =>
      super.noSuchMethod(Invocation.method(#emit, [state]),
          returnValueForMissingStub: null);
  @override
  void onChange(_i17.Change<_i2.AuthState>? change) =>
      super.noSuchMethod(Invocation.method(#onChange, [change]),
          returnValueForMissingStub: null);
  @override
  void addError(Object? error, [StackTrace? stackTrace]) =>
      super.noSuchMethod(Invocation.method(#addError, [error, stackTrace]),
          returnValueForMissingStub: null);
  @override
  void onError(Object? error, StackTrace? stackTrace) =>
      super.noSuchMethod(Invocation.method(#onError, [error, stackTrace]),
          returnValueForMissingStub: null);
  @override
  _i16.Future<void> close() => (super.noSuchMethod(
      Invocation.method(#close, []),
      returnValue: Future<void>.value(),
      returnValueForMissingStub: Future<void>.value()) as _i16.Future<void>);
}

/// A class which mocks [ApiRepository].
///
/// See the documentation for Mockito's code generation for more information.
class MockApiRepository extends _i1.Mock implements _i14.ApiRepository {
  MockApiRepository() {
    _i1.throwOnMissingStub(this);
  }

  @override
  void close() => super.noSuchMethod(Invocation.method(#close, []),
      returnValueForMissingStub: null);
  @override
  _i16.Future<_i3.Event> getEvent({int? pk}) =>
      (super.noSuchMethod(Invocation.method(#getEvent, [], {#pk: pk}),
              returnValue: Future<_i3.Event>.value(_FakeEvent_1()))
          as _i16.Future<_i3.Event>);
  @override
  _i16.Future<_i4.ListResponse<_i3.Event>> getEvents(
          {String? search,
          int? limit,
          int? offset,
          String? ordering,
          DateTime? start,
          DateTime? end}) =>
      (super.noSuchMethod(
              Invocation.method(#getEvents, [], {
                #search: search,
                #limit: limit,
                #offset: offset,
                #ordering: ordering,
                #start: start,
                #end: end
              }),
              returnValue: Future<_i4.ListResponse<_i3.Event>>.value(
                  _FakeListResponse_2<_i3.Event>()))
          as _i16.Future<_i4.ListResponse<_i3.Event>>);
  @override
  _i16.Future<_i4.ListResponse<_i3.PartnerEvent>> getPartnerEvents(
          {String? search,
          int? limit,
          int? offset,
          String? ordering,
          DateTime? start,
          DateTime? end}) =>
      (super.noSuchMethod(
              Invocation.method(#getPartnerEvents, [], {
                #search: search,
                #limit: limit,
                #offset: offset,
                #ordering: ordering,
                #start: start,
                #end: end
              }),
              returnValue: Future<_i4.ListResponse<_i3.PartnerEvent>>.value(
                  _FakeListResponse_2<_i3.PartnerEvent>()))
          as _i16.Future<_i4.ListResponse<_i3.PartnerEvent>>);
  @override
  _i16.Future<_i4.ListResponse<_i5.EventRegistration>> getEventRegistrations(
          {int? pk, int? limit, int? offset}) =>
      (super.noSuchMethod(
          Invocation.method(#getEventRegistrations, [],
              {#pk: pk, #limit: limit, #offset: offset}),
          returnValue: Future<_i4.ListResponse<_i5.EventRegistration>>.value(
              _FakeListResponse_2<_i5.EventRegistration>())) as _i16
          .Future<_i4.ListResponse<_i5.EventRegistration>>);
  @override
  _i16.Future<_i5.EventRegistration> registerForEvent(int? pk) =>
      (super.noSuchMethod(Invocation.method(#registerForEvent, [pk]),
              returnValue: Future<_i5.EventRegistration>.value(
                  _FakeEventRegistration_3()))
          as _i16.Future<_i5.EventRegistration>);
  @override
  _i16.Future<void> cancelRegistration({int? eventPk, int? registrationPk}) =>
      (super.noSuchMethod(
              Invocation.method(#cancelRegistration, [],
                  {#eventPk: eventPk, #registrationPk: registrationPk}),
              returnValue: Future<void>.value(),
              returnValueForMissingStub: Future<void>.value())
          as _i16.Future<void>);
  @override
  _i16.Future<Map<String, _i18.RegistrationField>> getRegistrationFields(
          {int? eventPk, int? registrationPk}) =>
      (super.noSuchMethod(
              Invocation.method(#getRegistrationFields, [],
                  {#eventPk: eventPk, #registrationPk: registrationPk}),
              returnValue: Future<Map<String, _i18.RegistrationField>>.value(
                  <String, _i18.RegistrationField>{}))
          as _i16.Future<Map<String, _i18.RegistrationField>>);
  @override
  _i16.Future<void> updateRegistrationFields(
          {int? eventPk,
          int? registrationPk,
          Map<String, _i18.RegistrationField>? fields}) =>
      (super.noSuchMethod(
              Invocation.method(#updateRegistrationFields, [], {
                #eventPk: eventPk,
                #registrationPk: registrationPk,
                #fields: fields
              }),
              returnValue: Future<void>.value(),
              returnValueForMissingStub: Future<void>.value())
          as _i16.Future<void>);
  @override
  _i16.Future<
      _i4.ListResponse<_i5.AdminEventRegistration>> getAdminEventRegistrations(
          {int? pk,
          int? limit,
          int? offset,
          String? search,
          String? ordering,
          bool? cancelled}) =>
      (super.noSuchMethod(
              Invocation.method(#getAdminEventRegistrations, [], {
                #pk: pk,
                #limit: limit,
                #offset: offset,
                #search: search,
                #ordering: ordering,
                #cancelled: cancelled
              }),
              returnValue:
                  Future<_i4.ListResponse<_i5.AdminEventRegistration>>.value(
                      _FakeListResponse_2<_i5.AdminEventRegistration>()))
          as _i16.Future<_i4.ListResponse<_i5.AdminEventRegistration>>);
  @override
  _i16.Future<_i5.AdminEventRegistration> markPresentAdminEventRegistration(
          {int? eventPk, int? registrationPk, bool? present}) =>
      (super.noSuchMethod(
              Invocation.method(#markPresentAdminEventRegistration, [], {
                #eventPk: eventPk,
                #registrationPk: registrationPk,
                #present: present
              }),
              returnValue: Future<_i5.AdminEventRegistration>.value(
                  _FakeAdminEventRegistration_4()))
          as _i16.Future<_i5.AdminEventRegistration>);
  @override
  _i16.Future<_i6.Payable> markPaidAdminEventRegistration(
          {int? registrationPk, _i19.PaymentType? paymentType}) =>
      (super.noSuchMethod(
              Invocation.method(#markPaidAdminEventRegistration, [],
                  {#registrationPk: registrationPk, #paymentType: paymentType}),
              returnValue: Future<_i6.Payable>.value(_FakePayable_5()))
          as _i16.Future<_i6.Payable>);
  @override
  _i16.Future<void> markNotPaidAdminEventRegistration({int? registrationPk}) =>
      (super.noSuchMethod(
              Invocation.method(#markNotPaidAdminEventRegistration, [],
                  {#registrationPk: registrationPk}),
              returnValue: Future<void>.value(),
              returnValueForMissingStub: Future<void>.value())
          as _i16.Future<void>);
  @override
  _i16.Future<_i4.ListResponse<_i8.AdminFoodOrder>> getAdminFoodOrders(
          {int? pk, int? limit, int? offset, String? search}) =>
      (super.noSuchMethod(
              Invocation.method(#getAdminFoodOrders, [],
                  {#pk: pk, #limit: limit, #offset: offset, #search: search}),
              returnValue: Future<_i4.ListResponse<_i8.AdminFoodOrder>>.value(
                  _FakeListResponse_2<_i8.AdminFoodOrder>()))
          as _i16.Future<_i4.ListResponse<_i8.AdminFoodOrder>>);
  @override
  _i16.Future<_i6.Payable> markPaidAdminFoodOrder(
          {int? orderPk, _i19.PaymentType? paymentType}) =>
      (super.noSuchMethod(
              Invocation.method(#markPaidAdminFoodOrder, [],
                  {#orderPk: orderPk, #paymentType: paymentType}),
              returnValue: Future<_i6.Payable>.value(_FakePayable_5()))
          as _i16.Future<_i6.Payable>);
  @override
  _i16.Future<void> markNotPaidAdminFoodOrder({int? orderPk}) =>
      (super.noSuchMethod(
              Invocation.method(
                  #markNotPaidAdminFoodOrder, [], {#orderPk: orderPk}),
              returnValue: Future<void>.value(),
              returnValueForMissingStub: Future<void>.value())
          as _i16.Future<void>);
  @override
  _i16.Future<_i7.FoodEvent> getFoodEvent(int? pk) =>
      (super.noSuchMethod(Invocation.method(#getFoodEvent, [pk]),
              returnValue: Future<_i7.FoodEvent>.value(_FakeFoodEvent_6()))
          as _i16.Future<_i7.FoodEvent>);
  @override
  _i16.Future<_i4.ListResponse<_i7.FoodEvent>> getFoodEvents(
          {int? limit,
          int? offset,
          String? ordering,
          DateTime? start,
          DateTime? end}) =>
      (super.noSuchMethod(
              Invocation.method(#getFoodEvents, [], {
                #limit: limit,
                #offset: offset,
                #ordering: ordering,
                #start: start,
                #end: end
              }),
              returnValue: Future<_i4.ListResponse<_i7.FoodEvent>>.value(
                  _FakeListResponse_2<_i7.FoodEvent>()))
          as _i16.Future<_i4.ListResponse<_i7.FoodEvent>>);
  @override
  _i16.Future<_i7.FoodEvent> getCurrentFoodEvent() =>
      (super.noSuchMethod(Invocation.method(#getCurrentFoodEvent, []),
              returnValue: Future<_i7.FoodEvent>.value(_FakeFoodEvent_6()))
          as _i16.Future<_i7.FoodEvent>);
  @override
  _i16.Future<_i8.FoodOrder> getFoodOrder(int? pk) =>
      (super.noSuchMethod(Invocation.method(#getFoodOrder, [pk]),
              returnValue: Future<_i8.FoodOrder>.value(_FakeFoodOrder_7()))
          as _i16.Future<_i8.FoodOrder>);
  @override
  _i16.Future<void> cancelFoodOrder(int? pk) => (super.noSuchMethod(
      Invocation.method(#cancelFoodOrder, [pk]),
      returnValue: Future<void>.value(),
      returnValueForMissingStub: Future<void>.value()) as _i16.Future<void>);
  @override
  _i16.Future<_i8.FoodOrder> placeFoodOrder({int? eventPk, int? productPk}) =>
      (super.noSuchMethod(
              Invocation.method(#placeFoodOrder, [],
                  {#eventPk: eventPk, #productPk: productPk}),
              returnValue: Future<_i8.FoodOrder>.value(_FakeFoodOrder_7()))
          as _i16.Future<_i8.FoodOrder>);
  @override
  _i16.Future<_i8.FoodOrder> changeFoodOrder({int? eventPk, int? productPk}) =>
      (super.noSuchMethod(
              Invocation.method(#changeFoodOrder, [],
                  {#eventPk: eventPk, #productPk: productPk}),
              returnValue: Future<_i8.FoodOrder>.value(_FakeFoodOrder_7()))
          as _i16.Future<_i8.FoodOrder>);
  @override
  _i16.Future<_i4.ListResponse<_i20.Product>> getFoodEventProducts(int? pk,
          {int? limit, int? offset, String? search}) =>
      (super.noSuchMethod(
              Invocation.method(#getFoodEventProducts, [pk],
                  {#limit: limit, #offset: offset, #search: search}),
              returnValue: Future<_i4.ListResponse<_i20.Product>>.value(
                  _FakeListResponse_2<_i20.Product>()))
          as _i16.Future<_i4.ListResponse<_i20.Product>>);
  @override
  _i16.Future<_i9.PaymentUser> getPaymentUser() =>
      (super.noSuchMethod(Invocation.method(#getPaymentUser, []),
              returnValue: Future<_i9.PaymentUser>.value(_FakePaymentUser_8()))
          as _i16.Future<_i9.PaymentUser>);
  @override
  _i16.Future<_i6.Payable> getFoodOrderPayable({int? foodOrderPk}) =>
      (super.noSuchMethod(
              Invocation.method(
                  #getFoodOrderPayable, [], {#foodOrderPk: foodOrderPk}),
              returnValue: Future<_i6.Payable>.value(_FakePayable_5()))
          as _i16.Future<_i6.Payable>);
  @override
  _i16.Future<_i6.Payable> thaliaPayFoodOrder({int? foodOrderPk}) =>
      (super.noSuchMethod(
              Invocation.method(
                  #thaliaPayFoodOrder, [], {#foodOrderPk: foodOrderPk}),
              returnValue: Future<_i6.Payable>.value(_FakePayable_5()))
          as _i16.Future<_i6.Payable>);
  @override
  _i16.Future<_i6.Payable> getEventRegistrationPayable({int? registrationPk}) =>
      (super.noSuchMethod(
              Invocation.method(#getEventRegistrationPayable, [],
                  {#registrationPk: registrationPk}),
              returnValue: Future<_i6.Payable>.value(_FakePayable_5()))
          as _i16.Future<_i6.Payable>);
  @override
  _i16.Future<_i6.Payable> thaliaPayRegistration({int? registrationPk}) =>
      (super.noSuchMethod(
              Invocation.method(#thaliaPayRegistration, [],
                  {#registrationPk: registrationPk}),
              returnValue: Future<_i6.Payable>.value(_FakePayable_5()))
          as _i16.Future<_i6.Payable>);
  @override
  _i16.Future<_i6.Payable> getSalesOrderPayable({String? salesOrderPk}) =>
      (super.noSuchMethod(
              Invocation.method(
                  #getSalesOrderPayable, [], {#salesOrderPk: salesOrderPk}),
              returnValue: Future<_i6.Payable>.value(_FakePayable_5()))
          as _i16.Future<_i6.Payable>);
  @override
  _i16.Future<_i6.Payable> thaliaPaySalesOrder({String? salesOrderPk}) =>
      (super.noSuchMethod(
              Invocation.method(
                  #thaliaPaySalesOrder, [], {#salesOrderPk: salesOrderPk}),
              returnValue: Future<_i6.Payable>.value(_FakePayable_5()))
          as _i16.Future<_i6.Payable>);
  @override
  _i16.Future<_i10.Member> getMember({int? pk}) =>
      (super.noSuchMethod(Invocation.method(#getMember, [], {#pk: pk}),
              returnValue: Future<_i10.Member>.value(_FakeMember_9()))
          as _i16.Future<_i10.Member>);
  @override
  _i16.Future<_i4.ListResponse<_i10.ListMember>> getMembers(
          {String? search, int? limit, int? offset, String? ordering}) =>
      (super.noSuchMethod(
              Invocation.method(#getMembers, [], {
                #search: search,
                #limit: limit,
                #offset: offset,
                #ordering: ordering
              }),
              returnValue: Future<_i4.ListResponse<_i10.ListMember>>.value(
                  _FakeListResponse_2<_i10.ListMember>()))
          as _i16.Future<_i4.ListResponse<_i10.ListMember>>);
  @override
  _i16.Future<_i10.FullMember> getMe() =>
      (super.noSuchMethod(Invocation.method(#getMe, []),
              returnValue: Future<_i10.FullMember>.value(_FakeFullMember_10()))
          as _i16.Future<_i10.FullMember>);
  @override
  _i16.Future<void> updateAvatar(String? file) => (super.noSuchMethod(
      Invocation.method(#updateAvatar, [file]),
      returnValue: Future<void>.value(),
      returnValueForMissingStub: Future<void>.value()) as _i16.Future<void>);
  @override
  _i16.Future<void> updateDescription(String? description) =>
      (super.noSuchMethod(Invocation.method(#updateDescription, [description]),
              returnValue: Future<void>.value(),
              returnValueForMissingStub: Future<void>.value())
          as _i16.Future<void>);
  @override
  _i16.Future<_i11.Album> getAlbum({String? slug}) =>
      (super.noSuchMethod(Invocation.method(#getAlbum, [], {#slug: slug}),
              returnValue: Future<_i11.Album>.value(_FakeAlbum_11()))
          as _i16.Future<_i11.Album>);
  @override
  _i16.Future<_i4.ListResponse<_i11.ListAlbum>> getAlbums(
          {String? search, int? limit, int? offset}) =>
      (super.noSuchMethod(
              Invocation.method(#getAlbums, [],
                  {#search: search, #limit: limit, #offset: offset}),
              returnValue: Future<_i4.ListResponse<_i11.ListAlbum>>.value(
                  _FakeListResponse_2<_i11.ListAlbum>()))
          as _i16.Future<_i4.ListResponse<_i11.ListAlbum>>);
  @override
  _i16.Future<_i4.ListResponse<_i21.Slide>> getSlides(
          {int? limit, int? offset}) =>
      (super.noSuchMethod(
          Invocation.method(#getSlides, [], {#limit: limit, #offset: offset}),
          returnValue: Future<_i4.ListResponse<_i21.Slide>>.value(
              _FakeListResponse_2<_i21.Slide>())) as _i16
          .Future<_i4.ListResponse<_i21.Slide>>);
  @override
  _i16.Future<_i4.ListResponse<_i22.FrontpageArticle>> getFrontpageArticles(
          {int? limit, int? offset}) =>
      (super.noSuchMethod(
          Invocation.method(
              #getFrontpageArticles, [], {#limit: limit, #offset: offset}),
          returnValue: Future<_i4.ListResponse<_i22.FrontpageArticle>>.value(
              _FakeListResponse_2<_i22.FrontpageArticle>())) as _i16
          .Future<_i4.ListResponse<_i22.FrontpageArticle>>);
  @override
  _i16.Future<_i12.Device> registerDevice(
          {String? token, String? type, bool? active = true}) =>
      (super.noSuchMethod(
              Invocation.method(#registerDevice, [],
                  {#token: token, #type: type, #active: active}),
              returnValue: Future<_i12.Device>.value(_FakeDevice_12()))
          as _i16.Future<_i12.Device>);
  @override
  _i16.Future<_i12.Device> getDevice({int? pk}) =>
      (super.noSuchMethod(Invocation.method(#getDevice, [], {#pk: pk}),
              returnValue: Future<_i12.Device>.value(_FakeDevice_12()))
          as _i16.Future<_i12.Device>);
  @override
  _i16.Future<_i12.Device> disableDevice({int? pk}) =>
      (super.noSuchMethod(Invocation.method(#disableDevice, [], {#pk: pk}),
              returnValue: Future<_i12.Device>.value(_FakeDevice_12()))
          as _i16.Future<_i12.Device>);
  @override
  _i16.Future<_i12.Device> updateDeviceToken({int? pk, String? token}) => (super
      .noSuchMethod(
          Invocation.method(#updateDeviceToken, [], {#pk: pk, #token: token}),
          returnValue: Future<_i12.Device>.value(_FakeDevice_12())) as _i16
      .Future<_i12.Device>);
  @override
  _i16.Future<_i12.Device> updateDeviceReceiveCategory(
          {int? pk, List<String>? receiveCategory}) =>
      (super.noSuchMethod(
              Invocation.method(#updateDeviceReceiveCategory, [],
                  {#pk: pk, #receiveCategory: receiveCategory}),
              returnValue: Future<_i12.Device>.value(_FakeDevice_12()))
          as _i16.Future<_i12.Device>);
  @override
  _i16.Future<_i4.ListResponse<_i23.PushNotificationCategory>>
      getCategories() => (super.noSuchMethod(
              Invocation.method(#getCategories, []),
              returnValue:
                  Future<_i4.ListResponse<_i23.PushNotificationCategory>>.value(
                      _FakeListResponse_2<_i23.PushNotificationCategory>()))
          as _i16.Future<_i4.ListResponse<_i23.PushNotificationCategory>>);
  @override
  _i16.Future<_i13.SalesOrder> claimSalesOrder({String? pk}) =>
      (super.noSuchMethod(Invocation.method(#claimSalesOrder, [], {#pk: pk}),
              returnValue: Future<_i13.SalesOrder>.value(_FakeSalesOrder_13()))
          as _i16.Future<_i13.SalesOrder>);
}

/// A class which mocks [PaymentUserCubit].
///
/// See the documentation for Mockito's code generation for more information.
class MockPaymentUserCubit extends _i1.Mock implements _i24.PaymentUserCubit {
  MockPaymentUserCubit() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i14.ApiRepository get api => (super.noSuchMethod(Invocation.getter(#api),
      returnValue: _FakeApiRepository_14()) as _i14.ApiRepository);
  @override
  _i15.DetailState<_i9.PaymentUser> get state =>
      (super.noSuchMethod(Invocation.getter(#state),
              returnValue: _FakeDetailState_15<_i9.PaymentUser>())
          as _i15.DetailState<_i9.PaymentUser>);
  @override
  _i16.Stream<_i15.DetailState<_i9.PaymentUser>> get stream =>
      (super.noSuchMethod(Invocation.getter(#stream),
              returnValue: Stream<_i15.DetailState<_i9.PaymentUser>>.empty())
          as _i16.Stream<_i15.DetailState<_i9.PaymentUser>>);
  @override
  bool get isClosed =>
      (super.noSuchMethod(Invocation.getter(#isClosed), returnValue: false)
          as bool);
  @override
  _i16.Future<void> load() => (super.noSuchMethod(Invocation.method(#load, []),
      returnValue: Future<void>.value(),
      returnValueForMissingStub: Future<void>.value()) as _i16.Future<void>);
  @override
  void emit(_i15.DetailState<_i9.PaymentUser>? state) =>
      super.noSuchMethod(Invocation.method(#emit, [state]),
          returnValueForMissingStub: null);
  @override
  void onChange(_i17.Change<_i15.DetailState<_i9.PaymentUser>>? change) =>
      super.noSuchMethod(Invocation.method(#onChange, [change]),
          returnValueForMissingStub: null);
  @override
  void addError(Object? error, [StackTrace? stackTrace]) =>
      super.noSuchMethod(Invocation.method(#addError, [error, stackTrace]),
          returnValueForMissingStub: null);
  @override
  void onError(Object? error, StackTrace? stackTrace) =>
      super.noSuchMethod(Invocation.method(#onError, [error, stackTrace]),
          returnValueForMissingStub: null);
  @override
  _i16.Future<void> close() => (super.noSuchMethod(
      Invocation.method(#close, []),
      returnValue: Future<void>.value(),
      returnValueForMissingStub: Future<void>.value()) as _i16.Future<void>);
}
