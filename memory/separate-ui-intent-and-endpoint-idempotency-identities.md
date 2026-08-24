# UI intent identity と endpoint idempotency identity を分離する

## 発生した問題（抽象化）

Composer の typed command を既存の専用 endpoint へ再配線した際、送信 snapshot の client nonce を、そのまま endpoint の `request_id` に流用した。client nonce は draft の CAS clear に適した UI intent identity だったが、endpoint は UUID の idempotency identity を要求していた。mock mutation は任意文字列を受理するため、component/unit test は routing 成功を示しても wire contract の不一致を検出しなかった。

## 再発防止（How to apply）

1. UI から既存 mutation を復元・再配線するときは、旧 caller と server request type を読み、各 identifier の format と semantic owner を照合する。
2. draft nonce、submission nonce、operation request ID、resource ID を「一意な文字列」として交換可能に扱わない。UI intent の CAS identity と endpoint の idempotency identity は別の責務である。
3. endpoint が既存 request-ID generator を持つ場合は、その owner を復元する。Composer snapshot の nonce は、成功後に同じ draft だけを clear する用途へ限定する。
4. retry semantics も確認する。同じ operation の transport retry では request ID を再利用し、後続の新しい user action では既存 contract に従って新しい request ID を発行する。
5. test は callback が呼ばれた事実だけでなく、wire が要求する format の request ID が mutation に渡ることと、UI nonce が endpoint body に漏れないことを固定する。

## Review signal

typed command routing、既存 endpoint の復活、idempotent mutation、draft success/failure recovery が同じ差分にある場合は、final review で identifier の型・format・lifecycle を横断する。`string` 同士でも owner が違えば contract mismatch の可能性がある。
