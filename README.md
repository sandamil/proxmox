bash -c "$(curl -fsSL https://raw.githubusercontent.com/sandamil/proxmox/main/gpu-tool.sh)"

info:
===============================================
🧩 GPU Management Tool for Proxmox VE 9
===============================================
1️⃣  Instalar driver NVIDIA en host
2️⃣  Habilitar GPU en contenedor(es)
3️⃣  Deshabilitar GPU en contenedor(es)
4️⃣  Ver estado general (GPU + LXC)
5️⃣  Salir
===============================================
Selecciona una opción [1-5]:

2️⃣ Habilitar GPU en contenedor(es)
	1.	Seleccionas 2.
	2.	El script lista todos los contenedores LXC de tu host, ejemplo:

ID    Hostname       Estado
100   debian-lxc     detenido
101   ubuntu-lxc     corriendo
102   test-lxc       corriendo

Te pedirá seleccionar uno o varios contenedores.
	•	Puedes escribir un solo ID, por ejemplo: 101
	•	O varios separados por espacios: 101 102
	4.	El script hará automáticamente:
	•	Modificación de /etc/pve/lxc/<ID>.conf para agregar la GPU.
	•	Reinicio del contenedor (si está corriendo).
	5.	Al terminar, te mostrará un mensaje de confirmación: