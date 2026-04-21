#!/usr/bin/env bash
# =============================================================
# Script 1 — Entorno Python y dependencias de Odoo 19
# Uso: bash 1_sistema.sh
# =============================================================
set -euo pipefail

# ── Configuración ──────────────────────────────────────────────
WORKDIR="$HOME/ProyectoOdoo"
ODOO_ZIP="odoo-19.0.zip"
ODOO_DIR="odoo-19.0"
ODOO_URL="https://github.com/odoo/odoo/archive/refs/heads/19.0.zip"
# Cambia la URL si ya tienes el zip descargado localmente

# ── 1. Instalar dependencias del sistema ───────────────────────
echo "[1/6] Instalando postgresql y python3-venv..."
sudo apt update -qq
sudo apt install -y postgresql python3-venv python3-dev \
    build-essential libxml2-dev libxslt1-dev \
    libsasl2-dev libldap2-dev libssl-dev

# ── 2. Crear directorio de trabajo ────────────────────────────
echo "[2/6] Creando directorio de trabajo: $WORKDIR"
mkdir -p "$WORKDIR"
cd "$WORKDIR"

# ── 3. Descargar y descomprimir Odoo ──────────────────────────
echo "[3/6] Descargando Odoo 19..."
if [ ! -f "$ODOO_ZIP" ]; then
    wget -q --show-progress "$ODOO_URL" -O "$ODOO_ZIP"
else
    echo "  -> $ODOO_ZIP ya existe, omitiendo descarga."
fi

echo "  -> Descomprimiendo..."
unzip -q -o "$ODOO_ZIP"

# ── 4. Crear entorno virtual ──────────────────────────────────
echo "[4/6] Creando entorno virtual Python..."
python3 -m venv .venv

# ── 5. Parchear requirements.txt ──────────────────────────────
echo "[5/6] Comentando psycopg2 y python-ldap en requirements.txt..."
REQS="$ODOO_DIR/requirements.txt"
# Comenta las líneas que empiecen con psycopg2 o python-ldap
sed -i 's/^\(psycopg2\)/#\1/' "$REQS"
sed -i 's/^\(python-ldap\)/#\1/' "$REQS"

# ── 6. Instalar dependencias Python ──────────────────────────
echo "[6/6] Instalando requirements y paquetes adicionales..."
source .venv/bin/activate

pip install --upgrade pip -q
pip install -r "$REQS" -q
pip install psycopg2-binary python3-ldap -q

echo ""
echo "✔  Script 1 completado. Continúa con: bash 2_base_de_datos.sh"
