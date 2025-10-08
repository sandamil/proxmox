# Proxmox GPU Tool

Script para habilitar y deshabilitar GPU NVIDIA en contenedores LXC en Proxmox VE.

---

## Requisitos

- Proxmox VE 9
- GPU NVIDIA (ej. T1000)
- Drivers NVIDIA instalados en el host
- Contenedores LXC basados en Debian o Ubuntu

---

## Funcionalidades

- Instalar driver NVIDIA en el host
- Habilitar GPU en contenedor(es) LXC
- Deshabilitar GPU en contenedor(es) LXC
- Ver estado general de GPU y contenedores

---

## Uso

### Ejecutar desde host Proxmox

Si ya subiste el script al host:

```bash
chmod +x gpu-tool.sh
./gpu-tool.sh
```

O directamente desde GitHub:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/sandamil/proxmox/main/gpu-tool.sh)"
```

---

### Menú del script

```
=============================
   GPU Tool - Proxmox LXC
=============================
1️⃣  Instalar driver NVIDIA en host
2️⃣  Habilitar GPU en contenedor(es)
3️⃣  Deshabilitar GPU en contenedor(es)
4️⃣  Ver estado general (GPU + LXC)
5️⃣  Salir
=============================
```

- Selecciona la opción escribiendo el número y pulsando Enter.
- Para habilitar/deshabilitar GPU, se listarán los contenedores disponibles y podrás elegir por ID.

---

## Ejemplo de contenedores

| ID  | Hostname      | Estado     |
|-----|---------------|------------|
| 100 | debian-lxc    | detenido   |
| 101 | ubuntu-lxc    | corriendo  |
| 102 | test-lxc      | corriendo  |

---

## Notas

- Solo habilita GPU en contenedores que realmente la necesiten.
- Asegúrate de que `nvidia-smi` funcione en el host antes de habilitar GPU en contenedores.
- Algunos cambios pueden requerir reiniciar contenedores o el host.

---

## Créditos

Desarrollado por [sandamil](https://github.com/sandamil) basado en scripts comunitarios de Proxmox.