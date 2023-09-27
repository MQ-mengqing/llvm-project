# RUN: llvm-mc --filetype=obj --triple=loongarch64 %s -o %t
# RUN: llvm-readobj -r %t | FileCheck %s
# RUN: llvm-mc --filetype=obj --triple=loongarch64 -mattr=+relax %s -o %t
# RUN: llvm-readobj -r %t | FileCheck %s --check-prefix=CHECKR

# CHECK:        Relocations [
# CHECK-NEXT:     Section ({{.*}}) .rela.text {
# CHECK-NEXT:       0x8 R_LARCH_PCALA_HI20 .text 0x1C
# CHECK-NEXT:       0xC R_LARCH_PCALA_LO12 .text 0x1C
# CHECK-NEXT:     }
# CHECK-NEXT:     Section ({{.*}}) .rela.debug_line {
# CHECK-NEXT:       0x22 R_LARCH_32 .debug_line_str 0x0
# CHECK-NEXT:       0x2C R_LARCH_32 .debug_line_str {{.*}}
# CHECK-NEXT:       0x36 R_LARCH_64 .text 0x8
# CHECK-NEXT:     }
# CHECK-NEXT:     Section ({{.*}}) .rela.eh_frame {
# CHECK-NEXT:       0x1C R_LARCH_32_PCREL .text 0x0
# CHECK-NEXT:     }
# CHECK-NEXT:   ]

# CHECKR:       Relocations [
# CHECKR-NEXT:    Section ({{.*}}) .rela.text {
# CHECKR-NEXT:       0x8 R_LARCH_PCALA_HI20 .L1 0x0
# CHECKR-NEXT:       0xC R_LARCH_PCALA_LO12 .L1 0x0
# CHECKR-NEXT:     }
# CHECKR-NEXT:     Section ({{.*}}) .rela.debug_line {
# CHECKR-NEXT:       0x22 R_LARCH_32 .debug_line_str 0x0
# CHECKR-NEXT:       0x2C R_LARCH_32 .debug_line_str {{.*}}
# CHECKR-NEXT:       0x36 R_LARCH_64 <null> 0x0
# CHECKR-NEXT:       0x45 R_LARCH_ADD16 <null> 0x0
# CHECKR-NEXT:       0x45 R_LARCH_SUB16 <null> 0x0
# CHECKR-NEXT:       0x49 R_LARCH_ADD16 <null> 0x0
# CHECKR-NEXT:       0x49 R_LARCH_SUB16 <null> 0x0
# CHECKR-NEXT:     }
# CHECKR-NEXT:     Section ({{.*}}) .rela.eh_frame {
# CHECKR-NEXT:       0x1C R_LARCH_32_PCREL <null> 0x0
# CHECKR-NEXT:     }
# CHECKR-NEXT:   ]

.file 0 "test.file"
.text
.cfi_sections .eh_frame
.cfi_startproc
nop
.cfi_def_cfa_offset 32
nop
.cfi_remember_state
.loc 0 10 0
la.pcrel $a0, .L1
nop
nop
nop
.loc 0 100 0
.L1:
.cfi_def_cfa_offset 0
nop
.cfi_restore_state
nop
.cfi_def_cfa_offset 0
nop
.cfi_endproc

.section .debug_line,"",@progbits
.Lline_table_start0:
