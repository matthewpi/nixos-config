import { bind, GLib, Variable } from 'astal';
import { App, Astal, Gdk, Gtk } from 'astal/gtk3';
import Cairo from 'cairo';
import Battery from 'gi://AstalBattery';
import Bluetooth from 'gi://AstalBluetooth';
import Hyprland from 'gi://AstalHyprland';
// import IWD from 'gi://AstalIWD';
import Mpris from 'gi://AstalMpris';
// import Networkd from 'gi://AstalNetworkd';
import Tray from 'gi://AstalTray';
import Wireplumber from 'gi://AstalWp';

type PollFn<T> = (prev: T) => T | Promise<T>;

function Media({ player }: { player: Mpris.Player }) {
	const playIcon = bind(player, 'playbackStatus').as(s =>
		s === Mpris.PlaybackStatus.PLAYING ? 'media-playback-start-symbolic' : 'media-playback-pause-symbolic',
	);

	return (
		<button
			className="media"
			onClickRelease={(_, event) => {
				switch (event.button) {
					case Astal.MouseButton.PRIMARY:
						player.play_pause();
						break;
				}
			}}
		>
			<box valign={Gtk.Align.CENTER}>
				<box className="media-icon">
					<icon icon={playIcon} iconSize={20} />
				</box>
				<box className="media-label" vertical homogeneous={false} valign={Gtk.Align.CENTER}>
					<label className="media-title" label={bind(player, 'title')} />
					<label className="media-artists" label={bind(player, 'artist')} />
				</box>
			</box>
		</button>
	);
}

function Workspaces() {
	const hypr = Hyprland.get_default();

	const workspaces = bind(hypr, 'workspaces').as(workspaces => {
		const hyprWorkspaces = workspaces
			// Filter for normal workspaces.
			.filter(w => w.id > 0)
			// Sort workspaces in order of ID.
			.sort((a, b) => a.id - b.id);

		// Map the workspaces to components.
		const components: Gtk.Widget[] = [];
		components.length = 10;
		for (let i = 1; i <= components.length; i++) {
			components[i - 1] = Workspace(
				hypr,
				i,
				hyprWorkspaces.find(w => w.id === i),
			);
		}

		return components;
	});

	return <box className="workspaces">{workspaces}</box>;
}

/**
 * TODO: monitor indicator (change color depending on if the workspace is on the local monitor or not)
 */
function Workspace(hypr: Hyprland.Hyprland, id: number, w?: Hyprland.Workspace) {
	const size = 16;
	const thickness = 4;
	const radius = (size - thickness) / 2;

	return (
		<button
			className={bind(hypr, 'focusedWorkspace').as(fw =>
				['workspace', w === undefined ? 'empty' : w === fw ? 'focused' : '']
					.filter(v => typeof v === 'string' && v.length > 0)
					.join(' '),
			)}
			onClicked={() => w?.focus()}
			tooltipText={id.toString()}
		>
			<drawingarea
				className={bind(hypr, 'focusedWorkspace').as(fw =>
					['circle', w === undefined ? 'empty' : w === fw ? 'focused' : '']
						.filter(v => typeof v === 'string' && v.length > 0)
						.join(' '),
				)}
				halign={Gtk.Align.CENTER}
				valign={Gtk.Align.CENTER}
				widthRequest={size}
				heightRequest={size}
				// @ts-expect-error go away
				onDraw={(self: Gtk.DrawingArea, cr: Cairo.Context) => {
					const fg = self.get_style_context().get_property('color', Gtk.StateFlags.NORMAL) as Gdk.RGBA;

					cr.setLineWidth(thickness);
					cr.setSourceRGBA(fg.red, fg.green, fg.blue, fg.alpha);
					cr.arc(size / 2, size / 2, radius, 0, 2 * Math.PI);
					cr.stroke();
				}}
			/>
		</button>
	);
}

function Clock() {
	return (
		<box className="clock">
			<Time />
			<Time fn={() => GLib.DateTime.new_now_utc()} />
		</box>
	);
}

function Time({ fn }: { fn?: PollFn<GLib.DateTime | undefined> }) {
	if (fn === undefined) {
		fn = () => GLib.DateTime.new_now_local();
	}

	const time = Variable<GLib.DateTime | undefined>(undefined).poll(1000, fn);

	return (
		<box className="time-display" onDestroy={() => time.drop()}>
			<label className="time" label={bind(time).as(time => time?.format('%H:%M:%S') ?? '')} />
			<label className="timezone" label={bind(time).as(time => ` ${time?.get_timezone_abbreviation() ?? ''}`)} />
		</box>
	);
}

function SysTray() {
	const tray = Tray.get_default();

	return <box>{bind(tray, 'items').as(items => items.map(TrayItem))}</box>;
}

