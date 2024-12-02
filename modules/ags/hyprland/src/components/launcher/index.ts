import App from 'resource:///com/github/Aylur/ags/app.js';
import Service from 'resource:///com/github/Aylur/ags/service.js';
import { execAsync, lookUpIcon } from 'resource:///com/github/Aylur/ags/utils.js';
import Widget from 'resource:///com/github/Aylur/ags/widget.js';

import type { Application } from 'resource:///com/github/Aylur/ags/service/applications.js';

import GLib from 'gi://GLib?version=2.0';

const WINDOW_NAME = 'applauncher';

const applications = await Service.import('applications');

function icon(name: string | null, fallback = 'image-missing-symbolic') {
	if (name === null) {
		return fallback ?? '';
	}

	if (GLib.file_test(name, GLib.FileTest.EXISTS)) {
		return name;
	}

	const icon = name;
	if (lookUpIcon(icon)) {
		return icon;
	}

	print(`no icon substitute "${icon}" for "${name}", fallback: "${fallback}"`);
	return fallback;
}

function getRandomNumber(max: number): number {
	return Math.floor(Math.random() * max);
}

async function launch(app: Application): Promise<void> {
	const appName = app.app.get_name();
	const cmd = [
		'systemd-run',
		'--user',
		'--collect',
		'--no-block',
		'--slice=app',
		`--unit=app-${appName}@${getRandomNumber(32767)}`,
	];

	// If the application is VSCodium or Zed, set `Type=forking`.
	//
	// Both these editors fork themselves so they can provide multiple windows
	// and manage their child processes.
	switch (appName) {
		case 'VSCodium':
		case 'Zed':
			cmd.push('--property=Type=forking');
			break;
	}

	// Add the app's executable and flags to the command.
	cmd.push(...app.executable.split(/\s+/).filter(str => !str.startsWith('%') && !str.startsWith('@')));

	await execAsync(cmd).catch(err => {
		print(err);
	});

	app.frequency += 1;
}

function AppItem(app: Application) {
	return Widget.Button({
		className: 'app-item',
		attribute: {
			app,
		},
		onClicked: () => {
			App.closeWindow(WINDOW_NAME);
			void launch(app);
		},
		child: Widget.Box({
			className: 'app-item',
			children: [
				Widget.Icon({
					icon: icon(app.icon_name, 'application-x-executable-symbolic'),
					size: 32,
				}),
				Widget.Label({
					class_name: 'title',
					css: `margin-left: 0.75rem;`,
					label: app.name,
					xalign: 0,
					vpack: 'center',
					truncate: 'end',
				}),
			],
		}),
	});
}

const collator = new Intl.Collator(undefined, {
	numeric: true,
	sensitivity: 'base',
});

function queryApplications() {
	return applications
		.query('')
		.sort((a, b) => collator.compare(a.name, b.name))
		.map(AppItem);
}

function Launcher() {
	let items = queryApplications();

	// container holding the buttons
	const list = Widget.Box({
		vertical: true,
		children: items,
		spacing: 12,
	});

	// Search entry
	const entry = Widget.Entry({
		primaryIconName: 'system-search-symbolic',
		hexpand: true,

		// Launch the first item on Enter
		// TODO: we may need to find the first visible item due to how we handle filtering items.
		on_accept: () => {
			if (items.length < 1) {
				return;
			}

			const item = items[0];
			if (item === undefined) {
				return;
			}

			App.toggleWindow(WINDOW_NAME);
			void launch(item.attribute.app);
		},

		// List filtering.
		on_change: ({ text }) =>
			items.forEach(item => {
				item.visible = item.attribute.app.match(text ?? '');
			}),
	});

	// repopulate the box, so the most frequent apps are on top of the list
	function repopulate(): void {
		list.children = items = queryApplications();
	}

	function focus(): void {
		entry.text = '';
		entry.set_position(-1);
		entry.select_region(0, -1);
		entry.grab_focus();
		// quicklaunch.reveal_child = true;
	}

	return Widget.Box({
		vertical: true,
		className: 'app-launcher',
		children: [
			entry,
			Widget.Scrollable({
				hscroll: 'never',
				className: 'scrollable',
				css: `
                    min-width: 500px;
                    min-height: 500px;
                `,
				child: list,
			}),
		],
		setup: self => {
			self.hook(App, (_, windowName, visible) => {
				if (windowName !== WINDOW_NAME || !visible) {
					return;
				}

				if (!visible) {
					return;
				}

				repopulate();
				focus();
			});
		},
	});
}

function Window() {
	return Widget.Window({
		name: WINDOW_NAME,
		class_names: [WINDOW_NAME, 'popup-window'],
		visible: false,
		keymode: 'on-demand',
		exclusivity: 'ignore',
		layer: 'top',
		anchor: ['top', 'bottom', 'right', 'left'],
		child: Launcher(),
		setup: self => {
			self.keybind('Escape', () => {
				App.closeWindow(WINDOW_NAME);
			});
		},
	});
}

export { Window };
