# Aplicación de Tareas con Sincronización Offline

Aplicación móvil desarrollada en Flutter que permite gestionar tareas con soporte offline y sincronización automática cuando hay conexión a internet.

## 📱 Características

- Crear, editar, marcar como completadas y eliminar tareas
- Listar tareas con filtros (todas, pendientes, completadas)
- Sincronización automática cuando hay conexión
- Funcionamiento offline con persistencia local
- Interfaz de usuario intuitiva y responsiva

## 🏗️ Arquitectura y Tecnologías

- **Framework**: Flutter 3.x
- **Lenguaje**: Dart
- **Gestión de Estado**: Riverpod
- **Base de Datos Local**: SQLite con sqflite
- **Consumo de API**: http
- **Manejo de Conectividad**: connectivity_plus
- **Inyección de Dependencias**: provider
- **Generación de IDs**: uuid
- **Manejo de Fechas**: intl

## 📁 Estructura de Carpetas

```
lib/
├── core/
│   ├── constants/    # Constantes de la aplicación
│   ├── errors/       # Manejo de errores
│   ├── network/      # Cliente HTTP y manejo de red
│   └── utils/        # Utilidades y helpers
│
├── features/
│   └── tasks/
│       ├── data/
│       │   ├── datasources/  # Fuentes de datos (local y remoto)
│       │   ├── models/       # Modelos de datos
│       │   └── repositories/ # Implementaciones de repositorios
│       │
│       ├── domain/
│       │   ├── entities/     # Entidades de negocio
│       │   ├── repositories/ # Interfaces de repositorios
│       │   └── usecases/     # Casos de uso
│       │
│       └── presentation/
│           ├── providers/    # Proveedores de estado
│           └── screens/      # Pantallas de la aplicación
│
└── main.dart         # Punto de entrada de la aplicación
```

## 🚀 Instalación

1. Asegúrate de tener instalado Flutter SDK (versión 3.x o superior)
2. Clona el repositorio:
   ```bash
   git clone https://github.com/tu-usuario/todo-offline-flutter.git
   cd todo-offline-flutter
   ```
3. Instala las dependencias:
   ```bash
   flutter pub get
   ```
4. Configura la URL de la API en `lib/core/constants/api_constants.dart`
5. Ejecuta la aplicación:
   ```bash
   flutter run
   ```

## 🔄 Cómo probar el modo offline y sincronización

1. **Prueba de Modo Offline**:
   - Abre la aplicación con conexión a internet
   - Crea algunas tareas
   - Activa el modo avión en tu dispositivo
   - Sigue interactuando con la aplicación (crear, editar, eliminar tareas)
   - Verás que los cambios se guardan localmente

2. **Prueba de Sincronización**:
   - Con el modo avión activado, realiza cambios en las tareas
   - Desactiva el modo avión para restaurar la conexión
   - La aplicación debería detectar automáticamente la conexión
   - Los cambios locales se sincronizarán con el servidor
   - Verifica que los cambios se reflejen en otros dispositivos conectados

## 📱 Capturas de Pantalla

*(Incluye aquí capturas de pantalla o GIFs de tu aplicación en funcionamiento)*

## 🛠️ Generación de APK

Para generar un APK de lanzamiento:

```bash
flutter clean
flutter pub get
flutter build apk --release
```

El APK se generará en: `build/app/outputs/flutter-apk/app-release.apl`

## 📝 Notas Adicionales

- La aplicación utiliza una estrategia "Last-Write-Wins" para resolver conflictos
- Las operaciones fallidas se reintentan automáticamente con backoff exponencial
- Se recomienda probar la aplicación en diferentes escenarios de conectividad

## 📄 Licencia

Este proyecto está bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para más detalles.