function TrayItem(item: Tray.TrayItem) {
	if (item.iconThemePath) {
		App.add_icons(item.iconThemePath);
	}

	const menu = item.create_menu();

	return (
		<button
			tooltipMarkup={bind(item, 'tooltipMarkup')}
			onDestroy={() => menu?.destroy()}
			onClickRelease={(self, event) => {
				switch (event.button) {
					case Astal.MouseButton.PRIMARY:
						menu?.activate();
						break;
					case Astal.MouseButton.SECONDARY:
						menu?.popup_at_widget(self, Gdk.Gravity.SOUTH, Gdk.Gravity.NORTH, null);
						break;
				}
			}}
		>
			<icon gIcon={bind(item, 'gicon')} />
		</button>
	);
}

// function NetworkIndicator() {
// 	const networkd = Networkd.get_default();
//
// 	return (
// 		<label
// 			label={bind(networkd, 'links').as(links => {
// 				return links
// 					.map(link => {
// 						const data = JSON.parse(link.describe());
// 						console.log(data.Name);
//
// 						return data.Name;
// 					})
// 					.join(', ');
// 			})}
// 		/>
// 	);
// }

// function WirelessIndicator() {
// 	const iwd = IWD.get_default();
//
// 	return (
// 		<label
// 			label="Wi-Fi"
// 		/>
// 	);
// }

function BluetoothIndicator() {
	const bluetooth = Bluetooth.get_default();

	const adapter = bluetooth.adapter;

	return (
		<box>
			<button
				className="bluetooth"
				tooltipText={bind(adapter, 'name').as(String)}
				onClickRelease={(_, event) => {
					switch (event.button) {
						case Astal.MouseButton.PRIMARY:
							App.get_window('bluetooth')?.show();
							break;
						case Astal.MouseButton.SECONDARY:
							// bluetooth.toggle();
							break;
					}
				}}
			>
				<icon
					icon={bind(bluetooth, 'is_powered').as(powered =>
						powered ? 'bluetooth-active-symbolic' : 'bluetooth-disabled-symbolic',
					)}
				/>
			</button>
		</box>
	);
}

function BluetoothWindow() {
	return (
		<window
			// `name` must go before `application`.
			name="bluetooth"
			application={App}
			anchor={Astal.WindowAnchor.TOP | Astal.WindowAnchor.RIGHT}
			marginTop={36}
			marginRight={36}
			exclusivity={Astal.Exclusivity.IGNORE}
			// Required for `onKeyPressEvent` to work.
			keymode={Astal.Keymode.ON_DEMAND}
			onKeyPressEvent={(self, event) => {
				if (event.get_keyval()[1] === Gdk.KEY_Escape) {
					self.hide();
				}
			}}
		>
			<label label="Hello, world!" />
		</window>
	);
}

function BatteryLevel() {
	const battery = Battery.get_default();
	const percentageText = bind(battery, 'percentage').as(p => `${Math.floor(p * 100)}%`);

	return (
		<box visible={bind(battery, 'isPresent')} className="battery" tooltipText={percentageText}>
			<icon icon={bind(battery, 'batteryIconName')} />
			{/* <label label={percentageText} /> */}
		</box>
	);
}

function VolumeIndicator() {
	const wireplumber = Wireplumber.get_default();

	const speaker = wireplumber?.audio.defaultSpeaker!;
	const scrollRevealed = Variable(false);

	return (
		<eventbox
			className="volume"
			tooltipText={bind(speaker, 'volume').as(p => `${Math.floor(p * 100)}%`)}
			onHover={() => scrollRevealed.set(true)}
			onHoverLost={() => scrollRevealed.set(false)}
			onDestroy={() => scrollRevealed.drop()}
		>
			<box>
				<button
					onClickRelease={(_, event) => {
						switch (event.button) {
							case Astal.MouseButton.PRIMARY:
								speaker.mute = !speaker.mute;
								break;
							case Astal.MouseButton.SECONDARY:
								// TODO: open output selection menu
								break;
						}
					}}
				>
					<icon icon={bind(speaker, 'volumeIcon')} />
				</button>

				<revealer
					revealChild={scrollRevealed()}
					transitionType={Gtk.RevealerTransitionType.SLIDE_LEFT}
					valign={Gtk.Align.CENTER}
				>
					<slider
						className="volume-slider"
						onDragged={self => (speaker.volume = self.value)}
						value={bind(speaker, 'volume')}
						hexpand
					/>
				</revealer>
			</box>
		</eventbox>
	);
}

function Bar(monitor: Gdk.Monitor) {
	const mpris = Mpris.get_default();

	const player = mpris.get_players()?.[0] ?? undefined;

	return (
		<window
			className="bar"
			gdkmonitor={monitor}
			anchor={Astal.WindowAnchor.TOP | Astal.WindowAnchor.LEFT | Astal.WindowAnchor.RIGHT}
			exclusivity={Astal.Exclusivity.EXCLUSIVE}
		>
			<centerbox>
				<box hexpand halign={Gtk.Align.START}>
					{player && <Media player={player} />}
					<Workspaces />
				</box>

				<box>
					<Clock />
				</box>

				<box hexpand halign={Gtk.Align.END}>
					<SysTray />
					{/* <WirelessIndicator /> */}
					{/* <NetworkIndicator /> */}
					<BluetoothIndicator />
					<VolumeIndicator />
					<BatteryLevel />
				</box>
			</centerbox>
		</window>
	);
}

export { Bar, BluetoothWindow };
