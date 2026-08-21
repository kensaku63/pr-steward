# No-user mixed-version rollout

When a human confirms that an environment has no users and asks for the simplest deployment, a mixed-version writer race that requires user-triggered writes can be accepted as an explicit current-deployment premise instead of adding a compatibility layer, trigger, worker, or multi-release protocol.

Keep distinct what the answer proves: no user-triggered traffic does not prove that historical rows are absent. Retain the smallest safety needed for existing data, validate malformed legacy values without throwing, record the operational premise in the audit and handoff, and require the rolling-safe strategy to be reconsidered before users are introduced.
