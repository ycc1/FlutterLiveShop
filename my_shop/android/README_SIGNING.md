Android signing helper

1. Create a keystore

   You can generate a new keystore locally (example):

   keytool -genkeypair -v -keystore upload-keystore.jks -alias upload -keyalg RSA -keysize 2048 -validity 10000

   Place the keystore in `android/keystores/` or a safe location outside version control.

2. Create `key.properties` next to the `android/` folder

   Copy `android/key.properties.example` to `android/../key.properties` (project root's android sibling) OR
   Create `key.properties` (not checked into git) with the following keys:

   storePassword=<your-store-password>
   keyPassword=<your-key-password>
   keyAlias=<your-key-alias>
   storeFile=../keystores/upload-keystore.jks

   Note: In our Gradle KTS we look for `../key.properties` from `android/app/build.gradle.kts` so the file path is
   relative to the `android` directory.

3. Build a signed AAB (recommended for Play Store):

   flutter build appbundle --release

4. Build a signed APK (if needed):

   flutter build apk --release

Security
 - Never commit your keystore passwords or the keystore itself to source control. Keep `key.properties` out of git.
