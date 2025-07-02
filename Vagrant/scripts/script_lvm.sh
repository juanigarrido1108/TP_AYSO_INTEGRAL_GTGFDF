#!/bin/bash

# Configuración LVM - 4 discos con particiones
# vg_datos: lv_docker (10M) + lv_workareas (2.5GB) 
# vg_temp: lv_swap (2.5G)
# Partición swap adicional: /dev/sdf1

echo "=== VERIFICANDO DISCOS DISPONIBLES ==="
lsblk

echo "=== CREANDO PARTICIONES PARA LVM ==="
# Partición en /dev/sde (tipo 8e = Linux LVM)
fdisk /dev/sde << EOF
n
p
1


t
8e
w
EOF

# Partición en /dev/sdc (tipo 8e = Linux LVM)
fdisk /dev/sdc << EOF
n
p
1


t
8e
w
EOF

# Partición en /dev/sdd (tipo 8e = Linux LVM)
fdisk /dev/sdd << EOF
n
p
1


t
8e
w
EOF

echo "=== CREANDO PHYSICAL VOLUMES ==="
pvcreate /dev/sdb1
pvcreate /dev/sdc1
pvcreate /dev/sdd1

echo "=== MOSTRANDO PHYSICAL VOLUMES ==="
pvdisplay

echo "=== CREANDO VOLUME GROUPS ==="
vgcreate vg_datos /dev/sdb1 /dev/sdc1
vgcreate vg_temp /dev/sdd1

echo "=== CREANDO LOGICAL VOLUMES ==="
lvcreate -L 10M -n lv_docker vg_datos
lvcreate -L 2.5G -n lv_workareas vg_datos
lvcreate -L 2.5G -n lv_swap vg_temp

echo "=== FORMATEANDO SISTEMAS DE ARCHIVOS ==="
mkfs.ext4 /dev/vg_datos/lv_docker
mkfs.ext4 /dev/vg_datos/lv_workareas
mkswap /dev/vg_temp/lv_swap
mkswap /dev/sdf1

echo "=== CREANDO PUNTOS DE MONTAJE ==="
mkdir -p /var/lib/docker /work

echo "=== MONTANDO VOLÚMENES ==="
mount /dev/vg_datos/lv_docker /var/lib/docker
mount /dev/vg_datos/lv_workareas /work
swapon /dev/vg_temp/lv_swap
swapon /dev/sdf1

echo "=== CONFIGURACIÓN COMPLETADA ==="
echo "Verificación final:"
lsblk
df -h
swapon -s

