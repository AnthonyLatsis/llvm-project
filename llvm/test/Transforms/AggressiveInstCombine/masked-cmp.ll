; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -aggressive-instcombine -S | FileCheck %s

; PR37098 - https://bugs.llvm.org/show_bug.cgi?id=37098

define i32 @anyset_two_bit_mask(i32 %x) {
; CHECK-LABEL: @anyset_two_bit_mask(
; CHECK-NEXT:    [[TMP1:%.*]] = and i32 [[X:%.*]], 9
; CHECK-NEXT:    [[TMP2:%.*]] = icmp ne i32 [[TMP1]], 0
; CHECK-NEXT:    [[TMP3:%.*]] = zext i1 [[TMP2]] to i32
; CHECK-NEXT:    ret i32 [[TMP3]]
;
  %s = lshr i32 %x, 3
  %o = or i32 %s, %x
  %r = and i32 %o, 1
  ret i32 %r
}

define i32 @anyset_four_bit_mask(i32 %x) {
; CHECK-LABEL: @anyset_four_bit_mask(
; CHECK-NEXT:    [[TMP1:%.*]] = and i32 [[X:%.*]], 297
; CHECK-NEXT:    [[TMP2:%.*]] = icmp ne i32 [[TMP1]], 0
; CHECK-NEXT:    [[TMP3:%.*]] = zext i1 [[TMP2]] to i32
; CHECK-NEXT:    ret i32 [[TMP3]]
;
  %t1 = lshr i32 %x, 3
  %t2 = lshr i32 %x, 5
  %t3 = lshr i32 %x, 8
  %o1 = or i32 %t1, %x
  %o2 = or i32 %t2, %t3
  %o3 = or i32 %o1, %o2
  %r = and i32 %o3, 1
  ret i32 %r
}

; We're not testing the LSB here, so all of the 'or' operands are shifts.

define i32 @anyset_three_bit_mask_all_shifted_bits(i32 %x) {
; CHECK-LABEL: @anyset_three_bit_mask_all_shifted_bits(
; CHECK-NEXT:    [[TMP1:%.*]] = and i32 [[X:%.*]], 296
; CHECK-NEXT:    [[TMP2:%.*]] = icmp ne i32 [[TMP1]], 0
; CHECK-NEXT:    [[TMP3:%.*]] = zext i1 [[TMP2]] to i32
; CHECK-NEXT:    ret i32 [[TMP3]]
;
  %t1 = lshr i32 %x, 3
  %t2 = lshr i32 %x, 5
  %t3 = lshr i32 %x, 8
  %o2 = or i32 %t2, %t3
  %o3 = or i32 %t1, %o2
  %r = and i32 %o3, 1
  ret i32 %r
}

; TODO: Recognize the 'and' sibling pattern. The 'and 1' may not be at the end.

define i64 @allset_four_bit_mask(i64 %x) {
; CHECK-LABEL: @allset_four_bit_mask(
; CHECK-NEXT:    [[T1:%.*]] = lshr i64 [[X:%.*]], 1
; CHECK-NEXT:    [[T2:%.*]] = lshr i64 [[X]], 2
; CHECK-NEXT:    [[T3:%.*]] = lshr i64 [[X]], 3
; CHECK-NEXT:    [[T4:%.*]] = lshr i64 [[X]], 4
; CHECK-NEXT:    [[A1:%.*]] = and i64 [[T4]], 1
; CHECK-NEXT:    [[A2:%.*]] = and i64 [[T2]], [[A1]]
; CHECK-NEXT:    [[A3:%.*]] = and i64 [[A2]], [[T1]]
; CHECK-NEXT:    [[R:%.*]] = and i64 [[A3]], [[T3]]
; CHECK-NEXT:    ret i64 [[R]]
;
  %t1 = lshr i64 %x, 1
  %t2 = lshr i64 %x, 2
  %t3 = lshr i64 %x, 3
  %t4 = lshr i64 %x, 4
  %a1 = and i64 %t4, 1
  %a2 = and i64 %t2, %a1
  %a3 = and i64 %a2, %t1
  %r = and i64 %a3, %t3
  ret i64 %r
}

