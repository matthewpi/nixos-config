import App from 'resource:///com/github/Aylur/ags/app.js';
import Service from 'resource:///com/github/Aylur/ags/service.js';
import Widget from 'resource:///com/github/Aylur/ags/widget.js';

import Mpris from 'resource:///com/github/Aylur/ags/service/mpris.js';
import Notifications from 'resource:///com/github/Aylur/ags/service/notifications.js';

import { Window } from 'resource:///com/github/Aylur/ags/widgets/window.js';

import { Clock } from './clock';
import { Media } from './media';
import { NotificationButton, NotificationLabel, PopupNotificationWindow } from './notifications';
import { difference } from './set';
import { SysTray } from './systray';
// import { Volume } from './volume';

import Gdk from 'gi://Gdk?version=3.0';
import Gtk from 'gi://Gtk?version=3.0';
import GLib from 'gi://GLib?version=2.0';

function BarContent() {
	return Widget.CenterBox({
		// Left
		startWidget: Widget.Box({
			children: [Media()],
		}),
		// Center
		centerWidget: Widget.Box({
			children: [Clock()],
		}),
		// Right
		endWidget: Widget.Box({
			hpack: 'end',
			children: [SysTray(), NotificationLabel(), NotificationButton()],
		}),
	});
}

/**
 * Creates a Bar pinned to the top of a monitor.
 */
function Bar(monitor: number, name: string) {
	return Widget.Window({
		monitor,
		name: `bar-${name}`,
		className: 'bar',
		anchor: ['top', 'left', 'right'],
		exclusivity: 'exclusive',
		child: BarContent(),
		// Ensure the window is removed when it is destroyed.
		setup: self =>
			self.on('destroy', self => {
				print('window destroyed', self.name);
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

		const data = getMonitorByCoordinates(monitor.x, monitor.y, display);
		if (data === undefined) {
			print('failed to get gdk monitor');
			continue;
		}

		const { id, monitor: m } = data;

		// Mark the monitor as being processed.
		print('adding monitor', monitor.name);
		registeredMonitors.add(monitor.name);

		print(id, monitor.model, m.model);
		print(monitor.x, m.geometry.x);
		print(monitor.y, m.geometry.y);

		// Add a Bar to the monitor.
		addWindow(Bar(id, monitor.name));

		// // If this is the primary monitor, add the notification window.
		if (monitor.name === primaryMonitorName) {
			addWindow(PopupNotificationWindow(id, monitor.name));
		}
	}

	// Unregister the monitor if it was removed.
	for (const name of removedMonitors) {
		print('removing monitor', name);
		registeredMonitors.delete(name);
	}
});

function addWindow<Child extends Gtk.Widget, Attr>(win: Window<Child, Attr>): void {
	win.on('destroy', () => {
		print('window destroyed', win.name);
		App.removeWindow(win);
	});
	App.addWindow(win);
}

/**
 * Finds a {@type Gdk.Monitor} using coordinates. This function returns both the {@type Gdk.Monitor}
 * and numeric ID that are the closest matches to those coordinates.
 *
 * @param x ?
 * @param y ?
 * @param display ?
 * @returns ?
 */
function getMonitorByCoordinates(
	x: number,
	y: number,
	display?: Gdk.Display,
): { id: number; monitor: Gdk.Monitor } | undefined {
	// Allow the caller to pass a display instance if they already have it. This is an optimization
	// if the caller expects to call this function multiple times, I don't write inefficient code.
	if (display === undefined) {
		display = Gdk.Display.get_default() ?? undefined;
		if (display === undefined) {
			return undefined;
		}
	}

	// Get the monitor closest to those coordinates.
	const gdkMonitor = display.get_monitor_at_point(x, y);

	// Find the index of the monitor at those coordinates.
	const numMonitors = display.get_n_monitors();
	for (let i = 0; i < numMonitors; i++) {
		const m = display.get_monitor(i);

		if (m === gdkMonitor) {
			return {
				id: i,
				monitor: gdkMonitor,
			};
		}
	}

	return undefined;
}

// Service settings
Mpris.cacheCoverArt = false;
Notifications.popupTimeout = 10 * 1000;

App.resetCss();
const catppuccin = GLib.getenv('CATPPUCCIN_CSS') ?? undefined;
if (catppuccin !== undefined) {
	App.applyCss(catppuccin);
}
App.applyCss(`${App.configDir}/style.css`);

// exporting the config so ags can manage the windows
export default {
	windows: [],
};