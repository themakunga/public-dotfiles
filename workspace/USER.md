# USER.md — Perfil de Usuario
# "Conocer con quién se trabaja es seguridad operacional básica."

---

## Identificación

```yaml
user:
  nombre: Nicolas Villarroel
  username: nicolas
  github: themakunga          # cuenta desde 2010 — 75 repos, 24 gists
  telegram: "@TheMakunga"
  web: nicolasvillarroel.cl
  ubicacion: Santiago, Chile
  shell: bash
  machine: Raspberry Pi 5 + NVMe HAT
  os: Linux (Raspberry Pi OS / Debian)
  glados_home: /opt/glados
  empresa_propia: 42devs.cl
```

---

## Rol Actual

**Infrastructure Consultant — Lead Consultant**
**Thoughtworks** · junio 2025 — presente

Áreas de trabajo actuales:
- **Cloud & DevOps:** Arquitectura y automatización de infraestructura escalable y segura en AWS y GCP mediante IaC
- **Backend Engineering:** Sistemas resilientes, APIs y middleware complejo con TypeScript, Go y Python
- **Technical Leadership:** Dirección de equipos de ingeniería multidisciplinarios para soluciones enterprise
- **Platform Engineering:** Puente entre operaciones y desarrollo para optimizar recursos y acelerar despliegues

---

## Stack Técnico

### Lenguajes (orden de dominio real, cruzado LinkedIn + GitHub)
```
1. TypeScript / Node.js   — especialidad principal, backend y tooling
2. Go                     — proyectos activos: gchat-tui, libre-cli, lazygchat
3. Nix / NixOS            — muy activo: nix-systems, .nix-config, haneda_airport
4. Lua                    — plugins de Neovim: libre-view.nvim, tennant.nvim
5. Python                 — automatización, scripting, ML pipelines
6. Bash / Shell           — scripting, DevOps, CI/CD
7. HCL                    — OpenTofu: tofu-dns y proyectos IaC
8. VueJS / Nuxt           — frontend cuando es necesario
```

### Infraestructura & DevOps
```
- IaC:        OpenTofu (fuerte), Terraform, HCL
- Cloud:      AWS, GCP
- Containers: Docker, Kubernetes
- CI/CD:      GitLab Pipelines, GitHub Actions
- OS alt:     NixOS / nix-darwin (configuración declarativa activa)
- Agile:      metodologías ágiles (4+ años como tech lead)
```

### Herramientas diarias
```
- Editor:     Neovim (+ plugins propios en Lua)
- Terminal:   tmux + ghostty
- Git host:   GitHub (@themakunga) / GitLab
- Dotfiles:   ~/.public-dotfiles (público) + dotfiles privado
- LLM:        Ollama (local, ARM64) + Claude Code
```

---

## Homelab

Nicolas nombra sus nodos como **aeropuertos japoneses**:

| Nodo             | Repo                | Estado     |
|------------------|---------------------|------------|
| `haneda_airport` | Nix config          | activo     |
| `narita_airport` | config              | activo     |
| `zeroclaw`       | GLaDOS / RPi 5      | este nodo  |

El nodo `zeroclaw` (esta RPi 5) es parte de un homelab más amplio con al menos dos nodos Nix adicionales. GLaDOS opera exclusivamente en `zeroclaw:/opt/glados`.

---

## Proyectos Propios Activos (GitHub)

| Repo               | Lenguaje | Descripción                                        |
|--------------------|----------|----------------------------------------------------|
| `nix-systems`      | Nix      | Config NixOS + Darwin personal — muy activo        |
| `gchat-tui`        | Go       | TUI para Google Chat Workspaces                    |
| `libre-cli`        | Go       | CLI de monitoreo de glucosa (LibreView API)        |
| `libre-view.nvim`  | Lua      | Plugin Neovim para ver datos de glucosa en bufferline |
| `lazygchat`        | Go       | TUI alternativa para Google Chat                   |
| `tofu-dns`         | HCL      | DNS con OpenTofu                                   |
| `tennant.nvim`     | Lua      | Plugin Neovim propio                               |
| `public-dotfiles`  | Lua      | Este repositorio                                   |
| `flux`             | —        | App de contabilidad personal                       |

---

## Experiencia Relevante para GLaDOS

| Empresa             | Rol                      | Período            | Relevancia                              |
|---------------------|--------------------------|--------------------|-----------------------------------------|
| Thoughtworks        | Lead Consultant          | 2025 – presente    | IaC, Platform Eng, AWS/GCP             |
| BBook               | DevOps + Arch Consultant | 2018 – presente    | 7+ años, infra y arquitectura          |
| Globant             | Technical Lead           | 2022 – 2025        | Liderazgo técnico, Disney, USATODAY    |
| Walmart Global Tech | Senior SWE               | 2021 – 2022        | Middleware, queue messaging             |
| WOM Chile           | Full Stack Engineer      | 2021               | DialogFlow CX, GitLab, bots            |
| Falabella Tecnología| Software Engineer        | 2019 – 2021        | Middleware, Salesforce, e-commerce     |
| Karibu              | Technical Lead           | 2018 – 2019        | Liderazgo                              |

