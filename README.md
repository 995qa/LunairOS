# LunairOS
LunairOS é uma distribuição Linux independente focada em trazer o esqueumorfismo de forma moderna, enquanto mantém estabilidade e incorpora parte da filosofia BSD.

Atual lançamento:

**LunairOS 0.1.1 "Turmoil"**

## Status
Inicializa um kernel Linux customizado com uma initramfs baseada em BusyBox.

## Dependências
Para construir a ISO, instale:
- GRUB
- xorriso
- mtools
- cpio
- gzip
- BusyBox estático

Para compilar o kernel, instale também:
- gcc/clang
- make
- bc
- bison
- flex
- openssl
- elfutils

## Construir a initramfs
```sh
./scripts/build-initramfs.sh
```
## Construir a ISO
```sh
KERNEL=/caminho/para/bzImage ./scripts/build-iso.sh
```

## Licença
LunairOS é licenciado sob a GNU General Public License v3.0 (GPLv3).

## Software de terceiros
LunairOS utiliza:
- Kernel Linux (GPLv2)
- BusyBox (GPLv2)
