# CxHubSdk
Обертка для нативных SDK CxHub для использования с Flutter.

Важный момент: оригинальные нативные SDK CxHub предназначены для использования с аккаунтами Firebase/Huawei/Rustore и APNs клиента, само пуш-уведомление приходит на приложение клиента, после чего обрабатывается при помощи SDK CxHub, поэтому внедрение включает в себя модификацию нативных частей Flutter-приложения.

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

Для использования дефолтной реализации пуш-уведомлений для Android через Firebase не требуется переопределения заисимостей. 

Для использования Huawei или Rustore уведомлений необходимо раскомментировать нужный пункт. То есть переход на нужную имплементацию для Android реализован как переопределение версии Android-модуля сдк.

Для iOS используется только APNs.


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

Репозитории помеченные комментариями добаляются только в случае использования указанного в них транспорта.

В android/app/build.gradle необходимо добавить следующие строки:
```groovy
plugins {
    //...
    id "com.google.gms.google-services" // если используется firebase
    id "com.huawei.agconnect" // если используется huawei
    //...
}
```

Плагины помеченные комментариями добаляются только в случае использования указанного в них траснспорта.


При сборке плагином CxHubSdk в merged манифест добавляются следующие разрешения:

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




