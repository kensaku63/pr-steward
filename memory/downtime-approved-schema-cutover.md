# Downtime-approved schema cutover

When a migration cannot be made safe while old writers remain live, first ask the human whether a brief outage is acceptable. If the answer is yes and current usage permits it, the smallest safe cutover is usually to stop the complete writer fleet outside SQL, verify the stopped state with a bounded wait, run a read-only preflight, acquire the strong lock with a short transaction-local timeout, recheck the invariant under that lock, apply the migration, and deploy the target writer before restoring service.

Do not add maintenance-mode APIs, dual writes, or rolling compatibility solely to avoid an outage the human has explicitly accepted. Do not put provider operations or process termination inside a migration. If the migrated schema is incompatible with the old writer, a failed promotion must remain fail closed; automatically restarting the old writer can be worse than continued downtime.

Workflow contract tests should fix the sequence `stop -> stopped verification -> preflight -> migration -> target deploy -> readiness`. Keep migration-free deploys on their existing availability strategy.
