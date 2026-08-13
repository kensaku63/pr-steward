# 複数 Session source の優先順位を field 単位で検証する

## 発生した問題（抽象化）

同じ Session を表す snapshot、detail、initial summary が同時に存在するとき、object 全体の source precedence は lifecycle や runtime freshness には正しくても、後から埋まる optional field には不適切なことがある。

上位 source の optional field が欠落しているだけで、下位の matching source にある確定値まで捨てると、UI は利用可能な値ではなく fallback を表示する。特に title のように runtime が後から refine する field では、object 全体の freshness と field の情報量が一致しない。

## 再発防止（How to apply）

1. PR が複数の Session source を一つの view model に射影するとき、object の選択順だけでなく、追加・変更した各 optional field の解決順を確認する。
2. field の欠落が clear を意味するのか、「未到着なので既存値を保持」を意味するのかを protocol / cache contract で確認する。後者なら matching Session ID の source 間で非空値を補完する。
3. lifecycle、runtime facts、token usage など freshness-sensitive field の precedence は変えず、必要な field だけを補完する。object 全体を stale source へ戻さない。
4. test は「上位 source に値がある」「上位 source がない」に加え、「上位 source はあるが対象 field だけ空、下位 matching source には値がある」と「別 ID の source は使わない」を固定する。
5. fallback label は全 matching source に usable value がない場合だけ出ることを確認する。
