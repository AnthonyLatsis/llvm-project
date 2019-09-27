; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt %s -instcombine -S | FileCheck %s

; If we have a shift by sign-extended value, we can replace sign-extension
; with zero-extension.

define i32 @t0_shl(i32 %x, i8 %shamt) {
; CHECK-LABEL: @t0_shl(
; CHECK-NEXT:    [[SHAMT_WIDE:%.*]] = sext i8 [[SHAMT:%.*]] to i32
; CHECK-NEXT:    [[R:%.*]] = shl i32 [[X:%.*]], [[SHAMT_WIDE]]
; CHECK-NEXT:    ret i32 [[R]]
;
  %shamt_wide = sext i8 %shamt to i32
  %r = shl i32 %x, %shamt_wide
  ret i32 %r
}
define i32 @t1_lshr(i32 %x, i8 %shamt) {
; CHECK-LABEL: @t1_lshr(
; CHECK-NEXT:    [[SHAMT_WIDE:%.*]] = sext i8 [[SHAMT:%.*]] to i32
; CHECK-NEXT:    [[R:%.*]] = lshr i32 [[X:%.*]], [[SHAMT_WIDE]]
; CHECK-NEXT:    ret i32 [[R]]
;
  %shamt_wide = sext i8 %shamt to i32
  %r = lshr i32 %x, %shamt_wide
  ret i32 %r
}
define i32 @t2_ashr(i32 %x, i8 %shamt) {
; CHECK-LABEL: @t2_ashr(
; CHECK-NEXT:    [[SHAMT_WIDE:%.*]] = sext i8 [[SHAMT:%.*]] to i32
; CHECK-NEXT:    [[R:%.*]] = ashr i32 [[X:%.*]], [[SHAMT_WIDE]]
; CHECK-NEXT:    ret i32 [[R]]
;
  %shamt_wide = sext i8 %shamt to i32
  %r = ashr i32 %x, %shamt_wide
  ret i32 %r
}

define <2 x i32> @t3_vec_shl(<2 x i32> %x, <2 x i8> %shamt) {
; CHECK-LABEL: @t3_vec_shl(
; CHECK-NEXT:    [[SHAMT_WIDE:%.*]] = sext <2 x i8> [[SHAMT:%.*]] to <2 x i32>
; CHECK-NEXT:    [[R:%.*]] = shl <2 x i32> [[X:%.*]], [[SHAMT_WIDE]]
; CHECK-NEXT:    ret <2 x i32> [[R]]
;
  %shamt_wide = sext <2 x i8> %shamt to <2 x i32>
  %r = shl <2 x i32> %x, %shamt_wide
  ret <2 x i32> %r
}
define <2 x i32> @t4_vec_lshr(<2 x i32> %x, <2 x i8> %shamt) {
; CHECK-LABEL: @t4_vec_lshr(
; CHECK-NEXT:    [[SHAMT_WIDE:%.*]] = sext <2 x i8> [[SHAMT:%.*]] to <2 x i32>
; CHECK-NEXT:    [[R:%.*]] = lshr <2 x i32> [[X:%.*]], [[SHAMT_WIDE]]
; CHECK-NEXT:    ret <2 x i32> [[R]]
;
  %shamt_wide = sext <2 x i8> %shamt to <2 x i32>
  %r = lshr <2 x i32> %x, %shamt_wide
  ret <2 x i32> %r
}
define <2 x i32> @t5_vec_ashr(<2 x i32> %x, <2 x i8> %shamt) {
; CHECK-LABEL: @t5_vec_ashr(
; CHECK-NEXT:    [[SHAMT_WIDE:%.*]] = sext <2 x i8> [[SHAMT:%.*]] to <2 x i32>
; CHECK-NEXT:    [[R:%.*]] = ashr <2 x i32> [[X:%.*]], [[SHAMT_WIDE]]
; CHECK-NEXT:    ret <2 x i32> [[R]]
;
  %shamt_wide = sext <2 x i8> %shamt to <2 x i32>
  %r = ashr <2 x i32> %x, %shamt_wide
  ret <2 x i32> %r
}

define i32 @t6_twoshifts(i32 %x, i8 %shamt) {
; CHECK-LABEL: @t6_twoshifts(
; CHECK-NEXT:  bb:
; CHECK-NEXT:    [[SHAMT_WIDE:%.*]] = sext i8 [[SHAMT:%.*]] to i32
; CHECK-NEXT:    br label [[WORK:%.*]]
; CHECK:       work:
; CHECK-NEXT:    br label [[END:%.*]]
; CHECK:       end:
; CHECK-NEXT:    [[N0:%.*]] = shl i32 [[X:%.*]], [[SHAMT_WIDE]]
; CHECK-NEXT:    [[R:%.*]] = ashr i32 [[N0]], [[SHAMT_WIDE]]
; CHECK-NEXT:    ret i32 [[R]]
;
bb:
  %shamt_wide = sext i8 %shamt to i32
  br label %work
work:
  %n0 = shl i32 %x, %shamt_wide
  %r = ashr i32 %n0, %shamt_wide
  br label %end
end:
  ret i32 %r
}

; This is not valid for funnel shifts in general
declare i7 @llvm.fshl.i7(i7 %a, i7 %b, i7 %c)
declare i7 @llvm.fshr.i7(i7 %a, i7 %b, i7 %c)
define i7 @n7_fshl(i7 %x, i7 %y, i6 %shamt) {
; CHECK-LABEL: @n7_fshl(
; CHECK-NEXT:    [[SHAMT_WIDE:%.*]] = sext i6 [[SHAMT:%.*]] to i7
; CHECK-NEXT:    [[R:%.*]] = call i7 @llvm.fshl.i7(i7 [[X:%.*]], i7 [[Y:%.*]], i7 [[SHAMT_WIDE]])
; CHECK-NEXT:    ret i7 [[R]]
;
  %shamt_wide = sext i6 %shamt to i7
  %r = call i7 @llvm.fshl.i7(i7 %x, i7 %y, i7 %shamt_wide)
  ret i7 %r
}
define i7 @n8_fshr(i7 %x, i7 %y, i6 %shamt) {
; CHECK-LABEL: @n8_fshr(
; CHECK-NEXT:    [[SHAMT_WIDE:%.*]] = sext i6 [[SHAMT:%.*]] to i7
; CHECK-NEXT:    [[R:%.*]] = call i7 @llvm.fshr.i7(i7 [[X:%.*]], i7 [[Y:%.*]], i7 [[SHAMT_WIDE]])
; CHECK-NEXT:    ret i7 [[R]]
;
  %shamt_wide = sext i6 %shamt to i7
  %r = call i7 @llvm.fshr.i7(i7 %x, i7 %y, i7 %shamt_wide)
  ret i7 %r
}
; And the cases that are safe are handled by SimplifyDemandedBits().
declare i8 @llvm.fshl.i8(i8 %a, i8 %b, i8 %c)
declare i8 @llvm.fshr.i8(i8 %a, i8 %b, i8 %c)
define i8 @t9_fshl(i8 %x, i8 %y, i6 %shamt) {
; CHECK-LABEL: @t9_fshl(
; CHECK-NEXT:    [[SHAMT_WIDE1:%.*]] = zext i6 [[SHAMT:%.*]] to i8
; CHECK-NEXT:    [[R:%.*]] = call i8 @llvm.fshl.i8(i8 [[X:%.*]], i8 [[Y:%.*]], i8 [[SHAMT_WIDE1]])
; CHECK-NEXT:    ret i8 [[R]]
;
  %shamt_wide = sext i6 %shamt to i8
  %r = call i8 @llvm.fshl.i8(i8 %x, i8 %y, i8 %shamt_wide)
  ret i8 %r
}
define i8 @t10_fshr(i8 %x, i8 %y, i6 %shamt) {
; CHECK-LABEL: @t10_fshr(
; CHECK-NEXT:    [[SHAMT_WIDE1:%.*]] = zext i6 [[SHAMT:%.*]] to i8
; CHECK-NEXT:    [[R:%.*]] = call i8 @llvm.fshr.i8(i8 [[X:%.*]], i8 [[Y:%.*]], i8 [[SHAMT_WIDE1]])
; CHECK-NEXT:    ret i8 [[R]]
;
  %shamt_wide = sext i6 %shamt to i8
  %r = call i8 @llvm.fshr.i8(i8 %x, i8 %y, i8 %shamt_wide)
  ret i8 %r
}

declare void @use32(i32)
define i32 @n11_extrause(i32 %x, i8 %shamt) {
; CHECK-LABEL: @n11_extrause(
; CHECK-NEXT:    [[SHAMT_WIDE:%.*]] = sext i8 [[SHAMT:%.*]] to i32
; CHECK-NEXT:    call void @use32(i32 [[SHAMT_WIDE]])
; CHECK-NEXT:    [[R:%.*]] = shl i32 [[X:%.*]], [[SHAMT_WIDE]]
; CHECK-NEXT:    ret i32 [[R]]
;
  %shamt_wide = sext i8 %shamt to i32
  call void @use32(i32 %shamt_wide)
  %r = shl i32 %x, %shamt_wide
  ret i32 %r
}
define i32 @n12_twoshifts_and_extrause(i32 %x, i8 %shamt) {
; CHECK-LABEL: @n12_twoshifts_and_extrause(
; CHECK-NEXT:    [[SHAMT_WIDE:%.*]] = sext i8 [[SHAMT:%.*]] to i32
; CHECK-NEXT:    br label [[WORK:%.*]]
; CHECK:       work:
; CHECK-NEXT:    br label [[END:%.*]]
; CHECK:       end:
; CHECK-NEXT:    [[N0:%.*]] = shl i32 [[X:%.*]], [[SHAMT_WIDE]]
; CHECK-NEXT:    [[R:%.*]] = ashr i32 [[N0]], [[SHAMT_WIDE]]
; CHECK-NEXT:    call void @use32(i32 [[SHAMT_WIDE]])
; CHECK-NEXT:    ret i32 [[R]]
;
  %shamt_wide = sext i8 %shamt to i32
  br label %work
work:
  %n0 = shl i32 %x, %shamt_wide
  %r = ashr i32 %n0, %shamt_wide
  br label %end
end:
  call void @use32(i32 %shamt_wide)
  ret i32 %r
}
