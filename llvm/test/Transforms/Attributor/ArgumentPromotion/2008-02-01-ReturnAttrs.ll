; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --function-signature --check-attributes --check-globals
; RUN: opt -aa-pipeline=basic-aa -passes=attributor -attributor-manifest-internal  -attributor-max-iterations-verify -attributor-annotate-decl-cs -attributor-max-iterations=4 -S < %s | FileCheck %s --check-prefixes=CHECK,TUNIT
; RUN: opt -aa-pipeline=basic-aa -passes=attributor-cgscc -attributor-manifest-internal  -attributor-annotate-decl-cs -S < %s | FileCheck %s --check-prefixes=CHECK,CGSCC

define internal i32 @deref(i32* %x) nounwind {
; CGSCC: Function Attrs: argmemonly nofree norecurse nosync nounwind readonly willreturn
; CGSCC-LABEL: define {{[^@]+}}@deref
; CGSCC-SAME: (i32 [[TMP0:%.*]]) #[[ATTR0:[0-9]+]] {
; CGSCC-NEXT:  entry:
; CGSCC-NEXT:    [[X_PRIV:%.*]] = alloca i32, align 4
; CGSCC-NEXT:    store i32 [[TMP0]], i32* [[X_PRIV]], align 4
; CGSCC-NEXT:    [[TMP2:%.*]] = load i32, i32* [[X_PRIV]], align 4
; CGSCC-NEXT:    ret i32 [[TMP2]]
;
entry:
  %tmp2 = load i32, i32* %x, align 4
  ret i32 %tmp2
}

define i32 @f(i32 %x) {
; TUNIT: Function Attrs: nofree norecurse nosync nounwind readnone willreturn
; TUNIT-LABEL: define {{[^@]+}}@f
; TUNIT-SAME: (i32 returned [[X:%.*]]) #[[ATTR0:[0-9]+]] {
; TUNIT-NEXT:  entry:
; TUNIT-NEXT:    [[X_ADDR:%.*]] = alloca i32, align 4
; TUNIT-NEXT:    store i32 [[X]], i32* [[X_ADDR]], align 4
; TUNIT-NEXT:    ret i32 [[X]]
;
; CGSCC: Function Attrs: nofree nosync nounwind readnone willreturn
; CGSCC-LABEL: define {{[^@]+}}@f
; CGSCC-SAME: (i32 [[X:%.*]]) #[[ATTR1:[0-9]+]] {
; CGSCC-NEXT:  entry:
; CGSCC-NEXT:    [[X_ADDR:%.*]] = alloca i32, align 4
; CGSCC-NEXT:    store i32 [[X]], i32* [[X_ADDR]], align 4
; CGSCC-NEXT:    [[TMP1:%.*]] = call i32 @deref(i32 [[X]]) #[[ATTR2:[0-9]+]]
; CGSCC-NEXT:    ret i32 [[TMP1]]
;
entry:
  %x_addr = alloca i32
  store i32 %x, i32* %x_addr, align 4
  %tmp1 = call i32 @deref( i32* %x_addr ) nounwind
  ret i32 %tmp1
}
;.
; TUNIT: attributes #[[ATTR0]] = { nofree norecurse nosync nounwind readnone willreturn }
;.
; CGSCC: attributes #[[ATTR0:[0-9]+]] = { argmemonly nofree norecurse nosync nounwind readonly willreturn }
; CGSCC: attributes #[[ATTR1:[0-9]+]] = { nofree nosync nounwind readnone willreturn }
; CGSCC: attributes #[[ATTR2:[0-9]+]] = { nounwind readonly willreturn }
;.
