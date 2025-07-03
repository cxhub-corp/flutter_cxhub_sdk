@Echo Off

cd ./cxhub_platform_interface
START /B /WAIT cmd /c "flutter clean"
START /B /WAIT cmd /c "flutter pub get"
cd ../cxhub_android_firebase
START /B /WAIT cmd /c "flutter clean"
START /B /WAIT cmd /c "flutter pub get"
cd ../cxhub_android_huawei
START /B /WAIT cmd /c "flutter clean"
START /B /WAIT cmd /c "flutter pub get"
cd ../cxhub_android_rustore
START /B /WAIT cmd /c "flutter clean"
START /B /WAIT cmd /c "flutter pub get"
cd ../cxhub_ios
START /B /WAIT cmd /c "flutter clean"
START /B /WAIT cmd /c "flutter pub get"
cd ../cxhub_sdk
START /B /WAIT cmd /c "flutter clean"
START /B /WAIT cmd /c "flutter pub get"
cd ../example
START /B /WAIT cmd /c "flutter clean"
START /B /WAIT cmd /c "flutter pub get"
cd ../cxhub_sdk/example
START /B /WAIT cmd /c "flutter clean"
START /B /WAIT cmd /c "flutter pub get"
cd ../..