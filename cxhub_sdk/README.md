# CxHubSdk
Обертка для нативных SDK CxHub для использования с Flutter.

Важный момент: оригинальные нативные SDK CxHub предназначены для использования с аккаунтами Firebase/Huawei/Rustore и APNs клиента, 
само пуш-уведомление приходит на приложение клиента, после чего обрабатывается при помощи SDK CxHub, поэтому внедрение включает 
в себя модификацию нативных частей Flutter-приложения.

## Интеграция в приложение

### Зависимости
Добавьте следующий код в pubspec.yaml вашего проекта:

```yaml
dependencies:
  # ...
  cxhub_sdk: 0.0.1
#dependency_overrides:
#  cxhub_android: 0.0.1-huawei
#  cxhub_android: 0.0.1-rustore
# ...
```

Для использования дефолтной реализации пуш-уведомлений для Android через Firebase не требуется переопределения зависимостей. 

Для использования Huawei или Rustore уведомлений необходимо раскомментировать нужный пункт. 
То есть переход на нужную имплементацию для Android реализован как переопределение версии Android-модуля сдк.

Для iOS используется только APNs.


### Android

В android/app/src (исходный код Android-части вашего приложения) необходимо добавить json-ключ google-services.json, 
или agconnect-services.json в зависимости от того какие именно пуш-уведомления вы подключаете. 
Для использования rustore-имплементации такого файла не нужно.

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

В android/build.gradle необходимо добавить следующие строки:

```groovy
buildscript{
  repositories {
    google() 
    mavenCentral()
    maven{
      url "https://developer.huawei.com/repo/" // для huawei
    }

    maven{
       url "https://artifactory-external.vkpartner.ru/artifactory/maven" // для rustore
    }
    //...
  }

  dependencies {
    classpath("com.google.gms:google-services:4.4.2") // для firebase
    classpath("com.huawei.agconnect:agcp:1.9.1.302") // для huawei
  }
}

//...

allprojects {
    repositories {
        google()
        mavenCentral()
        maven{
            url "https://developer.huawei.com/repo/" // для huawei
        }
        maven {
            url "https://artifactory-external.vkpartner.ru/artifactory/maven" // для rustore
        }
        //...
    }
}
```

Репозитории помеченные комментариями добавляются только в случае использования указанного в них транспорта.

В android/app/build.gradle необходимо добавить следующие строки:
```groovy
plugins {
    //...
    id "com.google.gms.google-services" // если используется firebase
    id "com.huawei.agconnect" // если используется huawei
    //...
}
```

Плагины помеченные комментариями добавляются только в случае использования указанного в них транспорта.


При сборке с плагином CxHubSdk в merged манифест Android-приложения добавляются следующие разрешения (руками добавлять не нужно):

```xml
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
    <uses-permission android:name="android.permission.READ_PHONE_STATE" />
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    <uses-permission android:name="android.permission.WAKE_LOCK" />
    <uses-permission android:name="com.google.android.c2dm.permission.RECEIVE" />
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
```

### iOS



### Инициализация
Для инициализации сдк с использованием Firebase или Huawei добавьте следующий код в функцию main:

```dart
CxHubSdk.init();
```

В случае использования Rustore:

```dart
CxHubSdk.init("[yourRustoreProjectId]");
```

Для минимального функционала (прием пушей) этого достаточно. 

## API
Апи представлено одним статическим интерфейсом "CxHubSdk".

### Методы:

```dart
static void init({String? param});
```
Инициализация. Может принимать идентификатор проекта RuStore, если используются пуши RuStore.


```dart
static Future<String?> getMobileInstance();
```
Геттер мобильного инстанса. Возвращает сгенерированный SDK мобильный идентификатор клиента.


```dart
static Future<String?> getPushToken();
```
Геттер пуш-токена. Возвращает пуш-токен, выданный системой доставки пуш-уведомлений.


```dart
static Stream<String?> subscribeToPushToken();
```
Подписка на пуш-токен. В системах доставки пуш-уведомлений случается обновление токена.
При этом в возвращаемый поток эмитится новое значение. При подписке эмитится текущее значение токена.


```dart
static Future<MapEntry<String, String>?> getUserId();
```
Геттер идентификатора юзера. Идентификатор юзера - пользовательская настройка. Опциональна.
Пользователь может быть идентифицирован одним из уникальных значений предоставляемых им личных данных,
по совместному решению разработчика приложения и оператора ЛК CxHub.
Например, это почта или телефон. Ключом в возвращаемом MapEntry является тип этого значения, например Phone или Email.
Другие типы пользовательских параметров можно посмотреть, а так же добавить в личном кабинете CxHUb в разделе "пользовательские параметры".
В значении MapEntry содержится значение параметра. Если ранее не было задано в приложении - возвратит null.


```dart
static Future setUserId(String userIdType, String userIdValue)
```
Сеттер идентификатора юзера. Здесь userIdType - ключ из MapEntry предыдущего метода, а userIdValue - значение параметра.

```dart
static Future setUserProperties(Map<String, String> properties);
```
Сеттер прочих пользовательских параметров. Например FirstName, SecondName, MiddleName, Address... 
Полный список может быть наден и модифицирвоан в ЛК CxHub в разделе "пользовательские параметры". 

```dart
static Future collectEvent(String key,{String? value,Map<String, String>? properties,bool deliverImmediately = false});
```
Отправить событие. SDK автоматически отправляет события связанные с пуш-уведомлениями, которые оно обрабатывает.
Разработчик приложения может дополнительно отправлять события, отображаемые в ЛК CxHub типом "AppCustom".
Здесь:
* key - название события
* value - необязательное единичное значение события
* properties - необязательный набор дополнительных значений с указанием их типов/названий
* deliverImmediately - необходимость срочной доставки (если false) то будет отправлено не сразу, а с остальными событиями по расписанию

```dart
enum PostNotificationPermission {
  unknown,
  denied,
  granted,
}
```
Enum для состояния разрешения показа нотификаций.
Значения:
* unknown - может быть запрошено
* denied - запрещено, неизменяемый статус, разрешение может быть выдано только путем изменения разрешений самим пользователем в настройках ОС
* granted - предоставлено


```dart 
static Future<PostNotificationPermission> checkPermission();
```
Проверить текущий статус разрешения на показ пуш-уведомлений

```dart
static Future<PostNotificationPermission> requestPermission();
```
Запросить разрешение на показ пуш-уведомлений


