# Mock boundary fix は遷移先 caller の side effect まで追う

Mock installerから直接の永続書き込みを除いても、in-memory projectionを受け取る既存callerが後から同じdurable authorityを書き換えることがある。installer直後のlocalStorage / cookie不変テストだけでは、mock利用全体の不変条件を証明できない。

最終reviewでは、mock entryからtarget production routeまでのchainを一続きで確認する。

1. Entryからtargetへのnavigationがmiddleware / route gateを通過できるか。元のcookie writeがgate通過も兼ねていた場合、writeを消すだけでclean browserがtargetへ到達不能になり得る。
2. In-memory identityのfieldを購読するlayout / provider / effectが、cookie、localStorage、observability identity、別storeへ同期しないか。
3. Teardown直後だけでなく、target mount、reload、mock外へのnavigation後にもdurable valueが元のbyte / semantic valueを保つか。
4. Persisted stateが存在する場合と存在しない場合を分けて固定する。absence testは「mock値を残さない」だけでなく、中心flowが到達可能かも確認する。

このchainで矛盾が見つかり、解消にmiddleware marker、temporary cookie、snapshot / restore、production component guardなど新しいcaller protocolやlifecycleが必要なら、局所patchを足さない。Approved planのsimplicity budgetを越えるarchitecture deltaとしてplanningまたは人間判断へ戻す。

Browser smokeが使えない場合は`browser-unavailable`のままにし、installer unit testをnavigation / mount lifecycleのPASSへ読み替えない。静的caller追跡とfocused component / middleware testで証拠を補えても、browser実測とは区別する。
