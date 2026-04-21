#!/usr/bin/env bash
# =============================================================
# Script 2 — Configuración de PostgreSQL para Odoo 19
# Uso: bash 2_base_de_datos.sh
# =============================================================
set -euo pipefail

# ── Configuración ──────────────────────────────────────────────
DB_USER="miusuario"
DB_PASS="micontrasena"          # Cámbiala antes de ejecutar
PG_VERSION="14"                 # Ajusta si tu PostgreSQL es distinto
PG_CONF="/etc/postgresql/$PG_VERSION/main/postgresql.conf"
PG_HBA="/etc/postgresql/$PG_VERSION/main/pg_hba.conf"

# ── 1. Crear usuario en PostgreSQL ───────────────────────────
echo "[1/5] Creando usuario de base de datos: $DB_USER"
sudo -u postgres psql -tc \
    "SELECT 1 FROM pg_roles WHERE rolname='$DB_USER'" \
    | grep -q 1 && echo "  -> Usuario ya existe." || \
    sudo -u postgres psql -c "CREATE USER $DB_USER;"

# ── 2. Asignar roles ─────────────────────────────────────────
echo "[2/5] Asignando roles superuser y createdb..."
sudo -u postgres psql -c \
    "ALTER ROLE $DB_USER WITH SUPERUSER CREATEDB;"

# ── 3. Asignar contraseña ────────────────────────────────────
echo "[3/5] Asignando contraseña cifrada..."
sudo -u postgres psql -c \
    "ALTER ROLE $DB_USER WITH ENCRYPTED PASSWORD '$DB_PASS';"

# ── 4. Configurar postgresql.conf (listen_addresses) ─────────
echo "[4/5] Configurando listen_addresses en postgresql.conf..."
if grep -q "^listen_addresses" "$PG_CONF"; then
    sudo sed -i "s/^listen_addresses.*/listen_addresses = '*'/" "$PG_CONF"
else
    echo "listen_addresses = '*'" | sudo tee -a "$PG_CONF" > /dev/null
fi

# ── 5. Configurar pg_hba.conf ────────────────────────────────
echo "[5/5] Añadiendo entrada en pg_hba.conf para $DB_USER..."
HBA_LINE="local   all   $DB_USER   md5"

if ! sudo grep -q "$DB_USER" "$PG_HBA"; then
    # Insertar antes de la primera línea "local all" existente
    sudo sed -i "/^local\s\+all\s\+all/i $HBA_LINE" "$PG_HBA"
else
    echo "  -> Entrada ya existe en pg_hba.conf."
fi

# ── Reiniciar servicio ────────────────────────────────────────
echo "Reiniciando PostgreSQL..."
sudo systemctl restart postgresql

echo ""
echo "✔  Script 2 completado. Continúa con: bash 3_ejecutar.sh"
