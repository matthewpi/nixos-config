import { bind, GLib } from 'astal';
import { Astal, astalify, Gtk } from 'astal/gtk4';
import Notifd from 'gi://AstalNotifd';
import Pango from 'gi://Pango';

function fileExists(path: string) {
	return GLib.file_test(path, GLib.FileTest.EXISTS);
}

function time(time: number, format = '%H:%M') {
	return GLib.DateTime.new_from_unix_local(time).format(format)!;
}

function urgency(n: Notifd.Notification) {
	switch (n.urgency) {
		case Notifd.Urgency.LOW:
			return 'low';
		case Notifd.Urgency.CRITICAL:
			return 'critical';
		// case Notifd.Urgency.NORMAL:
		default:
			return 'normal';
	}
}

// type SeparatorProps = ConstructProps<Gtk.Separator, Gtk.Separator.ConstructorProps>;
const Separator = astalify<Gtk.Separator, Gtk.Separator.ConstructorProps>(Gtk.Separator, {});

function NotificationIcon({ notification }: { notification: Notifd.Notification }) {
	// if (notification.image) {
	// 	return <image iconName={bind(notification, 'image')} cssClasses={['app-icon']} />;
	// }

	if (notification.appIcon) {
		return <image iconName={bind(notification, 'appIcon')} cssClasses={['app-icon']} />;
	}

	if (notification.desktopEntry) {
		return <image iconName={bind(notification, 'desktopEntry')} cssClasses={['app-icon']} />;
	}

	return <image iconName="dialog-information-symbolic" cssClasses={['app-icon']} />;
}

interface NotificationProps {
	notification: Notifd.Notification;
	setup?(self: Astal.Box): void;
	onHoverLeave?(self: Astal.Box): void;
}

function Notification({ notification: n, ...props }: NotificationProps) {
	return (
		<box cssClasses={['notification', urgency(n)]} setup={props.setup} onHoverLeave={props.onHoverLeave}>
			<box vertical>
				<box cssClasses={['header']}>
					<NotificationIcon notification={n} />
					<label
						cssClasses={['app-name']}
						halign={Gtk.Align.START}
						label={n.appName || 'Unknown'}
						ellipsize={Pango.EllipsizeMode.END}
					/>
					<label cssClasses={['time']} hexpand halign={Gtk.Align.END} label={time(n.time)} />
					<button onClicked={() => n.dismiss()}>
						<image iconName="window-close-symbolic" />
					</button>
				</box>
				{/* @ts-expect-error go away */}
				<Separator visible />
				<box cssClasses={['content']}>
					{n.image && (
						<box vexpand={false} hexpand={false} valign={Gtk.Align.START} cssClasses={['image']}>
							{fileExists(n.image) ? (
								<image
									file={n.image}
									hexpand
									vexpand
									halign={Gtk.Align.CENTER}
									valign={Gtk.Align.CENTER}
								/>
							) : (
								<image
									iconName={n.image}
									hexpand
									vexpand
									halign={Gtk.Align.CENTER}
									valign={Gtk.Align.CENTER}
								/>
							)}
						</box>
					)}
					<box vertical>
						<label
							cssClasses={['summary']}
							halign={Gtk.Align.START}
							xalign={0}
							label={n.summary}
							ellipsize={Pango.EllipsizeMode.END}
						/>
						{n.body && (
							<label
								cssClasses={['body']}
								halign={Gtk.Align.START}
								xalign={0}
								wrap
								wrapMode={Pango.WrapMode.WORD_CHAR}
								maxWidthChars={80}
								useMarkup
								label={n.body}
								justify={Gtk.Justification.FILL}
							/>
						)}
					</box>
				</box>

				{bind(n, 'actions').as(actions => {
					if (actions.length < 1) {
						return;
					}

					return (
						<box cssClasses={['actions']}>
							{actions.map(({ label, id }) => (
								<button onClicked={() => n.invoke(id)} hexpand>
									<label label={label} halign={Gtk.Align.CENTER} hexpand />
								</button>
							))}
						</box>
					);
				})}
			</box>
		</box>
	);
}

export { Notification };
export type { NotificationProps };
