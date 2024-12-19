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
    classpath("com.google.gms:google-services:4.4.2") // для firebase-пушей
    classpath("com.huawei.agconnect:agcp:1.9.1.302") // для huawei-пушей
  }
}

//...

allprojects {
    repositories {
        google()
        mavenCentral()
        maven{
            url "https://developer.huawei.com/repo/" // для huawei-пушей
        }
        maven {
            url "https://artifactory-external.vkpartner.ru/artifactory/maven" // для rustore-пушей
        }
        //...
    }
}

```

В android/app/build.gradle необходимо добавить следующие строки:
```groovy
plugins {
    //...
    id "com.google.gms.google-services" // если используется firebase
    id "com.huawei.agconnect" // если используется huawei
    //...
}

### iOS



### Инициализация
Для инициализации сдк с использованием Firebase или Huawei добавьте следующий код в функцию main:

```dart
CxHubSdk.init();
```

В случае использования имплементации Rustore:

```dart
CxHubSdk.init("[yourRustoreProjectId]");
```

Для минимального функционала (прием пушей) этого достаточно. 

## API




