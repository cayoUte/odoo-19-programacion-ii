#!/usr/bin/env bash
# =============================================================
# Script 3 — Configurar odoo.conf y lanzar Odoo 19
# Uso: bash 3_ejecutar.sh
# =============================================================
set -euo pipefail

# ── Configuración ──────────────────────────────────────────────
WORKDIR="$HOME/ProyectoOdoo"
ODOO_DIR="odoo-19.0"
DB_USER="miusuario"
DB_PASS="micontrasena"          # Debe coincidir con el script 2
ADMIN_PASS="claveAdmin"         # Contraseña del panel de administración
DB_HOST="localhost"
DB_PORT="5432"

# ── 1. Copiar odoo.conf ──────────────────────────────────────
echo "[1/3] Copiando odoo.conf al directorio de trabajo..."
cd "$WORKDIR"
cp "$ODOO_DIR/debian/odoo.conf" odoo.conf

# ── 2. Parametrizar odoo.conf ────────────────────────────────
echo "[2/3] Configurando parámetros en odoo.conf..."

set_param() {
    local key="$1"
    local value="$2"
    if grep -q "^;\?$key" odoo.conf; then
        sed -i "s|^;\?${key}.*|${key} = ${value}|" odoo.conf
    else
        echo "${key} = ${value}" >> odoo.conf
    fi
}

set_param "admin_passwd"  "$ADMIN_PASS"
set_param "db_host"       "$DB_HOST"
set_param "db_port"       "$DB_PORT"
set_param "db_user"       "$DB_USER"
set_param "db_password"   "$DB_PASS"

echo "  -> odoo.conf actualizado:"
grep -E "^(admin_passwd|db_host|db_port|db_user|db_password)" odoo.conf

# ── 3. Activar entorno y lanzar Odoo ─────────────────────────
echo "[3/3] Iniciando Odoo 19..."
echo "  Accede en tu navegador a: http://localhost:8069"
echo "  Presiona Ctrl+C para detener el servidor."
echo ""

source .venv/bin/activate
python "$ODOO_DIR/odoo-bin" -c odoo.conf
