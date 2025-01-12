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
			v.unparent();
		}

		this.#map.delete(key);
	}

	delete(key: K): void {
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

class NotificationMap extends VarMap<number, Gtk.Widget> {
	#notifd = Notifd.get_default();

	constructor() {
		super();

		/**
		 * uncomment this if you want to
		 * ignore timeout by senders and enforce our own timeout
		 * note that if the notification has any actions
		 * they might not work, since the sender already treats them as resolved
		 */
		// Ignore timeouts set by notification senders so we can enforce our own
		this.#notifd.ignoreTimeout = true;

		this.#notifd.connect('notified', (_, id) => {
			this.set(
				id,
				Notification({
					notification: this.#notifd.get_notification(id),
					// Remove the notification after the timeout has passed.
					setup: () => timeout(TIMEOUT_DELAY, () => this.delete(id)),
					// onHoverLeave: () => this.delete(id).
				}),
			);
		});

		// notifications can be closed by the outside before
		// any user input, which have to be handled too
		this.#notifd.connect('resolved', (_, id) => {
			this.delete(id);
		});
	}

	override set(key: number, value: Gtk.Widget): void {
		super.set(key, value);

		// If a notification was added, ensure the window is visible.
		const window = App.get_window('notifications') ?? undefined;
		if (window !== undefined && !window.visible) {
			window.show();
		}
	}

	override delete(id: number): void {
		super.delete(id);

		// If all notifications have been removed, hide the window.
		const window = App.get_window('notifications') ?? undefined;
		if (window !== undefined && this.get().length < 1) {
			window.hide();
		}
	}
}

function NotificationsWindow() {
	const notifications = new NotificationMap();

	return (
		<window
			// `name` must go before `application`.
			name="notifications"
			application={App}
			cssClasses={['notifications']}
			exclusivity={Astal.Exclusivity.EXCLUSIVE}
			anchor={Astal.WindowAnchor.TOP | Astal.WindowAnchor.RIGHT}
		>
			<box vertical>{bind(notifications)}</box>
		</window>
	);
}

export { NotificationsWindow };
