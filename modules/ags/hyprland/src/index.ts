import App from 'resource:///com/github/Aylur/ags/app.js';
import Service from 'resource:///com/github/Aylur/ags/service.js';
import Widget from 'resource:///com/github/Aylur/ags/widget.js';

import Mpris from 'resource:///com/github/Aylur/ags/service/mpris.js';
import Notifications from 'resource:///com/github/Aylur/ags/service/notifications.js';

import { Window } from 'resource:///com/github/Aylur/ags/widgets/window.js';

import { BatteryIcon } from './components/battery';
import { Clock } from './components/clock';
import { Window as LauncherWindow } from './components/launcher';
import { Media } from './components/media';
import { NotificationButton, NotificationLabel, PopupNotificationWindow } from './components/notifications';
import { SysTray } from './components/systray';
// import { Volume } from './components/volume';
import { difference } from './set';
import { init as initStyle } from './style';

import Gdk from 'gi://Gdk?version=3.0';
import Gtk from 'gi://Gtk?version=3.0';

function BarContent() {
	return Widget.CenterBox({
		// Left
		startWidget: Widget.Box({
			children: [Media()],
		}),
		// Center
		centerWidget: Widget.Box({
			hpack: 'center',
			children: [Clock()],
		}),
		// Right
		endWidget: Widget.Box({
			hpack: 'end',
			children: [SysTray(), NotificationLabel(), NotificationButton(), BatteryIcon()],
		}),
	});
}

/**
 * Creates a Bar pinned to the top of a monitor.
 */
function Bar(monitor: Gdk.Monitor, name: string) {
	return Widget.Window({
		gdkmonitor: monitor,
		name: `bar-${name}`,
		className: 'bar',
		anchor: ['top', 'left', 'right'],
		exclusivity: 'exclusive',
		child: BarContent(),
		// Ensure the window is removed when it is destroyed.
		setup: self =>
			self.on('destroy', self => {
				App.removeWindow(self);
			}),
	});
}

/**
 * Name of the primary monitor.
 *
 * Used control which monitor widgets like notifications are displayed on.
 */
const primaryMonitorName = 'DP-3';
const registeredMonitors = new Set<string>();
const hyprland = await Service.import('hyprland');

/**
 * Hook into Hyprland to watch changes to monitors.
 *
 * This callback seems to get dispatched pretty often, even when monitors
 * don't change. Be careful about when windows are added or removed.
 */
hyprland.connect('notify::monitors', self => {
	const monitorSet = new Set<string>();
	for (const monitor of self.monitors) {
		// Make a set of monitors (this is used to detect monitor removals).
		monitorSet.add(monitor.name);
	}

	// Get the difference in monitors between the monitor list and the monitors map.
	// const newMonitors = difference(monitorSet, registeredMonitors);

	// Get the monitors that were removed.
	const removedMonitors = difference(registeredMonitors, monitorSet);

	// If the monitors have changed, re-render all the windows.
	const display = Gdk.Display.get_default() ?? undefined;
	for (const monitor of self.monitors) {
		if (registeredMonitors.has(monitor.name)) {
			continue;
		}

		const gdkMonitor = getMonitorByModel(monitor.model, display);
		if (gdkMonitor === undefined) {
			continue;
		}

		// Mark the monitor as being processed.
		registeredMonitors.add(monitor.name);

		// Add a Bar to the monitor.
		addWindow(Bar(gdkMonitor, monitor.name));

		// // If this is the primary monitor, add the notification window.
		if (monitor.name === primaryMonitorName) {
			addWindow(PopupNotificationWindow(gdkMonitor, monitor.name));
		}
	}

	// Unregister the monitor if it was removed.
	for (const name of removedMonitors) {
		registeredMonitors.delete(name);
	}
});

function addWindow<Child extends Gtk.Widget, Attr>(win: Window<Child, Attr>): void {
	win.on('destroy', () => {
		App.removeWindow(win);
	});

	App.addWindow(win);
}

/**
 * Finds a {@type Gdk.Monitor} using it's model number.
 *
 * This should only be used if all the monitors have different models and if coordinate matching
 * is unable to differentiate between the monitors.
 *
 * @param model ?
 * @param display ?
 * @returns ?
 */
function getMonitorByModel(model: string, display?: Gdk.Display): Gdk.Monitor | undefined {
	// Allow the caller to pass a display instance if they already have it. This is an optimization
	// if the caller expects to call this function multiple times, I don't write inefficient code.
	if (display === undefined) {
		display = Gdk.Display.get_default() ?? undefined;
		if (display === undefined) {
			return undefined;
		}
	}

	// Find the index of the monitor at those coordinates.
	const numMonitors = display.get_n_monitors();
	for (let i = 0; i < numMonitors; i++) {
		const m = display.get_monitor(i);
		if (m === null || m.model !== model) {
			continue;
		}

		return m;
	}

	return undefined;
}

/**
 * Finds a {@type Gdk.Monitor} using coordinates.
 *
 * @param x ?
 * @param y ?
 * @param display ?
 * @returns ?
 */
function getMonitorByCoordinates(x: number, y: number, display?: Gdk.Display): Gdk.Monitor | undefined {
	// Allow the caller to pass a display instance if they already have it. This is an optimization
	// if the caller expects to call this function multiple times, I don't write inefficient code.
	if (display === undefined) {
		display = Gdk.Display.get_default() ?? undefined;
		if (display === undefined) {
			return undefined;
		}
	}

	// Get the monitor closest to those coordinates.
	return display.get_monitor_at_point(x, y);
}

// Service settings
Mpris.cacheCoverArt = false;
Notifications.popupTimeout = 10 * 1000;

// exporting the config so ags can manage the windows
App.config({
	windows: [LauncherWindow()],
	onConfigParsed: () => {
		initStyle();
	},
});
