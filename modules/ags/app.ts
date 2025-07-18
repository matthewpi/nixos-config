import app from 'ags/gtk4/app';
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
	},
});
