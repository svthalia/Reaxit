import 'package:reaxit/models.dart';
import 'package:reaxit/api/exceptions.dart';

/// Provides an interface to the api.
///
/// Its methods may throw an [ApiException] if there are unexpected results.
/// In case credentials cannot be refreshed, this calls `logOut`, which should
/// close the client and indicates that the user is no longer logged in.
abstract class ApiRepository {
  ApiRepository();

  /// Closes the connection to the api. This must be called when logging out.
  void close();

  /// Get the [Event] with the `pk`.
  Future<Event> getEventByPk({required int pk});

  Future<Event> getEventBySlug({required String slug});

  /// Get a list of [Event]s.
  ///
  /// Use `limit` and `offset` for pagination. [ListResponse.count] is the
  /// total number of [Events] that can be returned.
  /// Use `search` to filter on name, `ordering` to order with values in
  /// {'start', 'end', '-start', '-end'}, and `start` and/or `end` to filter on
  /// a time range.
  Future<ListResponse<Event>> getEvents({
    String? search,
    int? limit,
    int? offset,
    String? ordering,
    DateTime? start,
    DateTime? end,
  });

  /// Get a list of [PartnerEvent]s.
  ///
  /// Use `limit` and `offset` for pagination. [ListResponse.count] is the
  /// total number of [PartnerEvents] that can be returned.
  /// Use `search` to filter on name, `ordering` to order with values in
  /// {'start', 'end', '-start', '-end'}, and `start` and/or `end` to filter on
  /// a time range.
  Future<ListResponse<PartnerEvent>> getPartnerEvents({
    String? search,
    int? limit,
    int? offset,
    String? ordering,
    DateTime? start,
    DateTime? end,
  });

  /// Get the [EventRegistration]s for the [Event] with the `pk`.
  ///
  /// Use `limit` and `offset` for pagination. [ListResponse.count] is the
  /// total number of [EventRegistration]s that can be returned.
  ///
  /// These [EventRegistration]s are not cancelled. It's the publicly visible
  /// list. The admin of an event can use [getAdminEventRegistrations()] to
  /// include cancelled or queued registrations.
  Future<ListResponse<EventRegistration>> getEventRegistrations({
    required int pk,
    int? limit,
    int? offset,
  });

  /// Register for the [Event] with the `pk`.
  Future<EventRegistration> registerForEvent(int pk);

  /// Cancel the [EventRegistration] with `registrationPk`
  /// for the [Event] with `eventPk`.
  Future<void> cancelRegistration({
    required int eventPk,
    required int registrationPk,
  });

  /// Get the [RegistrationField]s of [EventRegistration] `registrationPk`
  /// for [Event] `eventPk`.
  ///
  /// Returns a [Map] of identifiers and corresponding [RegistrationFields].
  Future<Map<String, RegistrationField>> getRegistrationFields({
    required int eventPk,
    required int registrationPk,
  });

  /// Update the [RegistrationField]s of EventRegistration] `registrationPk`
  /// for [Event] `eventPk` to the values in `fields`.
  ///
  /// `fields` must contain every [RegistrationField] returned by
  /// [this.getRegistrationFields()], possibly with null values.
  Future<void> updateRegistrationFields({
    required int eventPk,
    required int registrationPk,
    required Map<String, RegistrationField> fields,
  });

  /// Get the [AdminEvent] with the `pk`.
  Future<AdminEvent> getAdminEvent({required int pk});

  /// Get the [AdminEventRegistration]s of the [Event] with the `pk`.
  ///
  /// Use `limit` and `offset` for pagination. [ListResponse.count] is the
  /// total number of registrations that can be returned.
  /// Use `search` to filter on name, `ordering` to order with values in
  /// {'date', 'date_cancelled', 'queue_position', '-date', '-date_cancelled',
  /// '-queue_position'}, and `cancelled` to filter on cancelled registrations.
  Future<ListResponse<AdminEventRegistration>> getAdminEventRegistrations({
    required int pk,
    int? limit,
    int? offset,
    String? search,
    String? ordering,
    bool? cancelled,
  });

  /// Mark the user's registration for [Event] `pk` as present, using `token`.
  Future<String> markPresentEventRegistration({
    required int eventPk,
    required String token,
  });

