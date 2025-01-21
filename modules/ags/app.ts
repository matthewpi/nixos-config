import { App, Gdk, Gtk } from 'astal/gtk4';
import Gio from 'gi://Gio';

import { Launcher } from './components/apps';
import { Bar } from './components/bar';
import { NotificationsWindow } from './components/notifications';
import style from './style.scss';

function main() {
	const display = Gdk.Display.get_default() ?? undefined;
	if (display === undefined) {
		return;
	}

	// @ts-expect-error go away
	const monitors: Gio.ListModel<Gdk.Monitor> = display.get_monitors();

	const bars = new Map<string, Gtk.Widget>();

	// Add a Bar for every monitor.
	{
		let monitor: Gdk.Monitor | null;
		for (let i = 0; (monitor = monitors.get_item(i)) !== null; i++) {
			console.log(monitor.connector, monitor);
			bars.set(monitor.connector, Bar(monitor));
		}
	}

	// Watch for changes to the monitors.
	monitors.connect('items-changed', async (v: Gio.ListModel<Gdk.Monitor>) => {
		// TODO: without this, it seems that a newly added monitor's `connector`
		// will be `null`.
		await new Promise(r => setTimeout(r, 100));

		const monitors = new Map<string, Gdk.Monitor>();

		let monitor: Gdk.Monitor | null;
		for (let i = 0; (monitor = v.get_item(i)) !== null; i++) {
			monitors.set(monitor.connector, monitor);
		}

		for (const connector of bars.keys()) {
			const monitor = monitors.get(connector);
			if (monitor === undefined) {
				console.log('monitor-removed', connector);
				// If there is no longer a monitor, delete the bar entry.
				bars.delete(connector);
				continue;
			}

			// If the monitor still exists, remove it from the monitors list.
			console.log('monitor-unchanged', connector);
			monitors.delete(connector);
		}

		for (const [connector, monitor] of monitors) {
			console.log('monitor-added', connector);
			bars.set(connector, Bar(monitor));
		}
	});

	NotificationsWindow();

	Launcher();
}

App.start({
	css: style,
	main,
});
