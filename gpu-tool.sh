#!/bin/bash
# ============================================================
# GPU Management Tool for Proxmox VE 9 (NVIDIA)
# Autor: ChatGPT (Optimizado para T1000 / RTX / GTX)
# ============================================================

set -e

LXC_DIR="/etc/pve/lxc"
DEFAULT_START=100
DEFAULT_END=110

check_gpu_host() {
  echo "🧠 Verificando estado de GPU en el host..."
  if ! command -v nvidia-smi >/dev/null 2>&1; then
      echo "❌ 'nvidia-smi' no está instalado."
      return 1
  fi

  if ! nvidia-smi >/dev/null 2>&1; then
      echo "⚠️  'nvidia-smi' no responde. El módulo NVIDIA puede no estar cargado."
      echo "👉 Ejecuta: modprobe nvidia  o revisa con: dmesg | grep -i nvidia"
      return 1
  fi

  echo "✅ GPU detectada correctamente:"
  nvidia-smi --query-gpu=name,driver_version,pci.bus_id --format=csv,noheader
  echo ""
  return 0
}

install_driver() {
  echo "⚙️  Instalando y configurando driver NVIDIA..."
  echo "Añadiendo repositorios contrib/non-free..."
  if ! grep -q "non-free" /etc/apt/sources.list; then
      echo "deb http://deb.debian.org/debian bookworm contrib non-free non-free-firmware" >> /etc/apt/sources.list
  fi

  apt update -y
  apt install -y linux-headers-$(uname -r) build-essential dkms
  echo "blacklist nouveau" > /etc/modprobe.d/blacklist-nouveau.conf
  echo "options nouveau modeset=0" >> /etc/modprobe.d/blacklist-nouveau.conf
  update-initramfs -u
  apt install -y nvidia-driver nvidia-smi
  echo "✅ Instalación completada. Reinicia el sistema con: reboot"
}

enable_gpu() {
  check_gpu_host || { echo "❌ GPU no operativa. Aborta."; return 1; }

  echo ""
  read -p "👉 Introduce los IDs de contenedores separados por espacio (o ENTER para rango $DEFAULT_START-$DEFAULT_END): " IDS
  if [ -z "$IDS" ]; then
      IDS=$(seq $DEFAULT_START $DEFAULT_END)
  fi

  for ID in $IDS; do
      CONF="$LXC_DIR/${ID}.conf"
      if [ ! -f "$CONF" ]; then
          echo "❌ Contenedor $ID no existe. Saltando..."
          continue
      fi

      if grep -q "nvidia" "$CONF"; then
          echo "🔹 Contenedor $ID ya tiene GPU configurada. Saltando..."
          continue
      fi

      echo "✅ Añadiendo GPU al contenedor $ID..."
      cat <<EOF >>"$CONF"

# --- GPU NVIDIA ---
lxc.cgroup2.devices.allow: c 195:* rwm
lxc.cgroup2.devices.allow: c 507:* rwm
lxc.mount.entry: /dev/nvidia0 dev/nvidia0 none bind,optional,create=file
lxc.mount.entry: /dev/nvidiactl dev/nvidiactl none bind,optional,create=file
lxc.mount.entry: /dev/nvidia-uvm dev/nvidia-uvm none bind,optional,create=file
lxc.mount.entry: /dev/nvidia-uvm-tools dev/nvidia-uvm-tools none bind,optional,create=file
EOF

      pct restart "$ID" || echo "⚠️  No se pudo reiniciar contenedor $ID."
  done
  echo "🎉 GPU habilitada en los contenedores seleccionados."
}

disable_gpu() {
  echo ""
  read -p "👉 Introduce los IDs de contenedores a deshabilitar (separados por espacio): " IDS
  if [ -z "$IDS" ]; then
      echo "❌ Debes indicar al menos un ID."
      return 1
  fi

  for ID in $IDS; do
      CONF="$LXC_DIR/${ID}.conf"
      if [ ! -f "$CONF" ]; then
          echo "❌ Contenedor $ID no existe. Saltando..."
          continue
      fi

      if ! grep -q "nvidia" "$CONF"; then
          echo "ℹ️  Contenedor $ID no tiene GPU configurada. Saltando..."
          continue
      fi

      echo "🚫 Eliminando GPU de contenedor $ID..."
      sed -i '/nvidia/d' "$CONF"
      pct restart "$ID" || echo "⚠️  No se pudo reiniciar contenedor $ID."
  done
  echo "✅ GPU deshabilitada en los contenedores seleccionados."
}

status_gpu() {
  echo ""
  check_gpu_host
  echo "💾 Estado de contenedores LXC:"
  echo "---------------------------------------------"
  HEADER="| ID | Nombre | Estado | GPU |"
  SEPARATOR="|----|--------|--------|-----|"
  printf "%s\n%s\n" "$HEADER" "$SEPARATOR"

  for CONF in "$LXC_DIR"/*.conf; do
      [ -e "$CONF" ] || continue
      ID=$(basename "$CONF" .conf)
      NAME=$(pct config "$ID" | grep -m1 '^hostname' | awk '{print $2}')
      STATE=$(pct status "$ID" | awk '{print $2}')
      if grep -q "nvidia" "$CONF"; then
          GPU="✅"
      else
          GPU="❌"
      fi
      printf "| %-3s | %-10s | %-7s | %-3s |\n" "$ID" "${NAME:---}" "${STATE:---}" "$GPU"
  done
  echo "---------------------------------------------"
  echo "✅ = GPU habilitada | ❌ = sin GPU configurada"
}

# --- Menú principal ---
while true; do
  clear
  echo "==============================================="
  echo "🧩 GPU Management Tool for Proxmox VE 9"
  echo "==============================================="
  echo "1️⃣  Instalar driver NVIDIA en host"
  echo "2️⃣  Habilitar GPU en contenedor(es)"
  echo "3️⃣  Deshabilitar GPU en contenedor(es)"
  echo "4️⃣  Ver estado general (GPU + LXC)"
  echo "5️⃣  Salir"
  echo "==============================================="
  read -p "Selecciona una opción [1-5]: " OPC

  case "$OPC" in
    1) install_driver ;;
    2) enable_gpu ;;
    3) disable_gpu ;;
    4) status_gpu ;;
    5) echo "👋 Saliendo..."; exit 0 ;;
    *) echo "❌ Opción no válida."; sleep 1 ;;
  esac

  echo ""
  read -p "Pulsa ENTER para volver al menú..."
done
