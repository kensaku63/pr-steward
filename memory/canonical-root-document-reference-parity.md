# Canonical root document reference parity

## 発生しやすい問題

shared document の generic formatter が canonical path を正しく出力していても、特別な root document を受け取る側の regex、parser、builder、known-entity resolver が別の allowlist を持つと、コピー時は成功して見える参照が貼り付け後に invalid になる。

通常の `<kind>/<id>.md` だけを component test で固定しても、uppercase canonical filename と reserved lowercase ID を持つ root document の drift は検知できない。producer の正しさと consumer の受理可能性は別々に確認する。

## Review で確認する境界

canonical document reference を追加・変更・再利用する PR では、次を同じ contract として追う。

1. authoritative shared-document path registry が定義する special root filename / ID。
2. client の project-relative path parser と canonical path builder。
3. WikiLink の regex、parse、build、reserved-alias rejection。
4. known-entity / navigation surface が builder の canonical target を使うか。
5. copy、drag/drop、composer insertion など reference producer の exact output。

各 special root について `canonical path -> parse -> ID -> build -> same canonical path` の round trip を固定し、lowercase / mixed-case の reserved alias は引き続き拒否する。UI producer には少なくとも通常 document と special root の exact clipboard assertion を置く。

## 最小修正の選び方

- formatter が authoritative canonical path を出しているなら、header だけの例外や別形式の fallback を足さず、drift した consumer を直す。
- 既存 special-root mapping に1件欠けているだけなら、対称な mapping と境界 test が最小解になり得る。
- source-of-truth 共通化は、循環依存や新しい abstraction を増やさず現在の変更経路を実際に減らせる場合だけ別途採用する。レビュー edge case を理由に incidental refactor へ広げない。
- hosted suite が green でも special root の case が無ければ contract parity の証拠にはならない。対象 case を実行した focused test と exact final-head check を分けて記録する。

