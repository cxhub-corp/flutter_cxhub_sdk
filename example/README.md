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

### iOS