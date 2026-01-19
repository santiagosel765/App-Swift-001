# Camera Demo App - iOS Swift/SwiftUI

Una aplicación iOS profesional que captura fotos usando la cámara del dispositivo y las muestra en pantalla. Implementada siguiendo arquitectura **MVVM + Services** con buenas prácticas y código escalable.

## 📱 Características

- ✅ Captura de fotos con la cámara nativa del dispositivo
- ✅ Preview de imagen capturada con UI profesional
- ✅ Manejo completo de permisos de cámara con AVFoundation
- ✅ Alertas y estados para guiar al usuario
- ✅ Detección automática de disponibilidad de cámara (simulador vs dispositivo real)
- ✅ Opción de abrir Settings si el permiso está denegado
- ✅ UI limpia con gradientes, sombras y animaciones
- ✅ Arquitectura MVVM + Services
- ✅ Unit tests con mocks

## 🏗️ Arquitectura

La aplicación sigue el patrón **MVVM + Services**:

```
CameraDemoApp/
├── App/
│   └── CameraDemoApp.swift          # Entry point de la app
├── Views/
│   ├── CameraScreen.swift           # Pantalla principal
│   └── Components/
│       └── PrimaryButton.swift      # Botones reutilizables
├── ViewModels/
│   └── CameraViewModel.swift        # Lógica y estado de la cámara
├── Services/
│   ├── CameraPermissionService.swift # Manejo de permisos
│   ├── CameraCaptureService.swift    # Servicio de captura
│   └── CameraPicker.swift            # Wrapper de UIImagePickerController
├── Models/
│   ├── CameraState.swift            # Estados de la cámara
│   ├── CameraError.swift            # Errores de cámara
│   └── AlertModel.swift             # Modelo para alertas
├── Utils/
│   └── SettingsOpener.swift         # Utilidad para abrir Settings
└── Info.plist                       # Configuración y permisos

CameraDemoAppTests/
├── CameraViewModelTests.swift       # Tests del ViewModel
└── Mocks/
    ├── MockCameraPermissionService.swift
    └── MockCameraCaptureService.swift
```

### Separación de Responsabilidades

- **Views**: Solo UI declarativa en SwiftUI
- **ViewModels**: Estado (`@Published`), lógica de negocio y coordinación
- **Services**: Interacción con APIs del sistema (AVFoundation, UIKit)
- **Models**: Estructuras de datos y estados
- **Utils**: Utilidades reutilizables

## 🚀 Cómo Ejecutar

### Requisitos

- **Xcode 15.0+** (o superior)
- **iOS 16.0+** como deployment target
- **iPhone físico** para probar la cámara (el simulador no tiene cámara)

### Pasos

1. **Clonar el repositorio**:
   ```bash
   git clone <repository-url>
   cd App-Swift-001
   ```

2. **Abrir el proyecto en Xcode**:
   - Abre Xcode
   - File → Open → Selecciona la carpeta `CameraDemoApp`
   - Si no existe un archivo `.xcodeproj`, crea uno nuevo:
     - File → New → Project
     - Selecciona "iOS" → "App"
     - Product Name: `CameraDemoApp`
     - Interface: SwiftUI
     - Language: Swift
     - Arrastra los archivos de las carpetas al proyecto

3. **Configurar el proyecto**:
   - Verifica que `Info.plist` esté incluido en el target
   - Verifica que el Bundle Identifier esté configurado
   - Selecciona un Team de desarrollo en Signing & Capabilities

4. **Ejecutar en dispositivo físico**:
   - Conecta tu iPhone vía USB
   - Selecciona tu dispositivo en el selector de destino
   - Presiona `Cmd + R` para ejecutar

### ⚠️ Nota sobre Simulador

**La cámara NO está disponible en el simulador de iOS**. Si ejecutas la app en el simulador:
- El botón "Tomar Foto" mostrará una alerta: "Cámara no disponible. Por favor, usa un dispositivo físico."
- Esta es una limitación del simulador de iOS, no un bug de la aplicación

Para probar la funcionalidad completa, **debes usar un iPhone físico**.

