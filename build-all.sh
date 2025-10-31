############################################################################
#
# (c) 1986-2025 Wolfgang G. Reißnegger <w.reissnegger@gmx.net>
# 
# Project: https://github.com/egnagflow/vmon
# License: https://github.com/egnagflow/vmon/blob/main/LICENSE
#
############################################################################

# BASIC loader builds.
PLATFORM=vic20 TARGET=unexpanded    make clean all
PLATFORM=vic20 TARGET=3k            make clean all
PLATFORM=vic20 TARGET=8k+           make clean all

# Cartridge build.
PLATFORM=vic20 TARGET=crt_a000_pal  make clean crt
PLATFORM=vic20 TARGET=crt_a000_ntsc make clean crt

# C64
PLATFORM=c64   TARGET=crt_8000      make clean crt
PLATFORM=c64   TARGET=bas_c000      make clean all
