# Conectar un servicio propio

La app se inicia con `MobileLabRepository` en `lib/main.dart`. El dominio depende de `TalkRepository`. La compilación selecciona el host mediante `MOBILELAB_URL`. En esta versión, las tres operaciones corresponden a una colección sin autenticación.

| Operación del contrato | HTTP local | Qué debe garantizar un reemplazo |
| --- | --- | --- |
| `list()` | GET /api/talks | Devolver una lista completa de guiones con sus bloques y ensayos en orden. |
| `save(talk)` | PUT /api/talks/{id} | Reemplazar atómicamente el documento con ese ID. Reintentar el mismo contenido conserva un único ensayo. |
| `remove(id)` | DELETE /api/talks/{id} | Quitar también los ensayos de ese guion. |

Cada ensayo contiene fecha UTC, presupuesto original y una copia del nombre, objetivo y segundos reales de cada bloque. La app acepta documentos anteriores sin el campo opcional `runs`. Un JSON incompatible produce un error visible. El modo demo mantiene todos los documentos en un único cuaderno compartido por quienes alcanzan el proceso local.

1. Define el contrato del servicio en OpenAPI con el DTO de la semilla como ejemplo. Si la lista es paginada, reúne las páginas en el adaptador o amplía explícitamente la interfaz y el estado de pantalla.
2. Implementa `TalkRepository` con un cliente HTTPS inyectado. Si el servicio usa sesiones, obtén la credencial en el flujo de acceso, gestiona la renovación y autoriza por propietario en el servidor. Añade pruebas de 401, 403 y expiración.
3. Para escritura compartida, incorpora una revisión del guion y una precondición de versión. Ante conflicto, recupera el documento y permite reconciliar las ediciones. Define límites de tamaño y separa los ensayos en otra colección si el historial crece.
4. Sustituye la construcción del repositorio en `main.dart`. Conserva las pruebas de `Notebook` y widgets. Ejecuta el contrato contra un entorno de pruebas del nuevo backend y comprueba reintentos, idempotencia y eliminación. Guarda secretos de servidor en el servidor.

El sandbox local usa HTTP, datos sintéticos y un único escritor. Una desconexión durante un PUT deja el resultado incierto hasta refrescar. La historia se conserva en el equipo que ejecuta MobileLab. Los cambios en curso antes de pulsar Guardar viven en memoria.