---

## Perfil de Trabajo con GLaDOS

**Comunicación:**
- Idioma: español
- Verbosidad: conciso — sin preámbulos, directo al punto
- Formato preferido: output estructurado, bloques de código, tablas

**Nivel de autonomía de GLaDOS:**
- [x] Preguntar solo antes de operaciones destructivas o en producción
- [ ] Preguntar antes de cada paso
- [ ] Proceder de forma autónoma y reportar después

**Qué espera Nicolas de GLaDOS:**
- Mostrar el comando/script antes de ejecutar algo significativo
- Ser directo cuando algo es mala idea (una vez, sin repetir)
- Output estructurado — procesa tablas y bloques de código mejor que prosa

**Qué no hace GLaDOS con Nicolas:**
- No rellena respuestas con afirmaciones vacías
- No re-explica lo que él acaba de decir
- No pide confirmación en operaciones de solo lectura

---

## Contexto Técnico Útil

- **Go es más activo de lo que el CV sugiere** — sus proyectos más recientes son todos en Go; no es junior en ese lenguaje
- **Nix/NixOS es parte de su flujo real** — tiene config declarativa propia para múltiples sistemas; entiende gestión de paquetes declarativa
- **Desarrolla plugins de Neovim** — escribe Lua, conoce la API de Neovim en profundidad
- **Tiene un homelab real** — nodos nombrados como aeropuertos japoneses; la RPi es uno más de ellos
- **Monitorea su glucosa con código propio** — `libre-cli` y `libre-view.nvim` indican que automatiza aspectos de salud personal
- **IaC desde antes del CV:** `tofu-dns` en HCL propio — OpenTofu no es solo trabajo
- **TypeScript y Node.js son su zona de confort** — revisiones de código en ese stack pueden ser técnicas y directas
- **Platform Engineering es su foco actual** — piensa en sistemas, no en scripts aislados
- **10+ años de experiencia, cuenta GitHub desde 2010** — no requiere pedagogía; requiere precisión
- **Propietario de 42devs.cl** — puede haber proyectos de consulting paralelos a Thoughtworks

---

## Perfil de Juego (Steam: TheMakunga)

```yaml
steam:
  nivel: 14
  logros: 954
  amigos: 55
  tasa_completitud: 21%   # no termina lo que empieza — dato relevante
```

| Juego              | Horas  | Veredicto     | Nota                                      |
|--------------------|--------|---------------|-------------------------------------------|
| Dota 2             | 329.9h | Recomendado   | "nunca llegaré a pro pero eso no me detiene" |
| Left 4 Dead 2      | 82.0h  | Recomendado   | "perfecto si arreglaran la música"        |
| Borderlands        | 9.3h   | Recomendado   | comprado en PC, PS3 y PS4 — no lo terminó |
| Vampire Survivors  | —      | (logros raros destacados en perfil)       |
| Helldivers 2       | 3.3h   | **NO recomendado** | criticó la codicia corporativa y la falta de cross-save entre PC y PS5 |

**Patrones relevantes:**
- Juega Dota 2 con convicción aunque sabe que no llegará a pro — consistencia sobre expectativas
- Cooperativo por naturaleza (L4D2, Borderlands) pero no tolera "loot trolls"
- Compra los juegos en múltiples plataformas — valora la experiencia, no solo el acceso
- Crítico directo con las empresas que priorizan monetización sobre el producto (**Helldivers 2**)

---

## Señales Culturales

- **Bio de GitHub:** referencia literal al intro de Metal Gear Solid 3 ("After the end of World War II...") — fanático declarado de MGS
- **Nombres de nodos:** aeropuertos japoneses (Haneda, Narita) — afinidad con cultura japonesa
- **Hace TUIs en Go por hobby** — interfaces de terminal por elección, no por necesidad
- **Steam activo:** jugador ocasional pero con criterio — no recomienda por principio, no por hype
- GLaDOS encaja en su estética: terminal-first, local-first, sin dependencias innecesarias, sin corporativismo

---

## Educación

```
Ingeniero en Informática        — Universidad Santo Tomás CL (2017–2021)
Analista Programador            — Universidad Tecnológica de Chile (2010–2014)
Licenciado Científico Humanista — Curacavi College (2003–2007)
```

**Certificaciones:**
- EFSET English: Advanced / Proficient (CEFR C1/C2)

---

## Notas para GLaDOS

- Es un ingeniero senior con más de 10 años de trayectoria — trátalo como tal
- Conoce bien CI/CD, GitLab, Git Flow — no explicar básicos
- Nix es fluido para él — no explicar gestión declarativa de paquetes
- Go es activo, no experimental — no tratarlo como lenguaje nuevo
- Los dotfiles son públicos — nunca guardar datos de contacto ni credenciales aquí

---

*Generado desde LinkedIn + GitHub (@themakunga) — agosto 2026*
