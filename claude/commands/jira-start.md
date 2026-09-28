# jira-start

Inicia el desarrollo de un ticket Jira: crea la branch, asigna el ticket y actualiza todo.txt.

## Uso

```
/jira-start PROJ-123
```

## Instrucciones

1. Toma el número de ticket de `$ARGUMENTS`. Si no se proporcionó, pide uno al usuario.
2. Ejecuta el script con Bash:
   ```bash
   ~/scripts/jira-start "$ARGUMENTS"
   ```
3. Muestra el output completo al usuario.
4. Si el script falla por prereqs faltantes, muestra el README de instalación:
   `cat ~/.claude/commands/jira-start/README.md`

No hagas nada más — el script maneja todo el flujo.