  /// Mark registration `registrationPk` for [Event] `eventPk` as `present`.
  Future<AdminEventRegistration> markPresentAdminEventRegistration({
    required int eventPk,
    required int registrationPk,
    required bool present,
  });

  /// Mark registration `registrationPk` as paid with `paymentType`.
  Future<Payable> markPaidAdminEventRegistration({
    required int registrationPk,
    required PaymentType paymentType,
  });

  /// Delete the payment for registration `registrationPk`.
  Future<void> markNotPaidAdminEventRegistration({
    required int registrationPk,
  });

  /// Get the [AdminFoodOrder]s of the [FoodEvent] with the `pk`.
  ///
  /// Use `limit` and `offset` for pagination. [ListResponse.count] is the
  /// total number of orders that can be returned.
  Future<ListResponse<AdminFoodOrder>> getAdminFoodOrders({
    required int pk,
    int? limit,
    int? offset,
    String? search,
  });

  /// Mark food order `orderPk` as paid with `paymentType`.
  Future<Payable> markPaidAdminFoodOrder({
    required int orderPk,
    required PaymentType paymentType,
  });

  /// Delete the payment for food order `orderPk`.
  Future<void> markNotPaidAdminFoodOrder({
    required int orderPk,
  });

  /// Get the [FoodEvent] with the `pk`.
  Future<FoodEvent> getFoodEvent(int pk);

  /// Get a list of [FoodEvent]s.
  ///
  /// Use `limit` and `offset` for pagination. [ListResponse.count] is the
  /// total number of [FoodEvents] that can be returned.
  /// Use `search` to filter on name, `ordering` to order with values in
  /// {'start', 'end', '-start', '-end'}, and `start` and/or `end` to filter
  /// on a time range.
  Future<ListResponse<FoodEvent>> getFoodEvents({
    int? limit,
    int? offset,
    String? ordering,
    DateTime? start,
    DateTime? end,
  });

  /// Get the [FoodEvent] that is currently going on.
  Future<FoodEvent> getCurrentFoodEvent();

  /// Get the [FoodOrder] for the [FoodEvent] with the `pk`.
  Future<FoodOrder> getFoodOrder(int pk);

  /// Cancel your [FoodOrder] for the [FoodEvent] with the `pk`.
  Future<void> cancelFoodOrder(int pk);

  /// Place an order [Product] `productPk` on [FoodEvent] `eventPk`.
  Future<FoodOrder> placeFoodOrder({
    required int eventPk,
    required int productPk,
  });

  /// Change your order to [Product] `productPk` on [FoodEvent] `eventPk`.
  Future<FoodOrder> changeFoodOrder({
    required int eventPk,
    required int productPk,
  });

  /// Get a list of [Product]s for the [FoodEvent] with the `pk`.
  ///
  /// Use `limit` and `offset` for pagination. [ListResponse.count] is the
  /// total number of [Product]s that can be returned.
  /// Use `search` to filter on name.
  Future<ListResponse<Product>> getFoodEventProducts(
    int pk, {
    int? limit,
    int? offset,
    String? search,
  });

  /// Get the [PaymentUser] of the currently logged in member.
  Future<PaymentUser> getPaymentUser();

  /// Get the [Payable] for the [FoodOrder] with the `foodOrderPk`.
  Future<Payable> getFoodOrderPayable({required int foodOrderPk});

  /// Pay for the [FoodOrder] with the `foodOrderPk` with Thalia Pay.
  Future<Payable> thaliaPayFoodOrder({required int foodOrderPk});

  /// Get the [Payable] for the [EventRegistration] with the `registrationPk`.
  Future<Payable> getEventRegistrationPayable({required int registrationPk});

  /// Pay for the [EventRegistration] with the `registrationPk` with Thalia Pay.
  Future<Payable> thaliaPayRegistration({required int registrationPk});

  /// get the [Payable] for the sales order with the `salesOrderPk`.
  Future<Payable> getSalesOrderPayable({required String salesOrderPk});

  /// Pay for the sales order with the `salesOrderPk` with Thalia Pay.
  Future<Payable> thaliaPaySalesOrder({required String salesOrderPk});

