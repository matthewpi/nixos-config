import App from 'resource:///com/github/Aylur/ags/app.js';

import Widget from 'resource:///com/github/Aylur/ags/widget.js';
import { lookUpIcon } from 'resource:///com/github/Aylur/ags/utils.js';

import Audio from 'resource:///com/github/Aylur/ags/service/audio.js';
import Hyprland from 'resource:///com/github/Aylur/ags/service/hyprland.js';
import Mpris from 'resource:///com/github/Aylur/ags/service/mpris.js';
import SystemTray, { TrayItem } from 'resource:///com/github/Aylur/ags/service/systemtray.js';

import { Clock } from './clock';
import { NotificationButton, NotificationWindow } from './notifications';

/**
 * ?
 */
function Media() {
	return Widget.Button({
		className: 'media',
		onPrimaryClick: () => Mpris.getPlayer('')?.playPause(),
		onScrollUp: () => Mpris.getPlayer('')?.next(),
		onScrollDown: () => Mpris.getPlayer('')?.previous(),
		child: Widget.Box({
			setup: self => {
				self.hook(Mpris, () => {
					const mpris = Mpris.getPlayer('');

					const children = [];
					switch (mpris?.play_back_status ?? '') {
						case 'Paused':
							children.push(
								Widget.Box({
									className: 'media-icon',
									child: Widget.Icon({ icon: 'media-playback-pause', size: 20 }),
								}),
							);
							break;
						case 'Playing':
							children.push(
								Widget.Box({
									className: 'media-icon',
									child: Widget.Icon({ icon: 'media-playback-start', size: 20 }),
								}),
							);
							break;
					}

					if (mpris === null) {
						children.push(
							Widget.Label({
								className: 'media-label',
								label: 'Nothing is playing',
							}),
						);
					} else {
						const boxChildren = [
							Widget.Label({
								className: 'media-title',
								label: mpris.track_title,
							}),
						];

						if (mpris.track_artists.length > 0) {
							boxChildren.push(
								Widget.Label({
									className: 'media-artists',
									label: `By ${mpris.track_artists.join(', ')}`.trim(),
								}),
							);
						}

						children.push(
							Widget.Box({
								className: 'media-label',
								vertical: true,
								homogeneous: false,
								children: boxChildren,
							}),
						);
					}

					self.children = children;
				});
			},
		}),
	});
}

/**
 * ?
 */
function Volume() {
	return Widget.Box({
		className: 'volume',
		css: 'min-width: 180px',
		children: [
			Widget.Stack({
				className: 'volume-icon',
				items: [
					// tuples of [string, Widget]
					['101', Widget.Icon('audio-volume-overamplified-symbolic')],
					['67', Widget.Icon('audio-volume-high-symbolic')],
					['34', Widget.Icon('audio-volume-medium-symbolic')],
					['1', Widget.Icon('audio-volume-low-symbolic')],
					['0', Widget.Icon('audio-volume-muted-symbolic')],
				],
				setup: self => {
					self.hook(
						Audio,
						() => {
							const speaker = Audio.speaker;
							if (speaker === undefined) {
								return;
							}

							// `speaker.is_muted` is only true when the volume is set to 0,
							// while `speaker.stream.is_muted` handles the audio output being
							// muted separately of volume control.
							if (speaker.is_muted || speaker.stream.is_muted) {
								self.shown = '0';
								return;
							}

							// Find the icon to show for the current volume.
							const show = [101, 67, 34, 1, 0].find(threshold => threshold <= speaker.volume * 100);

							// Show the correct icon, defaulting to audio muted if a matching icon
							// couldn't be found.
							self.shown = (show ?? 0).toString();
						},
						'speaker-changed',
					);
				},
			}),
			Widget.Slider({
				className: 'volume-slider',
				hexpand: true,
				drawValue: false,
				setup: self => {
					self.hook(
						Audio,
						() => {
							const speaker = Audio.speaker;
							if (speaker === undefined) {
								self.value = 0;
								return;
							}

							self.value = speaker.volume;
						},
						'speaker-changed',
					);

					self.on_change = self => {
						const speaker = Audio.speaker;
						if (speaker === undefined) {
							return;
						}

						speaker.volume = self.value;
					};
				},
			}),
		],
	});
}

function SysTrayIcon(item: TrayItem) {
	// Icon can be either a string or GdkPixbuf.Pixbuf
	if (typeof item.icon !== 'string') {
		return Widget.Icon({
			icon: item.icon,
		});
	}

	// TODO: better fallback icon
	let icon = 'dialog-information-symbolic';
	if (lookUpIcon(item.icon) !== null) {
		icon = item.icon;
	}

	return Widget.Icon({ icon });
}

/**
 * ?
 */
