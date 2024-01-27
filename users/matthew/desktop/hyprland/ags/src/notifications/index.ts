import App from 'resource:///com/github/Aylur/ags/app.js';

import Widget from 'resource:///com/github/Aylur/ags/widget.js';
import { lookUpIcon } from 'resource:///com/github/Aylur/ags/utils.js';

import Notifications from 'resource:///com/github/Aylur/ags/service/notifications.js';
import { Notification } from 'resource:///com/github/Aylur/ags/service/notifications.js';
import notifications from '../../types/service/notifications';

/**
 * ?
 */
function NotificationIcon(notification: Notification) {
	if (notification.image !== null) {
		return Widget.Box({
			css: `
                background-image: url("${notification.image}");
                background-size: contain;
                background-repeat: no-repeat;
                background-position: center;
            `,
		});
	}

	let icon = 'dialog-information-symbolic';
	if (lookUpIcon(notification.app_icon) !== null) {
		icon = notification.app_icon;
	}

	if (notification.app_entry !== null && lookUpIcon(notification.app_entry) !== null) {
		icon = notification.app_entry;
	}

	return Widget.Icon(icon);
}

/**
 * ?
 */
function NotificationBox(notification: Notification, popup: boolean) {
	const icon = Widget.Box({
		vpack: 'start',
		className: 'icon',
		child: NotificationIcon(notification),
	});

	const title = Widget.Label({
		className: 'title',
		hexpand: true,
		xalign: 0,
		justification: 'left',
		truncate: 'end',
		maxWidthChars: 24,
		wrap: true,
		useMarkup: true,
		label: notification.summary,
	});

	const body = Widget.Label({
		className: 'body',
		hexpand: true,
		xalign: 0,
		justification: 'left',
		wrap: true,
		useMarkup: true,
		label: notification.body,
	});

	const actions = Widget.Box({
		className: 'actions',
		children: notification.actions.map(({ id, label }) =>
			Widget.Button({
				className: 'action-button',
				hexpand: true,
				child: Widget.Label(label),
				on_clicked: () => notification.invoke(id),
			}),
		),
	});

	const close = Widget.Button({
		className: 'close-button',
		child: Widget.Icon('window-close'),
		on_clicked: () => {
			// If the notification is a popup dismiss it.
			if (popup) {
				notification.dismiss();
				return;
			}

			// If the notification was already dismissed (or wasn't a popup) close it forever.
			notification.close();
			// TODO: un-render notification.
		},
	});

	return Widget.EventBox({
		// attribute: {
		// 	id: notification.id,
		// 	destroy: () => notification.dismiss(),
		// },
		child: Widget.Box({
			className: `notification ${notification.urgency}`,
			children: [
				Widget.Box({
					vertical: true,
					children: [
						Widget.Box({
							children: [
								icon,
								Widget.Box({
									vertical: true,
									children: [title, body],
								}),
							],
						}),
						actions,
					],
				}),
				close,
			],
		}),
		// on_primary_click: () => notification.dismiss(),
	});
}

/**
 * ?
 */
function NotificationList() {
	return Widget.Box({
		className: 'notifications',
		vertical: true,
		css: 'padding: 1px;',
		children: Notifications.bind('popups').transform(popups => {
			console.log(popups);
			return popups.map(n => NotificationBox(n, true));
		}),
	});
}

/**
 * ?
 */
function NotificationButton() {
	return Widget.Button({
		className: 'notification-button',
		child: Widget.Stack({
			className: 'notification-icon',
			items: [
				// TODO: find better icons.
				['0', Widget.Icon('notifications')],
				['1', Widget.Icon('notifications')],
			],
			setup: self => {
				// TODO: switch what icon is being shown depending on if the window is being rendered or not.
				self.shown = '1';
			},
		}),
		on_primary_click: () => {
			// TODO: is there a better way to toggle a window like this?
			const windowName = 'yeet';
			for (const [name, window] of App.windows) {
				if (name !== windowName) {
					continue;
				}

				console.log('removing window');
				App.removeWindow(window);
				return;
			}

			App.addWindow(
				Widget.Window({
					name: windowName,
					className: '',
					anchor: ['top'],
					// @ts-expect-error go away
					child: NotificationTab(),
					// Ensure the window is removed when it is destroyed.
					setup: self => self.on('destroy', () => App.removeWindow(self)),
				}),
			);
		},
	});
}

/**
 *
 * @returns
 */
function NotificationTab() {
	return Widget.Box({
		vertical: true,
		className: 'notifications',
		css: 'padding: 1px;',
		// TODO: unrender window if all notifications are dismissed.
		children: Notifications.bind('notifications').transform(notifications => {
			console.log(notifications);
			return notifications.map(n => NotificationBox(n, false));
		}),
	});
}

/**
 * Creates a Notification Window pinned on a monitor.
 *
 * @param monitor ID of the monitor to render the Bar on.
 * @param monitorName Name of the monitor to render the Bar on.
 */
function NotificationWindow(monitor: number, monitorName: string) {
	return Widget.Window({
		name: `notifications-${monitorName}`,
		layer: 'top',
		anchor: ['top'],
		exclusivity: 'normal',
		className: '',
		// @ts-expect-error go away
		child: NotificationList(),
		monitor,
		// Ensure the window is removed when it is destroyed.
		setup: self => self.on('destroy', () => App.removeWindow(self)),
	});
}

export { NotificationButton, NotificationWindow };
