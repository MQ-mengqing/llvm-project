# RUN: llvm-mc --filetype=obj --triple=loongarch64 %s -o %t
# RUN: llvm-readobj -r %t | FileCheck %s
# RUN: llvm-mc --filetype=obj --triple=loongarch64 -mattr=+relax %s -o %t
# RUN: llvm-readobj -r %t | FileCheck %s --check-prefix=CHECKR

# CHECKR:       Relocations [
# CHECKR-NEXT:    Section ({{.*}}) .rela.text {
# CHECKR-NEXT:      0x0 R_LARCH_ALIGN - 0xC
# CHECKR-NEXT:      0x10 R_LARCH_ALIGN - 0x1C
# CHECKR-NEXT:      0x2C R_LARCH_ALIGN - 0xC
# CHECKR-NEXT:    }

# CHECK:       Relocations [
# CHECK-NEXT:  ]

.text
.p2align 4
nop
.p2align 5
.p2align 4
nop
## Not emit R_LARCH_ALIGN if code alignment great than alignment directive.
.p2align 2
.p2align 1
.p2align 0
## Not emit R_LARCH_ALIGN if alignment directive with specific padding value.
.p2align 4, 1
