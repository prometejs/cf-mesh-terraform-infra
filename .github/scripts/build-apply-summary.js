// Render the apply-run report into the GitHub Actions job summary and emit
// run-level annotations (warnings/errors) so every workflow run leaves a
// visible record of plan/apply outcomes.
//
// Invoked from .github/workflows/apply.yml via actions/github-script@v7.
//
// Env vars (passed by the workflow):
//   WORKSPACE    - terraform workspace (dev/prod)
//   PLAN_RESULT  - needs.plan.result  (success/failure/skipped/cancelled)
//   APPLY_RESULT - needs.apply.result
//   NEW_SITES    - space-separated list of sites the plan reported as new

module.exports = async ({ core, context }) => {
  const { WORKSPACE, PLAN_RESULT, APPLY_RESULT, NEW_SITES } = process.env;
  const newSites = (NEW_SITES || '').trim().split(/\s+/).filter(Boolean);

  const icon = (r) =>
    ({ success: '✅', failure: '❌', skipped: '⏭', cancelled: '⛔' }[r] || '❓');

  let headline;
  if (PLAN_RESULT === 'success' && APPLY_RESULT === 'success') {
    headline = '✅ Apply succeeded';
  } else if (APPLY_RESULT === 'skipped') {
    headline = '⏭ Apply skipped (plan did not succeed)';
  } else {
    headline = '❌ Apply failed';
  }

  const runUrl = `${context.serverUrl}/${context.repo.owner}/${context.repo.repo}/actions/runs/${context.runId}`;

  core.summary
    .addHeading(headline, 2)
    .addTable([
      [{ data: 'Job', header: true }, { data: 'Result', header: true }],
      ['Plan', `${icon(PLAN_RESULT)} \`${PLAN_RESULT}\``],
      ['Apply', `${icon(APPLY_RESULT)} \`${APPLY_RESULT}\``],
    ])
    .addRaw(`**Workspace:** \`${WORKSPACE}\``, true)
    .addRaw(`**Triggered by:** @${context.actor}`, true)
    .addLink(`Run #${context.runId}`, runUrl);

  if (APPLY_RESULT === 'success' && newSites.length) {
    const list = newSites.map((s) => `\`${s}\``).join(', ');
    core.summary
      .addRaw('\n\n> [!IMPORTANT]\n', false)
      .addRaw(`> **New sites created this run:** ${list}\n`, false)
      .addRaw(
        "> If these haven't been onboarded yet, run `site-onboard.yml` against them to install the Cloudflare Mesh node and bring it online.\n",
        false,
      );
    core.warning(
      `New sites created: ${newSites.join(' ')}. Run site-onboard.yml to onboard them.`,
    );
  }

  if (PLAN_RESULT === 'failure') {
    core.error('Terraform plan failed — apply was skipped.');
  } else if (APPLY_RESULT === 'failure') {
    core.error('Terraform apply failed.');
  }

  await core.summary.write();
};
