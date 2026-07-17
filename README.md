# buymarket_frontend

A new Flutter project.

## Google Sign-In

El backend recibe el ID token de Google en `POST /auth/google`. El cliente web
OAuth configurado en `GOOGLE_CLIENT_ID` del backend debe usarse también como
cliente de servidor en la app.

### Android

1. Crear un cliente OAuth Android para `ar.com.buymarket.mobile` con los SHA-1
   de las firmas debug y release. Se pueden consultar con
   `cd android && gradlew.bat signingReport`.
2. Ejecutar la app pasando el cliente OAuth web del backend:

   ```sh
   flutter run --dart-define=GOOGLE_SERVER_CLIENT_ID=CLIENTE_WEB.apps.googleusercontent.com
   ```

El build release todavía usa la firma debug del proyecto. Antes de publicar se
debe configurar la firma release y registrar también su SHA en Google Cloud.

### iOS

1. Crear un cliente OAuth iOS para el bundle ID `ar.com.buymarket.mobile`.
2. Reemplazar los tres placeholders de `ios/Flutter/GoogleAuth.xcconfig` con el
   cliente iOS, el cliente web del backend y el cliente iOS invertido.
3. Instalar pods y compilar desde macOS. El deployment target actual (iOS 13)
   cumple el mínimo del plugin.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
