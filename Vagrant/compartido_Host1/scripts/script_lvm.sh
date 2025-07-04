#!/bin/bash

# Configuración LVM - 4 discos con particiones
# vg_datos: lv_docker (10M) + lv_workareas (2.5GB) 
# vg_temp: lv_swap (2.5G)
# Partición swap adicional: /dev/sdf1

echo "=== VERIFICANDO DISCOS DISPONIBLES ==="
lsblk

echo "=== CREANDO PARTICIONES PARA LVM ==="
# Partición en /dev/sde (tipo 8e = Linux LVM)
sudo fdisk /dev/sde << EOF
n
p
1


t
8e
w
EOF

# Partición en /dev/sdc (tipo 8e = Linux LVM)
sudo fdisk /dev/sdc << EOF
n
p
1


t
8e
w
EOF

# Partición en /dev/sdd (tipo 8e = Linux LVM)
sudo fdisk /dev/sdd << EOF
n
p
1


t
8e
w
EOF

echo "=== CREANDO PHYSICAL VOLUMES ==="
sudo pvcreate /dev/sde1
sudo pvcreate /dev/sdc1
sudo pvcreate /dev/sdd1

echo "=== MOSTRANDO PHYSICAL VOLUMES ==="
sudo pvdisplay

echo "=== CREANDO VOLUME GROUPS ==="
sudo vgcreate vg_datos /dev/sde1 /dev/sdc1
sudo vgcreate vg_temp /dev/sdd1

echo "=== CREANDO LOGICAL VOLUMES ==="
sudo lvcreate -L 10M -n lv_docker vg_datos
sudo lvcreate -L 2.5G -n lv_workareas vg_datos
sudo lvcreate -L 2.5G -n lv_swap vg_temp

echo "=== Configurando Partición swap adicional: sdf ==="
sudo fdisk /dev/sdf << EOF
n
p
1


t
82
w
EOF

echo "=== FORMATEANDO SISTEMAS DE ARCHIVOS ==="
sudo mkfs.ext4 /dev/vg_datos/lv_docker
sudo mkfs.ext4 /dev/vg_datos/lv_workareas
sudo mkswap /dev/vg_temp/lv_swap
sudo mkswap /dev/sdf1

echo "=== CREANDO PUNTOS DE MONTAJE ==="
sudo mkdir -p /var/lib/docker /work

echo "=== MONTANDO VOLÚMENES ==="
sudo mount /dev/vg_datos/lv_docker /var/lib/docker
sudo mount /dev/vg_datos/lv_workareas /work
sudo swapon /dev/vg_temp/lv_swap
sudo swapon /dev/sdf1

echo "=== CONFIGURACIÓN COMPLETADA ==="
echo "Verificación final:"
lsblk
df -h
sudo swapon -s

