#!/usr/bin/env bash
# =============================================================
#  Comandos rápidos para tu entorno Odoo 19
#  Uso: bash dev.sh [comando]
# =============================================================

CMD=${1:-help}

case "$CMD" in

  # ── Iniciar / detener ──────────────────────────────────────
  up)
    echo "▶  Iniciando Odoo + PostgreSQL..."
    docker compose up -d
    echo "✓  Odoo disponible en http://localhost:8069"
    ;;

  down)
    echo "■  Deteniendo contenedores..."
    docker compose down
    ;;

  restart)
    docker compose restart odoo
    ;;

  # ── Logs ──────────────────────────────────────────────────
  logs)
    docker compose logs -f odoo
    ;;

  # ── Shell interactivo dentro del contenedor ───────────────
  shell)
    echo "Entrando al shell de Odoo (Ctrl+D para salir)..."
    docker compose exec odoo bash
    ;;

  # ── Shell de Python de Odoo (equivalente a odoo-bin shell) ─
  python-shell)
    DB=${2:-odoo}
    echo "Abriendo shell Python de Odoo con base de datos: $DB"
    docker compose exec odoo odoo shell -d "$DB"
    ;;

  # ── Instalar módulo ───────────────────────────────────────
  install)
    MODULE=${2:?  Uso: bash dev.sh install nombre_modulo}
    DB=${3:-odoo}
    echo "Instalando módulo '$MODULE' en base '$DB'..."
    docker compose exec odoo odoo -i "$MODULE" -d "$DB" --stop-after-init
    ;;

  # ── Actualizar módulo ─────────────────────────────────────
  update)
    MODULE=${2:?  Uso: bash dev.sh update nombre_modulo}
    DB=${3:-odoo}
    echo "Actualizando módulo '$MODULE' en base '$DB'..."
    docker compose exec odoo odoo -u "$MODULE" -d "$DB" --stop-after-init
    ;;

  # ── Tests ─────────────────────────────────────────────────
  test)
    MODULE=${2:?  Uso: bash dev.sh test nombre_modulo}
    DB=${3:-odoo_test}
    echo "Ejecutando tests de '$MODULE'..."
    docker compose exec odoo odoo \
      -i "$MODULE" \
      -d "$DB" \
      --test-enable \
      --log-level=test \
      --stop-after-init
    ;;

  # ── Base de datos ─────────────────────────────────────────
  psql)
    docker compose exec db psql -U odoo
    ;;

  # ── Debugger (pdb) ────────────────────────────────────────
  debug)
    echo "Reiniciando Odoo SIN el flag --dev (para que pdb funcione)..."
    docker compose exec odoo bash -c "
      pkill -f odoo-bin 2>/dev/null; sleep 1
      workers=0 odoo --workers=0
    "
    ;;

  # ── Instalar pudb/ipdb ────────────────────────────────────
  install-debuggers)
    docker compose exec odoo pip install pudb ipdb --user
    echo "✓  pudb e ipdb instalados. Úsalos con: import pudb; pudb.set_trace()"
    ;;

  # ── Ayuda ─────────────────────────────────────────────────
  help|*)
    echo ""
    echo "  Comandos disponibles:"
    echo "  ─────────────────────────────────────────────────"
    echo "  bash dev.sh up                    Iniciar todo"
    echo "  bash dev.sh down                  Detener todo"
    echo "  bash dev.sh restart               Reiniciar Odoo"
    echo "  bash dev.sh logs                  Ver logs en vivo"
    echo "  bash dev.sh shell                 Shell bash del contenedor"
    echo "  bash dev.sh python-shell [db]     Shell Python de Odoo"
    echo "  bash dev.sh install  módulo [db]  Instalar un módulo"
    echo "  bash dev.sh update   módulo [db]  Actualizar un módulo"
    echo "  bash dev.sh test     módulo [db]  Correr tests"
    echo "  bash dev.sh psql                  Consola PostgreSQL"
    echo "  bash dev.sh install-debuggers     Instalar pudb e ipdb"
    echo ""
    ;;
esac
