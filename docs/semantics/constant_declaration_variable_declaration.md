### Constant declaration, Variable declaration

constant-declaration (-> Let pattern-initializer pattern-initializer-tail?) [*1] =
```llvm
  ; pattern-initializer($0)...
  ; pattern-initializer-tail?($0)...
```

[*1] Assigning to a constant should be detected and rejected at the semantic analyzation.

variable-declaration (-> Var pattern-initializer pattern-initializer-tail?) =
```llvm
  ; pattern-initializer($0)...
  ; pattern-initializer-tail?($0)...
```

pattern-initializer (-> identifier-pattern(-> Identifier) Colon type) =
```llvm
; if $0.isGlobal() {
@\(Identifier) = global \(typeof(type($0)))
; } else {
  %\(Identifier) = alloca \(typeof(type($0)))
; }
```

pattern-initializer (-> identifier-pattern(-> Identifier) AssignmentOperator expression) =
```llvm
; if $0.isGlobal() {
; let type = typeof(expression($0))
@\(Identifier) = global \(type) zeroinitializer
  %0 = \(expression($0)...)
  %1 = getelementptr inbounds \(type) @\(Identifier), i32 0
  store \(type) %0, \(type)* %1
; } else {
  %0 = \(expression($0)...)
  %\(Identifier) = alloca \(typeof(expression($0)))
  store \(typeof(expression($0))) %0, \(typeof(expression($0)))* %\(Identifier)
; }
```

pattern-initializer (-> identifier-pattern(-> Identifier) Colon type AssignmentOperator expression) =
```llvm
; let t = typeof(type($0))
; if $0.isGlobal() {
@\(Identifier) = global \(t) zeroinitializer
  %0 = \(expression($0)...)
  %1 = getelementptr inbounds \(t) @\(Identifier), i32 0
  store \(t) %0, \(t)* %1
; } else {
  %0 = \(expression($0)...)
  %\(Identifier) = alloca \(t))
  store \(t) %0, \(t)* %\(Identifier)
; }
```

pattern-initializer (-> tuple-pattern Colon type) =
```llvm
  ; TODO
```

pattern-initializer (-> tuple-pattern AssignmentOperator expression) =
```llvm
  ; TODO
```

pattern-initializer (-> tuple-pattern Colon type AssignmentOperator expression) =
```llvm
  ; TODO
```
