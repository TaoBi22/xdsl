// RUN: xdsl-opt %s | xdsl-opt | filecheck %s

// Check that SSA values and blocks can reuse names across regions


"builtin.module"() ({

  // Two operations that share a basic block name and a argument name
  "test.op"() ({
  ^0(%0 : i32):
    "test.op"(%0) : (i32) -> ()
  }) : () -> ()

  // CHECK:      "test.op"() ({
  // CHECK-NEXT: ^{{.*}}(%{{.*}} : i32):
  // CHECK-NEXT:   "test.op"(%{{.*}}) : (i32) -> ()
  // CHECK-NEXT: }) : () -> ()


  "test.op"() ({
  ^0(%0 : i64):
    "test.op"(%0) : (i64) -> ()
  }) : () -> ()

  // CHECK:      "test.op"() ({
  // CHECK-NEXT: ^{{.*}}(%{{.*}} : i64):
  // CHECK-NEXT:   "test.op"(%{{.*}}) : (i64) -> ()
  // CHECK-NEXT: }) : () -> ()

  // Check that blocks in nested regions can clash names with the outer region blocks
  "test.op"() ({
  ^0(%0 : i1):
    "test.op"(%0) ({
      ^0:
    }, {
      ^0:
    }) : (i1) -> ()
    "test.op"(%0) : (i1) -> ()
  }) : () -> ()

  // CHECK:      "test.op"() ({
  // CHECK-NEXT: ^{{.*}}(%{{.*}} : i1):
  // CHECK-NEXT:   "test.op"(%{{.*}}) ({
  // CHECK-NEXT:   }, {
  // CHECK-NEXT:   }) : (i1) -> ()
  // CHECK-NEXT:   "test.op"(%{{.*}}) : (i1) -> ()
  // CHECK-NEXT: }) : () -> ()


  // Check that SSA names can be reused as long as they are defined after
  "test.op"() ({
  ^0(%0 : i1):
    "test.op"(%0) ({
      %1 = "test.op"() : () -> i32
    }, {
    }) : (i1) -> ()
    %1 = "test.op"() : () -> i32
    "test.op"(%0) : (i1) -> ()
  }): () -> ()


  // CHECK:      "test.op"() ({
  // CHECK-NEXT: ^{{.*}}(%{{.*}} : i1):
  // CHECK-NEXT:   "test.op"(%{{.*}}) ({
  // CHECK-NEXT:     %{{.*}} = "test.op"() : () -> i32
  // CHECK-NEXT:   }, {
  // CHECK-NEXT:   }) : (i1) -> ()
  // CHECK-NEXT:   %{{.*}} = "test.op"() : () -> i32
  // CHECK-NEXT:   "test.op"(%{{.*}}) : (i1) -> ()
  // CHECK-NEXT: }) : () -> ()


}) : () -> ()
