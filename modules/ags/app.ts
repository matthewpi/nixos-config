import { App, Gdk, Gtk } from 'astal/gtk3';

import { Launcher } from './components/apps';
import { Bar, BluetoothWindow } from './components/bar';
import { NotificationPopups } from './components/notifications';
import style from './style.scss';

function main() {
	const bars = new Map<Gdk.Monitor, Gtk.Widget>();

	for (const monitor of App.get_monitors()) {
		bars.set(monitor, Bar(monitor));
	}

	App.connect('monitor-added', (_, monitor) => {
		bars.set(monitor, Bar(monitor));
	});

	App.connect('monitor-removed', (_, monitor) => {
		bars.get(monitor)?.destroy();
		bars.delete(monitor);
	});

	NotificationPopups();

	// TODO: is there a better way to keep the launcher window hidden?
	Launcher();
	App.get_window('launcher')?.hide();

	BluetoothWindow();
	App.get_window('bluetooth')?.hide();
}

App.start({
	css: style,
	main,
	requestHandler(request, res) {
		print(request);
		res('ok');
	},
});
