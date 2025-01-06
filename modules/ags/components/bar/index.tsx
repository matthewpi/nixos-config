import { bind, GLib, Variable } from 'astal';
import { Astal, astalify, Gdk, Gtk } from 'astal/gtk4';
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

// type DrawingAreaProps = ConstructProps<Gtk.DrawingArea, Gtk.DrawingArea.ConstructorProps>;
const DrawingArea = astalify<Gtk.DrawingArea, Gtk.DrawingArea.ConstructorProps>(Gtk.DrawingArea);

function Media() {
	const mpris = Mpris.get_default();

	// This hacky code allows us to only show one player.
	// TODO: how should we handle multiple players? The first player may not be
	// the one we want to display.
	return bind(mpris, 'players').as(players => {
		const player = players.slice(0, 1).map(player => <MediaPlayer player={player} />)?.[0];
		if (player === undefined) {
			return <NoPlayer />;
		}

		return player;
	});
}

function NoPlayer() {
	return (
		<button cssClasses={['media']}>
			<box valign={Gtk.Align.CENTER}>
				<box cssClasses={['media-label']} vertical homogeneous={false} valign={Gtk.Align.CENTER}>
					<label cssClasses={['nothing']} label="Nothing is playing" />
				</box>
			</box>
		</button>
	);
}

interface MediaPlayerProps {
	player: Mpris.Player;
}

function MediaPlayer({ player }: MediaPlayerProps) {
	const playIcon = bind(player, 'playbackStatus').as(s =>
		s === Mpris.PlaybackStatus.PLAYING ? 'media-playback-start-symbolic' : 'media-playback-pause-symbolic',
	);

	return (
		<button cssClasses={['media']} onClicked={() => player.play_pause()}>
			<box valign={Gtk.Align.CENTER}>
				<box cssClasses={['media-icon']}>
					<image iconName={playIcon} />
				</box>
				<box cssClasses={['media-label']} vertical homogeneous={false} valign={Gtk.Align.CENTER}>
					<label cssClasses={['media-title']} label={bind(player, 'title').as(l => l ?? '')} />
					<label cssClasses={['media-artists']} label={bind(player, 'artist').as(l => l ?? '')} />
				</box>
			</box>
		</button>
	);
}

interface WorkspacesProps {
	monitor?: string;
}

function Workspaces({ monitor }: WorkspacesProps) {
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
			components[i - 1] = (
				<Workspace hypr={hypr} id={i} w={hyprWorkspaces.find(w => w.id === i)} monitor={monitor} />
			);
		}

		return components;
	});

	return <box cssClasses={['workspaces']}>{workspaces}</box>;
}

interface WorkspaceProps {
	hypr: Hyprland.Hyprland;
	id: number;
	w?: Hyprland.Workspace;
	monitor?: string;
}

function Workspace({ hypr, id, w, monitor }: WorkspaceProps) {
	const size = 16;
	const thickness = 4;
	const radius = (size - thickness) / 2;

	function draw(self: Gtk.DrawingArea, cr: Cairo.Context, _width: number, _height: number): void {
		const fg = self.get_style_context().get_color();

		cr.setLineWidth(thickness);
		cr.setSourceRGBA(fg.red, fg.green, fg.blue, fg.alpha);
		cr.arc(size / 2, size / 2, radius, 0, 2 * Math.PI);
		cr.stroke();
	}

	// Using the focused workspace and local monitor, generate classes for the workspace.
	const fw = bind(hypr, 'focusedWorkspace');
	const hm = bind(hypr, 'monitors').as(monitors => monitors.find(m => m.name === monitor));
	const classes = Variable.derive([fw, hm], (fw, hm) => {
		return [
			w === undefined ? 'empty' : '',
			// Only a single workspace across all monitors can be focused.
			w === fw ? 'focused' : '',
			// Each monitor can have an active workspace, at least one workspace will be both active and focused.
			hm?.activeWorkspace?.id === id ? 'active' : '',
			w === undefined || monitor === undefined
				? ''
				: monitor === w.monitor.name
					? 'local-monitor'
					: 'other-monitor',
		].filter(v => typeof v === 'string' && v.length > 0);
	});

	return (
		<button
			cssClasses={bind(classes).as(classes => ['workspace', ...classes])}
			onClicked={() => w?.focus()}
			tooltipText={id.toString()}
		>
			{/* @ts-expect-error go away */}
			<DrawingArea
				cssClasses={bind(classes).as(classes => ['circle', ...classes])}
				halign={Gtk.Align.CENTER}
				valign={Gtk.Align.CENTER}
				widthRequest={size}
				heightRequest={size}
				setup={(self: Gtk.DrawingArea) => {
					// @ts-expect-error go away
					self.set_draw_func(draw);
				}}
			/>
		</button>
	);
}

