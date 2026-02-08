import app from 'ags/gtk4/app';
import { exec } from 'ags/process';
import Gio from 'gi://Gio?version=2.0';
import Gtk from 'gi://Gtk?version=4.0';

import { AppLauncher } from './components/apps';
import { Bar } from './components/bar';
import { Notifications } from './components/notifications';
import style from './style.scss';

function nthIndex(str: string, searchString: string, n: number): number {
	const length = str.length;
	let i = -1;
	while (n-- && i++ < length) {
		i = str.indexOf(searchString, i);
		if (i < 0) {
			break;
		}
	}

	return i;
}

app.start({
	css: style,
	gtkTheme: 'Adwaita',
	main() {
		app.get_monitors().map(Bar);

		const appLauncher = AppLauncher() as Gtk.Window;
		app.add_window(appLauncher);

		const notifications = Notifications() as Gtk.Window;
		app.add_window(notifications);

		// sdnotify
		const file = Gio.File.new_for_path('/proc/self/stat');
		const [success, contents] = file.load_contents(null);
		if (!success) {
			console.log('Failed to read /proc/self/stat');
			return;
		}
		const data = new TextDecoder().decode(contents);
		const i = nthIndex(data, ' ', 3);
		const i2 = nthIndex(data, ' ', 4);
		const ppid = parseInt(data.substring(i + 1, i2));
		console.log(`Parent PID: ${ppid}`);

		console.log('informing systemd of ready status...');
		exec(['systemd-notify', `--pid=${ppid}`, '--ready']);
		console.log('informed systemd of ready status!');
	},
});
