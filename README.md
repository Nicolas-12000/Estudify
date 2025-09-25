# Estudify 📚

Una app móvil para reservar salas de estudio: simple, enfocada y construida con Flutter y Supabase siguiendo principios de Clean Architecture.

Si estás aquí es porque quieres que la app sea fácil de mantener, testeable y preparada para producción. Este repositorio contiene la estructura básica y los bloques necesarios para lograrlo.

---

## 🏗️ Resumen de la arquitectura

Organizamos el código en capas para separar responsabilidades y facilitar pruebas:

```
lib/
├─ core/        # configuración, inyección de dependencias, utilidades y temas
├─ domain/      # entidades, casos de uso e interfaces de repositorio
├─ data/        # implementaciones, modelos y fuentes externas (Supabase)
└─ presentation/ # UI: pantallas, widgets y BLoCs
```

Cada carpeta contiene pequeñas piezas con una sola responsabilidad; esto facilita cambios y pruebas unitarias.

---

## ✨ Funcionalidades principales

- Registro e inicio de sesión usando Supabase Auth
- Listado de salas con filtros (capacidad, amenities, búsqueda)
- Reservas: crear, ver y cancelar
- Actualizaciones en tiempo real para reflejar cambios de estado de las salas

---

## � Archivos clave

- `lib/` — Código fuente (módulos por capa)
- `supabase/schema.sql` — Script SQL para crear tablas, funciones, triggers y políticas en Supabase
- `.env.example` — Plantilla para las variables de entorno (copia a `.env` en local)

---

## ⚙️ Prerrequisitos

- Flutter SDK (stable)
- Dart
- Cuenta en Supabase (proyecto creado)

---

## 🚀 Primeros pasos para ejecutar (local)

1. Copia la plantilla de entorno y añade tus claves:

```bash
cp .env.example .env
# luego edita .env con tu editor y pega SUPABASE_URL y SUPABASE_ANON_KEY
```

2. Instala dependencias:

```bash
flutter pub get
```

3. Ejecuta la app en un emulador o dispositivo:

```bash
flutter run
```

---

## 🗄️ Base de datos: despliegue del esquema en Supabase

En `supabase/schema.sql` tienes todo lo necesario: tablas `rooms` y `reservations`, tipos ENUM, funciones como `get_available_rooms` y `is_room_available`, triggers para `updated_at`, políticas RLS y datos de ejemplo.

Cómo aplicar el esquema:

1. Abre tu proyecto en la consola de Supabase → SQL Editor.
2. Crea una nueva query y pega el contenido de `supabase/schema.sql`.
3. Ejecuta y revisa la salida.

Si prefieres usar la CLI/psql:

```bash
psql "postgresql://<user>:<pass>@<host>:<port>/<dbname>" -f supabase/schema.sql
```

Notas importantes:

- El script activa Row Level Security (RLS). Las policies incluidas dejan que los usuarios autenticados manejen sólo sus propias reservas.
- No subas el `SUPABASE_SERVICE_ROLE_KEY` a la app cliente. Este key debe permanecer en servidor si necesitas ejecutar tareas administrativas.
- El script incluye datos de ejemplo — elimínalos o modifícalos para producción.

---

## 🔌 Conectar Flutter con Supabase (ejemplo mínimo)

Instala `flutter_dotenv` y `supabase_flutter`, carga las variables y sigue este ejemplo en `lib/main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
	WidgetsFlutterBinding.ensureInitialized();
	await dotenv.load(fileName: '.env');

	await Supabase.initialize(
		url: dotenv.env['SUPABASE_URL']!,
		anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
	);

	runApp(const MyApp());
}
```

Si necesitas acciones con privilegios (migraciones, limpieza masiva, tareas cron), ejecútalas desde un servidor usando `SUPABASE_SERVICE_ROLE_KEY`.

---

## 🧪 Consejos para desarrollo y despliegue

- Prueba el SQL en un entorno de staging antes de producción.
- Mantén `supabase/schema.sql` bajo control de versiones y documenta cualquier cambio.
- Revisa y ajusta las RLS policies si amplías los permisos o el modelo de datos.