function Clock() {
	return (
		<box cssClasses={['clock']}>
			<Time fn={() => GLib.DateTime.new_now_local()} />
			<Time fn={() => GLib.DateTime.new_now_utc()} />
		</box>
	);
}

function Time({ fn }: { fn: PollFn<GLib.DateTime | undefined> }) {
	const time = Variable<GLib.DateTime | undefined>(undefined).poll(1000, fn);

	return (
		<box cssClasses={['time-display']} onDestroy={() => time.drop()}>
			<label cssClasses={['time']} label={bind(time).as(time => time?.format('%H:%M:%S') ?? '')} />
			<label
				cssClasses={['timezone']}
				label={bind(time).as(time => ` ${time?.get_timezone_abbreviation() ?? ''}`)}
			/>
		</box>
	);
}

function SysTray() {
	const tray = Tray.get_default();

	return <box cssClasses={['systray']}>{bind(tray, 'items').as(items => items.map(TrayItem))}</box>;
}

function TrayItem(item: Tray.TrayItem) {
	return (
		<menubutton
			cssClasses={['systray-item']}
			tooltipMarkup={bind(item, 'tooltipMarkup')}
			menuModel={bind(item, 'menu_model')}
		>
			<image gicon={bind(item, 'gicon')} />
		</menubutton>
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
				cssClasses={['bluetooth']}
				tooltipText={bind(adapter, 'name').as(String)}
				onClicked={() => {
					bluetooth.toggle();
				}}
				// onClickRelease={(_, event) => {
				// 	switch (event.button) {
				// 		case Astal.MouseButton.PRIMARY:
				// 			// TODO: Open Overskride?
				// 			break;
				// 		case Astal.MouseButton.SECONDARY:
				// 			bluetooth.toggle();
				// 			break;
				// 	}
				// }}
			>
				<image
					iconName={bind(bluetooth, 'is_powered').as(powered =>
						powered ? 'bluetooth-active-symbolic' : 'bluetooth-disabled-symbolic',
					)}
				/>
			</button>
		</box>
	);
}

function BatteryLevel() {
	const battery = Battery.get_default();
	const percentageText = bind(battery, 'percentage').as(p => `${Math.floor(p * 100)}%`);

	return (
		<box visible={bind(battery, 'isPresent')} cssClasses={['battery']} tooltipText={percentageText}>
			<image iconName={bind(battery, 'batteryIconName')} />
			{/* <label label={percentageText} /> */}
		</box>
	);
}

function VolumeIndicator() {
	const wireplumber = Wireplumber.get_default();

	const speaker = wireplumber?.audio.defaultSpeaker!;
	const scrollRevealed = Variable(false);

	return (
		<box
			cssClasses={['volume']}
			tooltipText={bind(speaker, 'volume').as(p => `${Math.floor(p * 100)}%`)}
			onHoverEnter={() => scrollRevealed.set(true)}
			onHoverLeave={() => scrollRevealed.set(false)}
			onDestroy={() => scrollRevealed.drop()}
		>
			<box>
				<button
					onClicked={() => {
						speaker.mute = !speaker.mute;
					}}
				>
					<image iconName={bind(speaker, 'volumeIcon')} />
				</button>

				<revealer
					revealChild={scrollRevealed()}
					transitionType={Gtk.RevealerTransitionType.SLIDE_LEFT}
					valign={Gtk.Align.CENTER}
				>
					<slider
						cssClasses={['volume-slider']}
						onChangeValue={self => (speaker.volume = self.value)}
						value={bind(speaker, 'volume')}
						hexpand
					/>
				</revealer>
			</box>
		</box>
	);
}

function Bar(monitor: Gdk.Monitor) {
	return (
		<window
			cssClasses={['bar']}
			gdkmonitor={monitor}
			anchor={Astal.WindowAnchor.TOP | Astal.WindowAnchor.LEFT | Astal.WindowAnchor.RIGHT}
			exclusivity={Astal.Exclusivity.EXCLUSIVE}
			visible
		>
			<centerbox>
				<box hexpand halign={Gtk.Align.START}>
					{/* @ts-expect-error Media returns `Binding<Gtk.Widget>` instead of just `Gtk.Widget`, which still works perfectly fine */}
					<Media />
					{/* NOTE: for anyone wondering, `get_connector` is only available in Gtk4 */}
					<Workspaces monitor={monitor.get_connector() ?? ''} />
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

export { Bar };
