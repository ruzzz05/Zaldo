# Zaldo

Gestor accesible de gastos personales hecho con Flutter. Práctica final de
Accesibilidad (4.º Ingeniería Informática, Universidad de León, curso 2026/2027).

## Estructura

- `zaldo/`: aplicación Flutter.
- `docs/`: memoria de la práctica, enunciado de la semana 5 y plantilla del portafolio.

## Funcionalidades

- **Registrar un gasto**: importe, categoría, fecha y descripción opcional, con validación y mensajes de error comprensibles.
- **Historial**: gastos del más reciente al más antiguo, filtros por fechas y categoría, y detalle de cada gasto (con borrado confirmado).
- **Resumen**: total del mes y desglose por categoría, con selector de mes.
- **Inicio**: último gasto, accesos y gráfico de barras de los últimos 7 días.

## Accesibilidad

- Semántica para lectores de pantalla (TalkBack): nombres, estados, encabezados, regiones vivas y orden de lectura.
- Respeta el tamaño de texto del sistema; probado hasta 3x.
- Controles de al menos 48×48 y contraste WCAG 2.2 AA.
- Nada depende solo del color: las categorías llevan nombre, icono y, en el gráfico, un patrón propio.
- Ninguna acción exige gestos complejos.
- Los datos se guardan solo en local.

## Ejecutar

```bash
cd zaldo
flutter pub get
flutter run -d chrome      # o un dispositivo/emulador Android
```

## Tests

```bash
cd zaldo
flutter test
flutter analyze
```

## Equipo (Grupo B)

Elena Jañez Morán, Miguel Ruz García, Ranime Essid y Pablo Rodríguez García.
