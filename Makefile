NAME =                  ols.io
VERSION =               latest
VERSION_ALIASES =       1.0.0
TITLE =                 ols.io
DESCRIPTION =           Base image for ols.io
SOURCE_URL =            https://github.com/olsio/scaleway
VENDOR_URL =
DEFAULT_IMAGE_ARCH =	x86_64


IMAGE_VOLUME_SIZE =     50G
IMAGE_BOOTSCRIPT =      stable
IMAGE_NAME =            ols.io

## Image tools  (https://github.com/scaleway/image-tools)
all:	docker-rules.mk
docker-rules.mk:
	wget -qO - https://j.mp/scw-builder | bash
-include docker-rules.mk
