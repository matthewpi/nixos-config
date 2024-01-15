import Widget from 'resource:///com/github/Aylur/ags/widget.js';
import { lookUpIcon } from 'resource:///com/github/Aylur/ags/utils.js';

import Notifications from 'resource:///com/github/Aylur/ags/service/notifications.js';
import { Notification } from 'resource:///com/github/Aylur/ags/service/notifications.js';

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
function NotificationBox(notification: Notification) {
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
		on_clicked: () => notification.dismiss(),
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
		children: Notifications.bind('popups').transform(popups => {
			return popups.map(NotificationBox);
		}),
		setup: self => {
			self.hook(
				Notifications,
				(box, id) => {
					console.log('notified');

					// Check if no notifications are currently being shown.
					// if (box.get_children().length == 0) {
					// 	Notifications.notifications.forEach(n => {
					// 		console.log(n);
					// 		box.pack_end(NotificationBox(n), false, false, 0);
					// 	});

					// 	box.show_all();
					// 	return;
					// }

					const n = Notifications.getNotification(id);
					if (n !== undefined) {
						console.log(n);
						// box.pack_end(NotificationBox(n), false, false, 0);
						// box.show_all();
					}
				},
				'notified',
			);

			self.hook(
				Notifications,
				(box, id) => {
					console.log('closed');
					if (!id) {
						return;
					}
					console.log(id);

					// for (const child of box.children) {
					// 	console.log(child._id);
					// 	if (child._id !== id) {
					// 		continue;
					// 	}

					// 	console.log('destroying', id);
					// 	child.attribute.destroy();
					// }
				},
				'closed',
			);
		},
	});
}

/**
 * ?
 *
 * @param {number} monitor ID of the monitor to render the Bar on.
 */
function NotificationWindow(monitor: number) {
	return Widget.Window({
		name: 'notifications',
		layer: 'top',
		anchor: ['top', 'right'],
		exclusivity: 'normal',
		child: NotificationList(),
		monitor,
	});
}

export { NotificationWindow };
