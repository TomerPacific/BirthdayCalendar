const String applicationName = "Birthday Calendar";

const userBirthdayNameKey = "name";
const userBirthdayDateKey = "birthdayDate";
const userBirthdayHasNotificationKey = "hasNotification";
const userBirthdayPhoneNumberKey = "phoneNumber";
const userBirthdayNotificationIdKey = "notificationId";
const userBirthdayContactIdKey = "contactId";

const darkModeKey = "darkMode";
const contactsPermissionKey = "contacts";
const notificationsPermissionKey = "notifications";
const contactsPermissionStatusKey = "contactsPermissionStatusKey";
const notificationsPermissionStatusKey = "notificationsPermissionStatusKey";

const versionToMigrateNotificationStatusFrom = "1.2.1";
const didAlreadyMigrateNotificationStatusFlag = "migrateNotificationStatus";
const didAlreadyMigrateNotificationIdsFlag = "migrateNotificationIds";
const didAlreadyMigrateContactIdsFlag = "migrateContactIds";

enum NotificationPermissionState {
  unknown,
  granted,
  deniedTemporary,
  deniedPermanently,
}