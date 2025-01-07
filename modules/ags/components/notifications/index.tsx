import { bind, timeout } from 'astal';
import type { Subscribable } from 'astal/binding';
import { App, Astal, Gtk } from 'astal/gtk4';
import Notifd from 'gi://AstalNotifd';

import { Notification } from './Notification';

// see comment below in constructor
const TIMEOUT_DELAY = 5000;

// https://aylur.github.io/astal/guide/typescript/binding#example-custom-subscribable
export class VarMap<K, T = Gtk.Widget> implements Subscribable {
	#subs = new Set<(v: Array<[K, T]>) => void>();
	#map: Map<K, T>;

	constructor(initial?: Iterable<[K, T]>) {
		this.#map = new Map(initial);
	}

	get(): [K, T][] {
		return [...this.#map.entries()];
	}

	set(key: K, value: T): void {
		this.#delete(key);
		this.#map.set(key, value);
		this.#notify();
	}

	#delete(key: K): void {
		const v = this.#map.get(key);

		if (v instanceof Gtk.Widget) {
			// v.unparent();
			// v.run_dispose();
			// v.emit('destroy');
		}

		this.#map.delete(key);
	}

	delete(key: K): void {
		console.log('delete', key);
		this.#delete(key);
		this.#notify();
	}

	subscribe(callback: (v: Array<[K, T]>) => void): () => boolean {
		this.#subs.add(callback);
		return () => this.#subs.delete(callback);
	}

	#notify(): void {
		const value = this.get();
		for (const sub of this.#subs) {
			sub(value);
		}
	}
}

class NotificationMap extends VarMap<number> {
	constructor() {
		super();

		const notifd = Notifd.get_default();

		/**
		 * uncomment this if you want to
		 * ignore timeout by senders and enforce our own timeout
		 * note that if the notification has any actions
		 * they might not work, since the sender already treats them as resolved
		 */
		// notifd.ignoreTimeout = true;

		notifd.connect('notified', (_, id) => {
			this.set(
				id,
				Notification({
					notification: notifd.get_notification(id),

					// once hovering over the notification is done
					// destroy the widget without calling notification.dismiss()
					// so that it acts as a "popup" and we can still display it
					// in a notification center like widget
					// but clicking on the close button will close it
					onHoverLeave: () => {}, // this.delete(id)

					// notifd by default does not close notifications
					// until user input or the timeout specified by sender
					// which we set to ignore above
					setup: () => timeout(TIMEOUT_DELAY, () => this.delete(id)),
				}),
			);
		});

		// notifications can be closed by the outside before
		// any user input, which have to be handled too
		notifd.connect('resolved', (_, id) => {
			this.delete(id);
		});
	}
}

function NotificationPopups() {
	const notifications = new NotificationMap();

	return (
		<window
			// `name` must go before `application`.
			name="notifications"
			application={App}
			cssClasses={['notifications']}
			exclusivity={Astal.Exclusivity.EXCLUSIVE}
			anchor={Astal.WindowAnchor.TOP | Astal.WindowAnchor.RIGHT}
			visible
		>
			<box vertical>{bind(notifications)}</box>
		</window>
	);
}

export { NotificationPopups };
