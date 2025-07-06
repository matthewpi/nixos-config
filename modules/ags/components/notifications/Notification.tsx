import Adw from 'gi://Adw';
import AstalNotifd from 'gi://AstalNotifd?version=0.1';
import GLib from 'gi://GLib?version=2.0';
import Gtk from 'gi://Gtk?version=4.0';
import Pango from 'gi://Pango?version=1.0';

function fileExists(path: string) {
	return GLib.file_test(path, GLib.FileTest.EXISTS);
}

function time(time: number, format = '%H:%M') {
	return GLib.DateTime.new_from_unix_local(time).format(format)!;
}

function urgency(n: AstalNotifd.Notification) {
	switch (n.urgency) {
		case AstalNotifd.Urgency.LOW:
			return 'low';
		case AstalNotifd.Urgency.CRITICAL:
			return 'critical';
		default:
			return 'normal';
	}
}

interface NotificationProps {
	n: AstalNotifd.Notification;
	onHoverLost?: () => void;
}

function Notification({ n, onHoverLost }: NotificationProps) {
	return (
		<Adw.Clamp maximumSize={400}>
			<box cssClasses={['notification', urgency(n)]} widthRequest={400}>
				<Gtk.EventControllerMotion onLeave={onHoverLost} />

				<box orientation={Gtk.Orientation.VERTICAL}>
					<box cssClasses={['header']}>
						<image
							iconName={n.appIcon || n.desktopEntry || 'dialog-information-symbolic'}
							cssClasses={['app-icon']}
						/>
						<label
							cssClasses={['app-name']}
							halign={Gtk.Align.START}
							ellipsize={Pango.EllipsizeMode.END}
							label={n.appName || 'Unknown'}
						/>
						<label
							cssClasses={['time']}
							halign={Gtk.Align.END}
							ellipsize={Pango.EllipsizeMode.END}
							label={time(n.time)}
							hexpand
						/>
						<button onClicked={() => n.dismiss()}>
							<image iconName="window-close-symbolic" />
						</button>
					</box>

					<Gtk.Separator visible />

					<box cssClasses={['content']}>
						{n.image && (
							<box cssClasses={['image']} valign={Gtk.Align.START}>
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

						<box orientation={Gtk.Orientation.VERTICAL}>
							<label
								cssClasses={['summary']}
								halign={Gtk.Align.START}
								xalign={0}
								ellipsize={Pango.EllipsizeMode.END}
								label={n.summary}
							/>
							{n.body && (
								<label
									cssClasses={['body']}
									halign={Gtk.Align.START}
									xalign={0}
									justify={Gtk.Justification.FILL}
									useMarkup
									wrap
									label={n.body}
								/>
							)}
						</box>
					</box>

					{n.actions.length > 0 && (
						<box cssClasses={['actions']}>
							{n.actions.map(({ label, id }) => (
								<button onClicked={() => n.invoke(id)} hexpand>
									<label halign={Gtk.Align.CENTER} hexpand label={label} />
								</button>
							))}
						</box>
					)}
				</box>
			</box>
		</Adw.Clamp>
	);
}

export { Notification };
export type { NotificationProps };
