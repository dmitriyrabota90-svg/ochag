# Android Release Signing

The project is configured for Google Play release signing without committing real secrets.

## Files

- Example config committed to git: `android/key.properties.example`
- Real local config ignored by git: `android/key.properties`
- Recommended local keystore path ignored by git: `android/app/upload-keystore.jks`

## Create Keystore

Run from `mobile/` and keep the passwords somewhere safe:

```sh
keytool -genkey -v -keystore android/app/upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

If `keytool` is not in `PATH`, use the Android Studio JBR keytool:

```sh
"C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe" -genkey -v -keystore android/app/upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

## Configure Local Signing

Copy the example file:

```sh
copy android\key.properties.example android\key.properties
```

Fill `android/key.properties` with real local values:

```properties
storeFile=app/upload-keystore.jks
storePassword=YOUR_REAL_STORE_PASSWORD
keyAlias=upload
keyPassword=YOUR_REAL_KEY_PASSWORD
```

Do not commit `android/key.properties` or `android/app/upload-keystore.jks`.

## Build App Bundle

After the real keystore and `android/key.properties` are in place:

```sh
flutter build appbundle --release
```

The output will be under `build/app/outputs/bundle/release/`.
