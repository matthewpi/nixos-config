import app from 'ags/gtk4/app';
import { exec } from 'ags/process';
import Gio from 'gi://Gio?version=2.0';
import Gtk from 'gi://Gtk?version=4.0';

import { AppLauncher } from './components/apps';
import { Bar } from './components/bar';
import { Notifications } from './components/notifications';
import style from './style.scss';

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
		const credentials = new Gio.Credentials();
		const pid = credentials.get_unix_pid();
		console.log('informing systemd of ready status...');
		exec(['systemd-notify', `--pid=${pid}`, '--ready']);
		console.log('informed systemd of ready status!');
	},
});
