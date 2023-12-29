import App from 'resource:///com/github/Aylur/ags/app.js';

import { Widget } from 'resource:///com/github/Aylur/ags/widget.js';

import Audio from 'resource:///com/github/Aylur/ags/service/audio.js';
import Mpris from 'resource:///com/github/Aylur/ags/service/mpris.js';
import SystemTray from 'resource:///com/github/Aylur/ags/service/systemtray.js';

import AgsBox from 'resource:///com/github/Aylur/ags/widgets/box.js';
import AgsButton from 'resource:///com/github/Aylur/ags/widgets/button.js';
// import AgsLabel from 'resource:///com/github/Aylur/ags/widgets/label.js';
import AgsSlider from 'resource:///com/github/Aylur/ags/widgets/slider.js';
import AgsStack from 'resource:///com/github/Aylur/ags/widgets/stack.js';
import AgsWindow from 'resource:///com/github/Aylur/ags/widgets/window.js';

import Gtk from 'gi://Gtk?version=3.0';
import Gdk from 'gi://Gdk?version=3.0';

/**
 * ?
 *
 * @returns {AgsButton}
 */
function Clock() {
	return Widget.Button({
		className: 'clock',
		child: Widget.Box({
			className: 'clock-box',
			children: [TimeWithZone(), TimeWithZone('Etc/UTC')],
		}),
	});
}

/**
 * ?
 *
 * @param {string | undefined} timeZone ?
 *
 * @returns {AgsBox}
 */
function TimeWithZone(timeZone = undefined) {
	return Widget.Box({
		className: 'clock-display',
		connections: [
			[
				1000,
				(/** @type {AgsBox} */ self) => {
					const date = new Date();

					self.children = [
						Widget.Label({
							label: date.toLocaleTimeString('en-CA', {
								hour12: false,
								hour: '2-digit',
								minute: '2-digit',
								second: '2-digit',
								timeZone,
							}),
						}),
						Widget.Label({
							className: 'timezone',
							label: date
								.toLocaleDateString('en-CA', {
									day: '2-digit',
									timeZone,
									timeZoneName: 'short',
								})
								.slice(3), // 3 = ` ${timeZone}`, 4 = timeZone
						}),
					];
				},
			],
		],
	});
}

/**
 * ?
 *
 * @returns {AgsButton} ?
 */
function Media() {
	return Widget.Button({
		className: 'media',
		onPrimaryClick: () => Mpris.getPlayer('')?.playPause(),
		onScrollUp: () => Mpris.getPlayer('')?.next(),
		onScrollDown: () => Mpris.getPlayer('')?.previous(),
		child: Widget.Box({
			connections: [
				[
					Mpris,
					(/** @type {AgsBox} */ self) => {
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
					},
				],
			],
		}),
	});
}

/**
 * ?
 *
 * @returns {AgsBox} ?
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
				connections: [
					[
						Audio,
						(/** @type {AgsStack} */ self) => {
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
					],
				],
			}),
			Widget.Slider({
				className: 'volume-slider',
				hexpand: true,
				drawValue: false,
				on_change: (/** @type {AgsSlider} */ self) => {
					const speaker = Audio.speaker;
					if (speaker === undefined) {
						return;
					}

					speaker.volume = self.value;
				},
				connections: [
					[
						Audio,
						(/** @type {AgsSlider} */ self) => {
							const speaker = Audio.speaker;
							if (speaker === undefined) {
								self.value = 0;
								return;
							}

							self.value = speaker.volume;
						},
						'speaker-changed',
					],
				],
			}),
		],
	});
}

/**
 * ?
 *
 * @returns {AgsBox} ?
 */
function SysTray() {
	return Widget.Box({
		className: 'tray',
		connections: [
			[
				SystemTray,
				(/** @type {AgsBox} */ self) => {
					self.children = SystemTray.items.map(item =>
						Widget.Button({
							child: Widget.Icon({ binds: [['icon', item, 'icon']] }),
							binds: [['tooltip-markup', item, 'tooltip-markup']],
							on_primary_click: (/** @type {AgsButton} */ _, /** @type {Gdk.Event} */ event) =>
								item.activate(event),
							on_secondary_click: (/** @type {AgsButton} */ _, /** @type {Gdk.Event} */ event) =>
								item.openMenu(event),
						}),
					);
				},
			],
		],
	});
}

/**
 * ?
 *
 * @returns {AgsBox} ?
 */
function Left() {
	return Widget.Box({
		children: [Media()],
	});
}

/**
 * ?
 *
 * @returns {AgsBox} ?
 */
function Center() {
	return Widget.Box({
		children: [Clock()],
	});
}

/**
 * ?
 *
 * @returns {AgsBox} ?
 */
function Right() {
	return Widget.Box({
		hpack: 'end',
		children: [SysTray(), Volume()],
	});
}

/**
 * Creates a Bar pinned to the top of a monitor.
 *
 * @param {number} monitor ID of the monitor to render the Bar on.
 *
 * @returns {AgsWindow} ?
 */
function Bar(monitor) {
	return Widget.Window({
		name: `bar-${monitor}`,
		className: 'bar',
		anchor: ['top', 'left', 'right'],
		exclusivity: 'exclusive',
		child: Widget.CenterBox({
			startWidget: Left(),
			centerWidget: Center(),
			endWidget: Right(),
		}),
		monitor,
	});
}

/**
 * ?
 *
 * @param {Gdk.Display} display ?
 *
 * @returns {AgsWindow[]}
 */
function getWindows(display) {
	const numMonitors = display.get_n_monitors();
	if (numMonitors < 1) {
		return [];
	}

	console.log(`Number of Monitors: ${numMonitors}`);

	/** @type {AgsWindow[]} */
	let windows = [];
	for (let i = 0; i < numMonitors; i++) {
		const monitor = display.get_monitor(i);
		if (monitor === null) {
			console.log(`${i}: no monitor found`);
			continue;
		}

		console.log(`${i}: monitor found`);

		windows.push(Bar(i));
	}

	return windows;
}

/** @type {AgsWindow[]} */
let windows = [];

// Wonderful way to handle ensuring bars are rendered on all monitors.
//
// TODO: figure out if there is a better way to do this.
//
// The problem we are running into is that some monitor types are {Gtk.Monitor}
// but the Window wants a monitor/display id, which the other monitor type does
// not expose (at least from what I could find).
const display = Gdk.Display.get_default();
if (display !== null) {
	// Add the bar to all monitors.
	windows = getWindows(display);

	// Whenever a monitor is connected, remove then add bars to all monitors.
	display.connect('monitor-added', (_, monitor) => {
		console.log(`monitor-added: ${monitor}`);

		for (const [name] of App.windows) {
			console.log(`removing window: ${name}`);
			App.removeWindow(name);
		}

		for (const window of getWindows(display)) {
			App.addWindow(window);
		}
	});

	// Whenever a monitor is disconnected, remove then add bars to all monitors.
	display.connect('monitor-removed', (display, monitor) => {
		console.log(`monitor-removed: ${monitor}`);

		for (const [name] of App.windows) {
			console.log(`removing window: ${name}`);
			App.removeWindow(name);
		}

		for (const window of getWindows(display)) {
			App.addWindow(window);
		}
	});
}

// exporting the config so ags can manage the windows
export default {
	style: App.configDir + '/style.css',
	windows,
};
