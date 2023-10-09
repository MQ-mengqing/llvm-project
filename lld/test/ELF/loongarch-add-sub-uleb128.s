# REQUIRES: loongarch

# RUN: llvm-mc --filetype=obj --triple=loongarch64 --mattr=+relax %s -o %t.64.o

# RUN: ld.lld --section-start=.text=0x12000 --section-start=.rodata=0x14000 --no-relax %t.64.o -o %t.64.norelax
# RUN: llvm-readelf -x .rodata %t.64.norelax | FileCheck %s
# CHECK:      section '.rodata':
# CHECK-NEXT: 0x00014000 908000

# RUN: ld.lld --section-start=.text=0x12000 --section-start=.rodata=0x14000 %t.64.o -o %t.64
# RUN: llvm-readelf -x .rodata %t.64 | FileCheck --check-prefix=CHECKR %s
# CHECKR:      section '.rodata':
# CHECKR-NEXT: 0x00014000 8c8000

# RUN: llvm-mc --filetype=obj --triple=loongarch32 %s --defsym=of=1 -o %t.32.overflow.o
# RUN: not ld.lld %t.32.overflow.o 2>&1 | FileCheck --check-prefix=CHECK32 %s
# CHECK32: error: uleb128 too big when link object files

# RUN: llvm-mc --filetype=obj --triple=loongarch64 %s --defsym=of=1 --defsym=of64=1 -o %t.64.overflow.o
# RUN: not ld.lld %t.64.overflow.o 2>&1 | FileCheck --check-prefix=CHECK64 %s
# CHECK64: error: uleb128 too big when link object files

.text
.global _start
_start:
1:
  nop
  la.pcrel $t0, _start
  nop
2:

.rodata
foo:

## For overflow checks.
.ifdef of
.byte 0x80
.byte 0x80
.byte 0x80
.ifdef of64
.byte 0x80
.byte 0x80
.byte 0x80
.byte 0x80
.byte 0x80
.endif
.endif

.byte 0x80
.byte 0x80
.byte 0x00
.reloc foo, R_LARCH_ADD_ULEB128, 2b
.reloc foo, R_LARCH_SUB_ULEB128, 1b