  /// Get the [Member] with the `pk`.
  Future<Member> getMember({required int pk});

  /// Get a list of [ListMember]s.
  ///
  /// Use `limit` and `offset` for pagination. [ListResponse.count] is the
  /// total number of [ListMember]s that can be returned.
  /// Use `search` to filter on name, `ordering` to order with values in
  /// {'last_name', 'first_name', 'username', '-last_name', '-first_name',
  /// '-username'},
  Future<ListResponse<ListMember>> getMembers({
    String? search,
    int? limit,
    int? offset,
    String? ordering,
  });

  /// Get the logged in [FullMember].
  Future<FullMember> getMe();

  /// Update the avatar of the logged in member.
  ///
  /// `filePath` should be the path of a jpg image.
  Future<void> updateAvatar(String file);

  /// Update the description of the logged in member.
  Future<void> updateDescription(String description);

  /// Get the [Album] with the `slug`.
  Future<Album> getAlbum({required String slug});

  /// Create or delete a like on the photo with the `id`.
  Future<void> updateLiked(int id, bool liked);

  /// Get a list of [ListAlbum]s.
  ///
  /// Use `limit` and `offset` for pagination. [ListResponse.count] is the
  /// total number of [ListAlbum]s that can be returned.
  /// Use `search` to filter on name or date.
  Future<ListResponse<ListAlbum>> getAlbums({
    String? search,
    int? limit,
    int? offset,
  });

  /// Get a list of [Slide]s.
  ///
  /// Use `limit` and `offset` for pagination. [ListResponse.count] is the
  /// total number of [Slide]s that can be returned.
  Future<ListResponse<Slide>> getSlides({
    int? limit,
    int? offset,
  });

  /// Get a list of [FrontpageArticle]s.
  ///
  /// Use `limit` and `offset` for pagination. [ListResponse.count] is the
  /// total number of [FrontpageArticle]s that can be returned.
  Future<ListResponse<FrontpageArticle>> getFrontpageArticles({
    int? limit,
    int? offset,
  });

  /// Create a new [Device] for receiving push notifications.
  ///
  /// This is used to let the backend know where to send notifications. The
  /// `type` should be one of {'android', 'ios'}. This method creates a new
  /// device. When the token changes, do not create a new device, but use
  /// [updateDeviceToken].
  Future<Device> registerDevice({
    required String token,
    required String type,
    bool active = true,
  });

  /// Get the [Device] with the `pk`.
  Future<Device> getDevice({required int pk});

  /// Set `active` to `false` for the [Device] with the `pk`.
  Future<Device> disableDevice({required int pk});

  /// Update the `token` of the [Device] with the `pk`.
  Future<Device> updateDeviceToken({required int pk, required String token});

  /// Update the `receiveCategory` of the [Device] with the `pk`.
  Future<Device> updateDeviceReceiveCategory({
    required int pk,
    required List<String> receiveCategory,
  });

  /// Get the list of all [PushNotificationCategory]s.
  Future<ListResponse<PushNotificationCategory>> getCategories();

  /// Claim and get the [SalesOrder] with the `pk`.
  Future<SalesOrder> claimSalesOrder({required String pk});

  /// Get a list of [ListGroup]s.
  ///
  /// Use `limit` and `offset` for pagination, and `type`, `start`, `end` and
  /// `search` for filtering. [ListResponse.count] is the total number of
  /// [ListGroup]s that can be returned.
  Future<ListResponse<ListGroup>> getGroups({
    int? limit,
    int? offset,
    MemberGroupType? type,
    DateTime? start,
    DateTime? end,
    String? search,
  });

  /// Get the [Group] with the `pk`.
  Future<Group> getGroup({required int pk});

  /// Get the [Group] of a board with the `since` and `until`.
  Future<Group> getBoardGroup({required int since, required int until});

  Future<ListResponse<AlbumPhoto>> getLikedPhotos({
    int? limit,
    int? offset,
  });

  /// Get a list of [Payment]'s of the current user.
  Future<ListResponse<Payment>> getPayments({
    int? limit,
    int? offset,
    String? ordering,
    DateTime? start,
    DateTime? end,
    List<PaymentType>? type,
    bool? settled,
  });
}
