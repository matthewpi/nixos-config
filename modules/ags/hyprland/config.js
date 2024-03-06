import App from 'resource:///com/github/Aylur/ags/app.js';
import { execAsync } from 'resource:///com/github/Aylur/ags/utils.js';

const entry = `${App.configDir}/src/index.ts`;

// The AGS services runs as an isolated service, it has a private /tmp directory that is isolated
// from the main /tmp directory.
const outdir = '/tmp/ags/js';

await execAsync([
	'bun',
	'build',
	entry,
	'--outdir',
	outdir,
	// Ensure imports for resources and gi paths remain untouched while
	// allowing us to split our widgets and services into multiple files.
	'--external',
	'resource://*',
	'--external',
	'gi://*',
	'--external',
	'file://*',
]);

await import(`file://${outdir}/index.js`);
