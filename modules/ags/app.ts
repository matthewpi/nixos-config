import { App, Gdk, Gtk } from 'astal/gtk4';

import { Launcher } from './components/apps';
import { Bar } from './components/bar';
import { NotificationsWindow } from './components/notifications';
import style from './style.scss';

function main() {
	const bars = new Map<Gdk.Monitor, Gtk.Widget>();

	for (const monitor of App.get_monitors()) {
		bars.set(monitor, Bar(monitor));
	}

	// App.connect('monitor-added', (_, monitor) => {
	// 	bars.set(monitor, Bar(monitor));
	// });

	// App.connect('monitor-removed', (_, monitor) => {
	// 	bars.get(monitor)?.destroy();
	// 	bars.delete(monitor);
	// });

	NotificationsWindow();

	Launcher();
}

App.start({
	css: style,
	main,
	requestHandler(request: string, res: (response: any) => void) {
		print(request);

		return res('ok');
	},
});