function SysTray() {
	return Widget.Box({
		className: 'tray',
		setup: self => {
			self.hook(SystemTray, () => {
				self.children = SystemTray.items.map(item => {
					return Widget.Button({
						child: SysTrayIcon(item),
						// TODO: figure out how to port these to the new API properly.
						// child: Widget.Icon({ binds: [['icon', item, 'icon']] }),
						// binds: [['tooltip-markup', item, 'tooltip-markup']],

						// @ts-expect-error fix these types
						on_primary_click: (_, event) => {
							item.activate(event);
						},
						// @ts-expect-error fix these types
						on_secondary_click: (_, event) => {
							item.openMenu(event);
						},
					});
				});
			});
		},
	});
}

/**
 * ?
 */
function Left() {
	return Widget.Box({
		children: [Media()],
	});
}

/**
 * ?
 */
function Center() {
	return Widget.Box({
		children: [Clock()],
	});
}

/**
 * ?
 */
function Right() {
	return Widget.Box({
		hpack: 'end',
		children: [SysTray(), Volume(), NotificationButton()],
	});
}

/**
 * Creates a Bar pinned to the top of a monitor.
 *
 * @param monitor ID of the monitor to render the Bar on.
 * @param monitorName Name of the monitor to render the Bar on.
 */
function Bar(monitor: number, monitorName: string) {
	return Widget.Window({
		name: `bar-${monitorName}`,
		className: 'bar',
		anchor: ['top', 'left', 'right'],
		exclusivity: 'exclusive',
		// @ts-expect-error go away
		child: Widget.CenterBox({
			startWidget: Left(),
			centerWidget: Center(),
			endWidget: Right(),
		}),
		monitor,
		// Ensure the window is removed when it is destroyed.
		setup: self => self.on('destroy', () => App.removeWindow(self)),
	});
}

/**
 * Name of the primary monitor.
 *
 * Used control which monitor widgets like notifications are displayed on.
 */
const primaryMonitorName = 'DP-3';

const registeredMonitors = new Set<string>();

/**
 * Hook into Hyprland to watch changes to monitors.
 *
 * This callback seems to get dispatched pretty often, even when monitors
 * don't change. Be careful about when windows are added or removed.
 */
Hyprland.connect('notify::monitors', () => {
	const monitorSet = new Set<string>();
	for (const monitor of Hyprland.monitors) {
		// Make a list of monitors (this is used to detect monitor removals).
		monitorSet.add(monitor.name);

		// Check if the monitor has already been processed.
		if (registeredMonitors.has(monitor.name)) {
			continue;
		}

		// Add a Bar to the monitor.
		App.addWindow(Bar(monitor.id, monitor.name));

		// If this is the primary monitor, add the notification window.
		if (monitor.name === primaryMonitorName) {
			App.addWindow(NotificationWindow(monitor.id, monitor.name));
			continue;
		}
	}

	// Get the difference in monitors between the monitor list and the monitors map.
	const newMonitors = difference(monitorSet, registeredMonitors);

	for (const name of newMonitors) {
		// Mark the monitor as being processed.
		registeredMonitors.add(name);
	}

	const diff = difference(registeredMonitors, monitorSet);

	// Unregister the monitor if it was removed.
	// If it gets re-added the windows will be re-created.
	for (const name of diff) {
		registeredMonitors.delete(name);

		// TODO: find matching windows with the monitor's name?
	}
});

function isSuperset<T>(set: Set<T>, subset: Set<T>): boolean {
	for (const elem of subset) {
		if (!set.has(elem)) {
			return false;
		}
	}
	return true;
}

function union<T>(setA: Set<T>, setB: Set<T>): Set<T> {
	const _union = new Set<T>(setA);
	for (const elem of setB) {
		_union.add(elem);
	}
	return _union;
}

function intersection<T>(setA: Set<T>, setB: Set<T>): Set<T> {
	const _intersection = new Set<T>();
	for (const elem of setB) {
		if (setA.has(elem)) {
			_intersection.add(elem);
		}
	}
	return _intersection;
}

function symmetricDifference<T>(setA: Set<T>, setB: Set<T>): Set<T> {
	const _difference = new Set<T>(setA);
	for (const elem of setB) {
		if (_difference.has(elem)) {
			_difference.delete(elem);
		} else {
			_difference.add(elem);
		}
	}
	return _difference;
}

function difference<T>(setA: Set<T>, setB: Set<T>): Set<T> {
	const _difference = new Set<T>(setA);
	for (const elem of setB) {
		_difference.delete(elem);
	}
	return _difference;
}

// exporting the config so ags can manage the windows
export default {
	style: App.configDir + '/style.css',
	windows: [],
	notificationPopupTimeout: 10 * 1000,
	cacheCoverArt: false,
};
