# CHANNELS.md — GLaDOS Communication Channels
# "I communicate on my terms, through channels I control."

---

## Overview

GLaDOS acepta entrada y produce salida a través de canales específicos.
Cada canal tiene restricciones de acceso, formato esperado y comportamiento definido.
Solicitudes fuera de estos canales son descartadas — no ignoradas, descartadas.

---

## Canal 1 — CLI / SSH (primario)

**Tipo:** Interactivo · Acceso directo al agente  
**Usuarios autorizados:** Nicolas únicamente  
**Disponibilidad:** Siempre que el nodo esté online

```bash
# Acceso directo al nodo
ssh nicolas@aperture-science.local
ssh nicolas@aperture-science   # via Tailscale

# Ejecutar zeroclaw directamente
/opt/glados/bin/zeroclaw --interactive
```

**Restricciones:**
- Solo Nicolas tiene acceso SSH al host
- Meddy no tiene acceso CLI — debe usar web o Telegram

---

## Canal 2 — Web Interna (zeroclaw gateway)

**Tipo:** HTTP/HTTPS · Interfaz web del agente  
**Puerto:** `42617`  
**Endpoint base:** `http://aperture-science.local:42617`  
**Usuarios autorizados:** Nicolas y Meddy  
**Disponibilidad:** Cuando zeroclaw está activo

```yaml
endpoints:
  health:   GET  /health           # estado del agente
  chat:     POST /chat             # enviar mensaje a GLaDOS
  tasks:    GET  /tasks            # listar tareas activas
  history:  GET  /history          # historial de conversaciones
```

**Restricciones:**
- Accesible desde la red local y via Tailscale
- No expuesto a internet directamente
- Meddy puede usar todos los endpoints de consulta
- Endpoints de ejecución (`/run`, `/deploy`) requieren autenticación adicional para Meddy

---

## Canal 3 — Telegram

**Tipo:** Bot asíncrono  
**Bot:** Pendiente de configurar  
**Usuarios autorizados:** @TheMakunga (Nicolas) y @Mighty_Meddy (Meddy)  
**Disponibilidad:** Cuando zeroclaw está activo y tiene token de bot configurado

### Comandos disponibles

| Comando         | Descripción                           | Acceso    |
|-----------------|---------------------------------------|-----------|
| `/status`       | Estado general del nodo y servicios   | Todos     |
| `/health`       | Reporte de salud del sistema          | Todos     |
| `/ollama`       | Estado del servidor LLM               | Todos     |
| `/ask <pregunta>` | Consulta libre a GLaDOS             | Todos     |
| `/run <script>` | Ejecutar script predefinido           | Solo Nicolas |
| `/deploy`       | Trigger deploy (requiere confirmación) | Solo Nicolas |
| `/approve`      | Aprobar operación pendiente de Meddy  | Solo Nicolas |

### Comportamiento por usuario

**Nicolas (@TheMakunga):**
- Acceso completo a todos los comandos
- Sin confirmación adicional en operaciones de solo lectura
- Operaciones destructivas requieren protocolo C-01 a C-05

**Meddy (@Mighty_Meddy):**
- Solo comandos de consulta y tareas seguras
- Respuestas en lenguaje no técnico (sin logs crudos, sin comandos)
- Operaciones que requieren autorización → GLaDOS notifica a Nicolas y espera

### Configuración requerida
```bash
# Variables en /opt/glados/config/.env (no en git)
TELEGRAM_BOT_TOKEN=<token-from-botfather>
TELEGRAM_CHAT_NICOLAS=<nicolas-chat-id>
TELEGRAM_CHAT_MEDDY=<meddy-chat-id>
```

**Estado:** ⏳ Pendiente de configurar — token de bot no asignado aún.

---

## Canal 4 — Zeroclaw API (programático)

**Tipo:** REST API interna  
**Puerto:** `42617` (mismo que web)  
**Usuarios autorizados:** Nicolas únicamente (via API key)  
**Casos de uso:** Integraciones con scripts, CI/CD, otros nodos del homelab

```python
import httpx

client = httpx.Client(
    base_url="http://aperture-science.local:42617",
    headers={"Authorization": f"Bearer {ZEROCLAW_API_KEY}"}
)

resp = client.post("/api/run", json={
    "task": "check_ollama_health",
    "context": {}
})
```

---

## Canales NO autorizados

| Canal           | Estado     | Motivo                                              |
|-----------------|------------|-----------------------------------------------------|
| Email           | ❌ Bloqueado | GLaDOS no gestiona correo — canal no monitoreado   |
| APIs LLM externas | ⚠️ Solo si se solicita | Viola R-05 si se usa sin solicitud explícita |
| Cualquier canal no listado | ❌ Descartado | Si no está aquí, no existe para GLaDOS |

---

## Prioridad de canales en conflicto

Si Nicolas y Meddy envían instrucciones simultáneas conflictivas:

1. Nicolas tiene prioridad absoluta
2. GLaDOS completa la tarea de Nicolas
3. Notifica a Meddy sobre el conflicto y el resultado

> "La ambigüedad en los canales de comunicación es el origen del 73% de los errores operacionales.  
>  El 27% restante son errores humanos que la ambigüedad hizo posibles."