## 🔐 Permisos Requeridos

La aplicación requiere permiso de cámara. El mensaje que se muestra al usuario está configurado en `Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>Esta aplicación necesita acceso a la cámara para tomar fotos que se mostrarán en pantalla.</string>
```

### Flujo de Permisos

1. **Primera vez**: La app solicitará permiso automáticamente
2. **Permiso denegado**: Se mostrará una alerta con opción de abrir Settings
3. **Permiso concedido**: La cámara se abrirá inmediatamente

## 🎨 UI/UX

- **Empty State**: Icono de cámara con texto guía
- **Preview**: Imagen con bordes redondeados, borde sutil y sombra
- **Gradiente de fondo**: Colores neutros y profesionales
- **Botón primario**: Azul con gradiente y sombra
- **Botón secundario**: Estilo outline para acciones secundarias
- **Loading states**: Indicador de progreso durante operaciones
- **Alertas**: Mensajes claros con acciones relevantes

## 🧪 Tests

La aplicación incluye **unit tests** completos para el `CameraViewModel`.

### Ejecutar Tests

```bash
# En Xcode
Cmd + U
```

O desde la línea de comandos:
```bash
xcodebuild test -scheme CameraDemoApp -destination 'platform=iOS Simulator,name=iPhone 15'
```

### Cobertura de Tests

- ✅ Estado inicial del ViewModel
- ✅ Permiso denegado → muestra alerta correcta
- ✅ Permiso autorizado → abre sheet de cámara
- ✅ Permiso no determinado → solicita y maneja respuesta
- ✅ Cámara no disponible → muestra error
- ✅ Retomar foto limpia el estado
- ✅ Manejo de errores de captura
- ✅ Estados de loading

Los tests usan **mocks** de los servicios (`MockCameraPermissionService`, `MockCameraCaptureService`) para aislar la lógica del ViewModel.

## 📋 Criterios de Aceptación (QA)

- ✅ **No crashea**: Info.plist configurado correctamente
- ✅ **iPhone real**: Toma foto y la muestra
- ✅ **Permiso denegado**: Muestra alerta con opción de Settings
- ✅ **Simulador**: Muestra alerta "Cámara no disponible"
- ✅ **Código limpio**: MVVM + Services + Protocolos
- ✅ **Tests**: Unit tests con mocks incluidos
- ✅ **README**: Documentación completa

## 🛠️ Tecnologías Utilizadas

- **SwiftUI**: UI declarativa
- **AVFoundation**: Permisos de cámara
- **UIKit**: UIImagePickerController (via UIViewControllerRepresentable)
- **Combine**: Reactive programming con @Published
- **XCTest**: Unit testing

## 📝 Buenas Prácticas Implementadas

1. **Arquitectura clara**: MVVM separa UI de lógica
2. **Dependency Injection**: Services inyectados en ViewModels
3. **Protocolos**: Facilitan testing y escalabilidad
4. **Async/await**: Para operaciones asíncronas modernas
5. **Estados explícitos**: Enum `CameraState` para claridad
6. **Error handling**: Errores tipados con mensajes localizados
7. **Accesibilidad**: Labels para VoiceOver
8. **Testing**: Unit tests con mocks para aislamiento

## 🔄 Flujo de la Aplicación

1. Usuario abre la app → ve empty state
2. Usuario presiona "Tomar Foto"
3. App verifica disponibilidad de cámara
4. App verifica/solicita permisos
5. Si todo OK → abre cámara nativa
6. Usuario toma foto
7. Foto se muestra con preview profesional
8. Usuario puede "Tomar Nueva Foto" o "Limpiar"

## 🚧 Próximas Mejoras (Fuera de MVP)

- [ ] Guardar foto en galería
- [ ] Edición básica de imagen (crop, filtros)
- [ ] Múltiples fotos en galería
- [ ] Compartir foto
- [ ] Metadata de foto (ubicación, fecha)

## 📄 Licencia

Este es un proyecto de demostración educativa.

---

**Desarrollado con ❤️ usando Swift + SwiftUI**
