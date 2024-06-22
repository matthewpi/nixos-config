import App from 'resource:///com/github/Aylur/ags/app.js';

import Widget from 'resource:///com/github/Aylur/ags/widget.js';
import { lookUpIcon } from 'resource:///com/github/Aylur/ags/utils.js';

import Notifications from 'resource:///com/github/Aylur/ags/service/notifications.js';
import { Notification } from 'resource:///com/github/Aylur/ags/service/notifications.js';

import type { Label } from 'resource:///com/github/Aylur/ags/widgets/label.js';

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

	let icon = 'notification-symbolic';
	if (lookUpIcon(notification.app_icon) !== null) {
		icon = notification.app_icon;
	}

	if (
		notification.app_entry !== undefined &&
		notification.app_entry !== null &&
		lookUpIcon(notification.app_entry) !== null
	) {
		icon = notification.app_entry;
	}

	return Widget.Icon({ icon });
}

/**
 * ?
 */
function NotificationBox(notification: Notification, popup: boolean) {
	// @ts-expect-error go away (TODO figure out why this is erroring)
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
		child: Widget.Icon('close-symbolic'),
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

	const content = Widget.Box({
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
	});

	const container = Widget.Box({
		className: `notification ${notification.urgency}`,
		children: [content, close],
	});

	return Widget.EventBox({
		child: container,
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
			return popups.map(n => NotificationBox(n, true));
		}),
	});
}

interface NotificationLabelAttrs {
	unreadCount: number;
	update: (self: Label<NotificationLabelAttrs>) => void;
}

function NotificationLabel() {
	return Widget.Label<NotificationLabelAttrs>({
		className: '',
		label: '0',
		attribute: {
			unreadCount: 0,
			update: self => {
				self.label = self.attribute.unreadCount.toString();
			},
		},
		setup: self => {
			self.hook(Notifications, (self, _) => {
				// This isn't the "unread" count, instead it is just the number of notifications
				// that have been dismissed (either manually or after a timeout).
				//
				// If we want a proper unread count we will need to track when the notifications
				// list is opened and closed.
				self.attribute.unreadCount = Notifications.notifications.length;
				self.attribute.update(self);
			});
		},
	});
}

function NotificationsWindow(name: string) {
	return Widget.Window({
		name,
		className: 'notifications-window',
		anchor: ['top'],
		child: NotificationTab(),
	});
}

const WINDOW_NAME = 'yeet';

function closeNotificationWindow(): void {
	for (const window of App.windows) {
		if (window.name !== WINDOW_NAME) {
			continue;
		}

		App.removeWindow(window);
		break;
	}
}

/**
 * ?
 */
function NotificationButton() {
	return Widget.Button({
		className: 'notification-button',
		child: Widget.Stack({
			className: 'notification-icon',
			children: {
				0: Widget.Icon('notifications-symbolic'),
				1: Widget.Icon('notifications-new-symbolic'),
			},
			setup: self => {
				self.hook(Notifications, self => {
					if (Notifications.notifications.length < 1) {
						self.shown = 0;
						return;
					}

					self.shown = 1;
				});
			},
		}),
		on_primary_click: () => {
			// TODO: is there a better way to toggle a window like this?
			for (const window of App.windows) {
				if (window.name !== WINDOW_NAME) {
					continue;
				}

				App.removeWindow(window);
				return;
			}

			App.addWindow(NotificationsWindow(WINDOW_NAME));
		},
		setup: self => {
			self.hook(Notifications, () => {
				if (Notifications.notifications.length > 0) {
					return;
				}

				// Close the notification window after all notifications are closed.
				closeNotificationWindow();
			});
		},
	});
}

function NotificationTab() {
	return Widget.Box({
		vertical: true,
		className: 'notifications',
		css: 'padding: 1px;',
		children: Notifications.bind('notifications').transform(notifications => {
			return notifications.map(n => NotificationBox(n, false));
		}),
	});
}

/**
 * Creates a Notification Window pinned on a monitor.
 *
 * @param gdkmonitor ID of the monitor to render the Bar on.
 * @param monitorName Name of the monitor to render the Bar on.
 */
function PopupNotificationWindow(monitor: Gdk.Monitor, name: string) {
	return Widget.Window({
		gdkmonitor: monitor,
		name: `notifications-${name}`,
		layer: 'top',
		anchor: ['top'],
		exclusivity: 'normal',
		className: 'notification-popups',
		child: NotificationList(),
	});
}

export { NotificationButton, NotificationLabel, PopupNotificationWindow };
