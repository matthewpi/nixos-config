import { createState, For, onCleanup } from 'ags';

import Astal from 'gi://Astal?version=4.0';
import AstalNotifd from 'gi://AstalNotifd?version=0.1';
import Gtk from 'gi://Gtk?version=4.0';

import { Notification } from './Notification';

function Notifications() {
	const notifd = AstalNotifd.get_default();

	const [notifications, setNotifications] = createState(new Array<AstalNotifd.Notification>());

	const notifiedHandler = notifd.connect('notified', (_, id, replaced) => {
		const notification = notifd.get_notification(id);

		if (replaced && notifications.get().some(n => n.id === id)) {
			setNotifications(ns => ns.map(n => (n.id === id ? notification : n)));
			return;
		}

		setNotifications(ns => [notification, ...ns]);
	});

	const resolvedHandler = notifd.connect('resolved', (_, id) => {
		setNotifications(ns => ns.filter(n => n.id !== id));
	});

	// technically, we don't need to cleanup because in this example this is a root component
	// and this cleanup function is only called when the program exits, but exiting will cleanup either way
	// but it's here to remind you that you should not forget to cleanup signal connections
	onCleanup(() => {
		notifd.disconnect(notifiedHandler);
		notifd.disconnect(resolvedHandler);
	});

	return (
		<window
			name="notifications"
			cssClasses={['notifications']}
			visible={notifications(ns => ns.length > 0)}
			anchor={Astal.WindowAnchor.TOP | Astal.WindowAnchor.RIGHT}
		>
			<box orientation={Gtk.Orientation.VERTICAL}>
				<For each={notifications}>{notification => <Notification n={notification} />}</For>
			</box>
		</window>
	);
}

export { Notifications };
