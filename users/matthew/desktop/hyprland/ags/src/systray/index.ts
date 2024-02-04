import Widget from 'resource:///com/github/Aylur/ags/widget.js';
import { lookUpIcon } from 'resource:///com/github/Aylur/ags/utils.js';
import SystemTray, { TrayItem } from 'resource:///com/github/Aylur/ags/service/systemtray.js';

function getTrayIcon(item: TrayItem): TrayItem['icon'] {
	// Icon can be either a string or GdkPixbuf.Pixbuf
	if (typeof item.icon !== 'string') {
		return item.icon;
	}

	// TODO: better fallback icon
	let icon = 'dialog-information-symbolic';
	if (lookUpIcon(item.icon) !== null) {
		icon = item.icon;
	}

	return icon;
}

function SysTrayIcon(item: TrayItem) {
	return Widget.Icon({
		// Set the initial icon to ensure the icon actually renders properly.
		icon: getTrayIcon(item),
		setup: self => {
			// Watch for changes to the item's icon.
			self.hook(item, self => {
				self.icon = getTrayIcon(item);
			});
		},
	});
}

function SysTrayItem(item: TrayItem) {
	return Widget.Button({
		child: SysTrayIcon(item),

		setup: self => {
			// Set the tooltip markup (the text that shows when you hover over the icon).
			self.hook(item, self => {
				self.tooltipMarkup = item.tooltip_markup;
			});
		},

		on_primary_click: (_, event) => item.activate(event),
		on_secondary_click: (_, event) => item.openMenu(event),
	});
}

function SysTray() {
	return Widget.Box({
		className: 'tray',
		children: SystemTray.bind('items').transform(items => items.map(item => SysTrayItem(item))),
	});
}

export { SysTray };
