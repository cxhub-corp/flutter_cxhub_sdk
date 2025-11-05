# CxHubSdk Example
Пример приложения в котором при помощи dependency overrides можно менять андроид-имплементацию

## Сборка

### Android

В android/app/src (исходный код Android-части вашего приложения) необходимо добавить json-ключ google-services.json, или agconnect-services.json в зависимости от того какие именно пуш-уведомления вы подключаете. Для использования rustore-имплементации дополнительного файла не нужно.

В android/app/src/main/res/values необходимо добавить файл cxhub.xml следующего вида:

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="cxhub_resource_icon_id">[drawable-ресурс иконки сообщения]</string>
    <string name="cxhub_integration_id" translatable="false">[id итеграции из личного кабинета cxhub]</string>
    <string name="cxhub_application_secret" translatable="false">[секретный ключ интеграции из личного кабинета]</string>
    <string name="cxhub_api_host" translatable="false">[путь к вашему проекту cxhub, например https://mytest.cxhub.ru]/callback-service/</string>
    <bool name="cxhub_trust_all_certificates">true</bool>
</resources>
```

В android/gradle.properties добавить следующие строки (изменить версии на актуальные):

```toml
flutter.minSdkVersion=24
flutter.targetSdkVersion=36
flutter.compileSdkVersion=36
flutter.ndkVersion=27.0.12077973
```

### iOS
В терминале переходим в папку проекта (ios), запускаем:
pod deintegrate
pod repo update
pod update (или pod install)

- Открываем Runner.xcworkspace

- Добавляем в проект файл Notify.plist следующего вида:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Enabled</key>
	<true/>
	<key>Debug</key>
	<true/>
	<key>LibNotify</key>
	<dict>
		<key>UNNotificationExtensionCategory</key>
		<array>
			<string>libnotify_default</string>
			<string>libnotify_button_queue_1</string>
			<string>libnotify_button_queue_2</string>
			<string>libnotify_button_queue_3</string>
			<string>libnotify_button_queue_4</string>
			<string>libnotify_button_queue_5</string>
		</array>
		<key>Activity</key>
		<dict>
			<key>Colors</key>
			<dict>
				<key>BackgroundColor</key>
				<dict>
					<key>Dark</key>
					<string>#030303</string>
					<key>Light</key>
					<string>#DDDDDD</string>
				</dict>
				<key>TextColor</key>
				<dict>
					<key>Dark</key>
					<string>#DDDDDD</string>
					<key>Light</key>
					<string>#030303</string>
				</dict>
				<key>AccentColor</key>
				<dict>
					<key>Dark</key>
					<string>#219653</string>
					<key>Light</key>
					<string>#219653</string>
				</dict>
				<key>ButtonTextColor</key>
				<dict>
					<key>Dark</key>
					<string>#70D098</string>
					<key>Light</key>
					<string>#70D098</string>
				</dict>
				<key>CloseButtonColor</key>
				<dict>
					<key>Dark</key>
					<string>#6FCF97</string>
					<key>Light</key>
					<string>#6FCF97</string>
				</dict>
				<key>DarkModeSupported</key>
				<true/>
			</dict>
			<key>FontType</key>
			<string>Custom</string>
		</dict>
		<key>Enabled</key>
		<true/>
		<key>Application</key>
		<dict>
			<key>ApiUrlHost</key>
			<string>*YOUR_CXHUB_PROJECT_URL*</string>
			<key>IntegrationId</key>
			<string>*YOUR_CXHUB_INTEGRATION_ID*</string>
			<key>Secret</key>
			<string>*YOUR_CXHUB_INTEGRATION_SECRET*</string>
		</dict>
	</dict>
	<key>SharedGroupId</key>
	<string>*YOUR_APPLE_SHARED_GROUP_ID*</string>
</dict>
</plist>
```

- модифицируем (заполняем своими параметрами) Root -> LibNotify -> Application:
 - ApiUrlHost: <базовый URL проекта в CxHub>/callback-service/  (пример: https://yourCXHubProject.cxhub.ru/callback-service/ )
 - IntegrationId: идентификатор интеграции в CxHub (получаем из настроек интеграции в Web интерфейсе личного кабинета CxHub)
 - Secret: секрет интеграции в CxHub (получаем из настроек интеграции в Web интерфейсе личного кабинета CxHub)

 - модифицируем (заполняем своими параметрами) Root -> SharedGroupId :  ваш идентификатор shared_group для приложения

*Важно*: параметр *Root -> Debug* по умолчанию установлен *True*, в релизной сборке приложения его необходимо установить *False*

Остальные параметры оставляем без изменений.

Файл *Notify.plist* описывает основные настройки для SDK, поэтому в "Target Membership" у него *обязательно* должен быть включены "галочки" для всех таргетов приложения (основной, ServiceExtension, ContentExtension)

- Добавляем свои параметры в настройки проекта (заменяем <yourBundleId>, <your_apple_app_group> - ваш SharedGroupId) для всех компонентов\таргетов (приложение, ServiceExtension, ContentExtension): 
    - BundleIdentifier -> ваш идентификатор приложения у Apple
    - AppGroups -> ваш SharedGroupId
*Важно*: значение <your_apple_app_group> подставляем в соответствующие места в Runner.entitlements, ServiceExtension.entitlements, ContentExtension.entitlements
    - Ваши подписи к приложению (ProvisioningProfile, Team, Signing Certificate)



Если нет ошибок, то далее там же запускаем:

flutter build ios

Переходим в XCode , выбираем устройство для установки, запускаем приложение.