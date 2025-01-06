import { GLib } from 'astal';
import { Astal, astalify, Gtk } from 'astal/gtk4';
import Notifd from 'gi://AstalNotifd';

function isIcon(_icon: string): boolean {
	// TODO: fix after Gtk4 update.
	// return !!Astal.Icon.lookup_icon(icon);
	return true;
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
	setup(self: Astal.Box): void;
	onHoverLeave(self: Astal.Box): void;
	notification: Notifd.Notification;
}

// type SeparatorProps = ConstructProps<Gtk.Separator, Gtk.Separator.ConstructorProps>;
const Separator = astalify<Gtk.Separator, Gtk.Separator.ConstructorProps>(Gtk.Separator, {});

function Notification(props: NotificationProps) {
	const { notification: n, onHoverLeave, setup } = props;

	return (
		<box cssClasses={['notification', urgency(n)]} setup={setup} onHoverLeave={onHoverLeave}>
			<box vertical>
				<box cssClasses={['header']}>
					<image
						cssClasses={['app-icon']}
						visible={Boolean(n.appIcon || n.desktopEntry)}
						iconName={n.appIcon || n.desktopEntry}
					/>
					{/* TODO: truncate? */}
					<label cssClasses={['app-name']} halign={Gtk.Align.START} label={n.appName || 'Unknown'} />
					<label cssClasses={['time']} hexpand halign={Gtk.Align.END} label={time(n.time)} />
					<button onClicked={() => n.dismiss()}>
						<image iconName="window-close-symbolic" />
					</button>
				</box>
				{/* @ts-expect-error go away */}
				<Separator visible />
				<box cssClasses={['content']}>
					{n.image && fileExists(n.image) && (
						<box
							valign={Gtk.Align.START}
							cssClasses={['image']}
							// TODO: does the `css` property still work?
							// css={`
							// 	background-image: url('${n.image}');
							// `}
						/>
					)}
					{n.image && isIcon(n.image) && (
						<box vexpand={false} hexpand={false} valign={Gtk.Align.START} cssClasses={['icon-image']}>
							<image
								iconName={n.image}
								hexpand
								vexpand
								halign={Gtk.Align.CENTER}
								valign={Gtk.Align.CENTER}
							/>
						</box>
					)}
					<box vertical>
						{/* TODO: truncate? */}
						<label cssClasses={['summary']} halign={Gtk.Align.START} xalign={0} label={n.summary} />
						{n.body && (
							// TOOD: justifyFill?
							<label
								cssClasses={['body']}
								wrap
								useMarkup
								halign={Gtk.Align.START}
								xalign={0}
								// justifyFill
								label={n.body}
							/>
						)}
					</box>
				</box>
				{n.get_actions().length > 0 && (
					<box cssClasses={['actions']}>
						{n.get_actions().map(({ label, id }) => (
							<button hexpand onClicked={() => n.invoke(id)}>
								<label label={label} halign={Gtk.Align.CENTER} hexpand />
							</button>
						))}
					</box>
				)}
			</box>
		</box>
	);
}

export { Notification };
export type { NotificationProps };
