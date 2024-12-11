import { GLib } from 'astal';
import { Astal, Gtk } from 'astal/gtk3';
import type { EventBox } from 'astal/gtk3/widget';
import Notifd from 'gi://AstalNotifd';

function isIcon(icon: string) {
	return !!Astal.Icon.lookup_icon(icon);
}

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

interface NotificationProps {
	setup(self: EventBox): void;
	onHoverLost(self: EventBox): void;
	notification: Notifd.Notification;
}

function Notification(props: NotificationProps) {
	const { notification: n, onHoverLost, setup } = props;

	return (
		<eventbox className={`notification ${urgency(n)}`} setup={setup} onHoverLost={onHoverLost}>
			<box vertical>
				<box className="header">
					{(n.appIcon || n.desktopEntry) && (
						<icon
							className="app-icon"
							visible={Boolean(n.appIcon || n.desktopEntry)}
							icon={n.appIcon || n.desktopEntry}
						/>
					)}
					<label className="app-name" halign={Gtk.Align.START} truncate label={n.appName || 'Unknown'} />
					<label className="time" hexpand halign={Gtk.Align.END} label={time(n.time)} />
					<button onClicked={() => n.dismiss()}>
						<icon icon="window-close-symbolic" />
					</button>
				</box>
				<Gtk.Separator visible />
				<box className="content">
					{n.image && fileExists(n.image) && (
						<box
							valign={Gtk.Align.START}
							className="image"
							css={`
								background-image: url('${n.image}');
							`}
						/>
					)}
					{n.image && isIcon(n.image) && (
						<box expand={false} valign={Gtk.Align.START} className="icon-image">
							<icon icon={n.image} expand halign={Gtk.Align.CENTER} valign={Gtk.Align.CENTER} />
						</box>
					)}
					<box vertical>
						<label className="summary" halign={Gtk.Align.START} xalign={0} label={n.summary} truncate />
						{n.body && (
							<label
								className="body"
								wrap
								useMarkup
								halign={Gtk.Align.START}
								xalign={0}
								justifyFill
								label={n.body}
							/>
						)}
					</box>
				</box>
				{n.get_actions().length > 0 && (
					<box className="actions">
						{n.get_actions().map(({ label, id }) => (
							<button hexpand onClicked={() => n.invoke(id)}>
								<label label={label} halign={Gtk.Align.CENTER} hexpand />
							</button>
						))}
					</box>
				)}
			</box>
		</eventbox>
	);
}

export { Notification };
export type { NotificationProps };
