# Entorno de desarrollo Odoo 19

Setup para aprendizaje con Odoo 19, que funciona igual en GitHub Codespaces y en Docker local.

---

## Estructura del repositorio

```
.
├── .devcontainer/
│   └── devcontainer.json     ← configuración de GitHub Codespaces
├── addons/                   ← tus módulos custom van aquí
├── oca_addons/               ← módulos de la comunidad OCA van aquí
├── config/
│   └── odoo.conf             ← configuración de Odoo
├── docker-compose.yml        ← define los servicios (Odoo + PostgreSQL)
├── dev.sh                    ← script con comandos útiles
└── README.md
```

---

## Opción A — GitHub Codespaces (universidad / sin instalar nada)

1. Abre el repo en GitHub
2. Haz clic en **Code → Codespaces → Create codespace on main**
3. Espera ~2 minutos a que arranque
4. Ve a la pestaña **PORTS** en VS Code y abre el puerto **8069**
5. Crea tu primera base de datos en la pantalla de bienvenida de Odoo

> Codespaces incluye Docker preinstalado, así que no necesitas instalar nada más.

---

## Opción B — Docker local (tu PC en casa)

### Requisitos
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) instalado

### Pasos

```bash
# Clonar el repo
git clone https://github.com/TU_USUARIO/TU_REPO.git
cd TU_REPO

# Iniciar todo
bash dev.sh up

# Abrir Odoo
# → http://localhost:8069
```

---

## Comandos del día a día

```bash
bash dev.sh up                     # iniciar
bash dev.sh down                   # detener
bash dev.sh logs                   # ver logs en tiempo real
bash dev.sh shell                  # entrar al contenedor
bash dev.sh python-shell mi_db     # shell Python de Odoo
bash dev.sh install mi_modulo      # instalar un módulo
bash dev.sh update  mi_modulo      # actualizar un módulo
bash dev.sh test    mi_modulo      # correr tests del módulo
bash dev.sh psql                   # consola PostgreSQL
```

---

## Cómo crear un módulo custom

```bash
# Crear la estructura básica del módulo
bash dev.sh shell
odoo scaffold mi_modulo /mnt/extra-addons
exit

# Instalar el módulo
bash dev.sh install mi_modulo
```

El módulo aparecerá en `addons/mi_modulo/`.

---

## Módulos OCA

Descarga los módulos OCA en la carpeta `oca_addons/`:

```bash
cd oca_addons
git clone https://github.com/OCA/partner-contact.git --branch 19.0 --depth 1

# Luego instala el módulo que necesites
bash dev.sh install nombre_del_modulo_oca
```

---

## Debugging con pdb / pudb

### Configuración inicial (solo una vez)

```bash
bash dev.sh install-debuggers
```

### Usar pdb (viene preinstalado)

En tu código Python agrega:

```python
import sys
if sys.__stdin__.isatty():
    import pdb; pdb.set_trace()
```

Luego entra al shell del contenedor y ejecuta Odoo manualmente:

```bash
bash dev.sh shell
odoo --workers=0   # workers=0 es obligatorio para que pdb funcione
```

### Usar pudb (más visual)

```python
import sys
if sys.__stdin__.isatty():
    import pudb; pudb.set_trace()
```

> **Importante:** `workers=0` en `odoo.conf` ya está configurado para desarrollo. Esto es necesario para que los debuggers interactivos funcionen correctamente.

---

## Acceso a la base de datos

```bash
bash dev.sh psql
# Luego dentro de psql:
\l           -- listar bases de datos
\c mi_db     -- conectar a una base
\dt          -- listar tablas
```

---

## Credenciales por defecto

| Servicio   | Usuario | Contraseña |
|------------|---------|------------|
| Odoo admin | admin   | admin      |
| PostgreSQL | odoo    | odoo       |

> Cambia estas credenciales si vas a exponer el entorno públicamente.
