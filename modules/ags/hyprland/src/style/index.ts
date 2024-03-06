import App from 'resource:///com/github/Aylur/ags/app.js';
import { execAsync, monitorFile } from 'resource:///com/github/Aylur/ags/utils.js';

const entry = `${App.configDir}/src/index.scss`;
const outfile = '/tmp/ags/index.css';

/**
 * @returns execAsync(["bash", "-c", cmd])
 */
async function bash(strings: TemplateStringsArray | string, ...values: unknown[]) {
	const cmd =
		typeof strings === 'string' ? strings : strings.flatMap((str, i) => str + `${values[i] ?? ''}`).join('');

	return execAsync(['bash', '-c', cmd]).catch(err => {
		console.error(cmd, err);
		return '';
	});
}

async function resetCss(): Promise<void> {
	try {
		await bash`sass --scss --style compact '${entry}' '${outfile}'`;

		App.resetCss();
		App.applyCss(outfile);
	} catch (error: unknown) {
		print(error);
	}
}

async function init(): Promise<void> {
	monitorFile(entry, () => void resetCss());

	return resetCss();
}

export { init };
