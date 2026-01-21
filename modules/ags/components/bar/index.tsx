import { createBinding, createComputed, For, With } from 'ags';
import app from 'ags/gtk4/app';
import { execAsync } from 'ags/process';
import { createPoll } from 'ags/time';
import Cairo from 'cairo';
import Astal from 'gi://Astal?version=4.0';
import AstalBattery from 'gi://AstalBattery?version=0.1';
import AstalBluetooth from 'gi://AstalBluetooth?version=0.1';
import AstalHyprland from 'gi://AstalHyprland?version=0.1';
import AstalMpris from 'gi://AstalMpris?version=0.1';
import AstalNotifd from 'gi://AstalNotifd?version=0.1';
import AstalPowerProfiles from 'gi://AstalPowerProfiles?version=0.1';
import AstalTray from 'gi://AstalTray?version=0.1';
import AstalWp from 'gi://AstalWp?version=0.1';
import Gdk from 'gi://Gdk?version=4.0';
import Gio from 'gi://Gio?version=2.0';
import GLib from 'gi://GLib?version=2.0';
import Gtk from 'gi://Gtk?version=4.0';

type PollFn<T> = (prev: T) => T | Promise<T>;

// TODO: find a better way to show all players, ideally allowing the user to
// pin one for quick-access.
function Media() {
	const mpris = AstalMpris.get_default();

	const player = createBinding(mpris, 'players').as(players => {
		if (players.length < 1) {
			return undefined;
		}

		return players.find(p => p.playbackStatus === AstalMpris.PlaybackStatus.PLAYING) ?? players[0];
	});

	return (
		<box cssClasses={['media']}>
			<With value={player}>
				{player => (
					<button cssClasses={['media-button']} onClicked={() => player?.play_pause()}>
						{player === undefined ? (
							<box valign={Gtk.Align.CENTER}>
								<box
									cssClasses={['media-label']}
									homogeneous={false}
									valign={Gtk.Align.CENTER}
									orientation={Gtk.Orientation.VERTICAL}
								>
									<label cssClasses={['nothing']} label="Nothing is playing" />
								</box>
							</box>
						) : (
							<box valign={Gtk.Align.CENTER}>
								<box cssClasses={['media-icon']}>
									<image
										iconName={createBinding(player, 'playbackStatus').as(s =>
											s === AstalMpris.PlaybackStatus.PLAYING
												? 'media-playback-start-symbolic'
												: 'media-playback-pause-symbolic',
										)}
									/>
								</box>
								<box
									cssClasses={['media-label']}
									homogeneous={false}
									valign={Gtk.Align.CENTER}
									orientation={Gtk.Orientation.VERTICAL}
								>
									<label
										cssClasses={['media-title']}
										label={createBinding(player, 'title').as(l => l ?? '')}
									/>
									<label
										cssClasses={['media-artists']}
										label={createBinding(player, 'artist').as(l => l ?? '')}
									/>
								</box>
							</box>
						)}
					</button>
				)}
			</With>
		</box>
	);
}

function Workspaces({ monitor }: { monitor?: string }) {
	const hypr = AstalHyprland.get_default();

	const workspaces = createBinding(hypr, 'workspaces').as(w => {
		const hw = w
			// Filter for normal workspaces.
			.filter(w => w.id > 0)
			// Sort workspaces in order of ID.
			.sort((a, b) => a.id - b.id);

		const workspaces: { id: number; w?: AstalHyprland.Workspace }[] = [];
		workspaces.length = 10;
		for (let i = 1; i <= workspaces.length; i++) {
			workspaces[i - 1] = {
				id: i,
				w: hw.find(w => w.id === i),
			};
		}
		return workspaces;
	});

	return (
		<box cssClasses={['workspaces']}>
			<For each={workspaces}>{({ id, w }) => <Workspace hypr={hypr} id={id} monitor={monitor} w={w} />}</For>
		</box>
	);
}

interface WorkspaceProps {
	hypr: AstalHyprland.Hyprland;
	id: number;
	monitor?: string;
	w?: AstalHyprland.Workspace;
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
	const fw = createBinding(hypr, 'focusedWorkspace');
	const hm = createBinding(hypr, 'monitors').as(monitors => monitors.find(m => m.name === monitor));
	const classes = createComputed(() =>
		[
			w === undefined ? 'empty' : '',
			// Only a single workspace across all monitors can be focused.
			w === fw() ? 'focused' : '',
			// Each monitor can have an active workspace, at least one workspace will be both active and focused.
			hm()?.activeWorkspace?.id === id ? 'active' : '',
			w === undefined || monitor === undefined
				? ''
				: monitor === w.monitor.name
					? 'local-monitor'
					: 'other-monitor',
		].filter(v => typeof v === 'string' && v.length > 0),
	);

	return (
		<button
			cssClasses={classes(classes => ['workspace', ...classes])}
			onClicked={() => w?.focus()}
			tooltipText={id.toString()}
		>
			<Gtk.DrawingArea
				$={self => self.set_draw_func(draw)}
				cssClasses={classes(classes => ['circle', ...classes])}
				halign={Gtk.Align.CENTER}
				valign={Gtk.Align.CENTER}
				widthRequest={size}
				heightRequest={size}
			/>
		</button>
	);
}

function Clock() {
	return (
		<menubutton cssClasses={['clock']}>
			<box spacing={16}>
				<Time fn={() => GLib.DateTime.new_now_local()} />
				<Time fn={() => GLib.DateTime.new_now_utc()} />
			</box>

			<popover>
				<Gtk.Calendar />
			</popover>
		</menubutton>
	);
}

function Time({ fn }: { fn: PollFn<GLib.DateTime | undefined> }) {
	const time = createPoll<GLib.DateTime | undefined>(undefined, 1000, fn);

	return (
		<box cssClasses={['time-display']}>
			<label cssClasses={['time']} label={time(time => time?.format('%H:%M:%S') ?? '')} />
			<label cssClasses={['timezone']} label={time(time => ` ${time?.get_timezone_abbreviation() ?? ''}`)} />
		</box>
	);
}

function SysTray() {
	const tray = AstalTray.get_default();
	// TODO: item sorting.
	const items = createBinding(tray, 'items');

	function init(btn: Gtk.MenuButton, item: AstalTray.TrayItem): void {
		btn.menuModel = item.menuModel;
		btn.insert_action_group('dbusmenu', item.actionGroup);
		item.connect('notify::action-group', () => {
			btn.insert_action_group('dbusmenu', item.actionGroup);
		});
	}

	return (
		<box cssClasses={['systray']}>
			<For each={items}>
				{item => (
					<menubutton
						$={self => init(self, item)}
						cssClasses={['systray-item']}
						tooltipMarkup={createBinding(item, 'tooltipMarkup')}
					>
						<image gicon={createBinding(item, 'gicon')} />
					</menubutton>
				)}
			</For>
		</box>
	);
}

function BluetoothIndicator() {
	const bluetooth = AstalBluetooth.get_default();
	const adapter = bluetooth.adapter;

	return (
		<menubutton cssClasses={['bluetooth']} tooltipText={createBinding(adapter, 'name')}>
			<image
				iconName={createBinding(bluetooth, 'is_powered').as(powered =>
					powered ? 'bluetooth-active-symbolic' : 'bluetooth-disabled-symbolic',
				)}
			/>

			<popover>
				<box>
					{/* TODO: bluetooth control */}
					<label label="Hello, world!" />
				</box>
			</popover>
		</menubutton>
	);
}

function BatteryLevel() {
	const battery = AstalBattery.get_default();
	const powerProfiles = AstalPowerProfiles.get_default();
	const percentageText = createBinding(battery, 'percentage').as(p => `${Math.floor(p * 100)}%`);

	const batteryIconName = createBinding(battery, 'iconName');
	const profileIconName = createBinding(powerProfiles, 'iconName');
	const iconName = createComputed(() => {
		const bIconName = batteryIconName();
		// If the device has a battery, show that icon instead.
		if (bIconName !== 'battery-missing-symbolic') {
			return bIconName;
		}

		const pIconName = profileIconName();
		// If the device has a power profile, show that icon instead.
		if (pIconName !== 'power-profile-') {
			return pIconName;
		}

		// Show a balanced power profile icon otherwise.
		return 'power-profile-balanced-symbolic';
	});

	return (
		<menubutton cssClasses={['battery']}>
			<box tooltipText={percentageText}>
				<image iconName={iconName} />
				{/* <label label={percentageText} /> */}
			</box>

			<popover>
				<box orientation={Gtk.Orientation.VERTICAL}>
					{/* TODO: placeholder if the system has no power profiles */}

					{/* TODO: active styling */}
					{powerProfiles.get_profiles().map(({ profile }) => (
						<button onClicked={() => powerProfiles.set_active_profile(profile)}>
							<label label={profile} xalign={0} />
						</button>
					))}
				</box>
			</popover>
		</menubutton>
	);
}

function NotificationsIndicator() {
	const notifd = AstalNotifd.get_default();

	return (
		<box>
			<button
				cssClasses={['notification-indicator']}
				onClicked={() => (notifd.dontDisturb = !notifd.dontDisturb)}
			>
				<image
					iconName={createBinding(notifd, 'dontDisturb').as(dnd =>
						dnd ? 'notifications-disabled-symbolic' : 'user-available-symbolic',
					)}
				/>
			</button>
		</box>
	);
}

function VolumeIndicator() {
	const wireplumber = AstalWp.get_default()!;
	const audio = wireplumber.get_audio();

	const sinks = createBinding(audio, 'speakers').as(v =>
		v
			// Filter out devices I don't care about. Ideally there would be a
			// better way to handle this instead of just hard-coding a list,
			// but I am lazy and wanted a clean menu.
			.filter(v => {
				switch (true) {
					case v.is_default as boolean:
						return true; // Always show the default device even if it may be filtered.
					case v.description.startsWith('USB Audio '):
						// I only care about the optical out USB Audio device.
						return v.description === 'USB Audio S/PDIF Output';
					case v.description.startsWith('HyperX QuadCast '):
						return false;
					case v.description.includes('NVidia '):
						// I don't use the HDMI port.
						return false;
					default:
						return true;
				}
			})
			.sort((a, b) => a.id - b.id),
	);

	const sources = createBinding(audio, 'microphones').as(v =>
		v
			// Filter out devices I don't care about. Ideally there would be a
			// better way to handle this instead of just hard-coding a list,
			// but I am lazy and wanted a clean menu.
			.filter(v => {
				switch (true) {
					case v.is_default as boolean:
						return true; // Always show the default device even if it may be filtered.
					case v.description.startsWith('USB Audio '):
						return false;
					default:
						return true;
				}
			})
			.sort((a, b) => a.id - b.id),
	);

	const { defaultSpeaker: sink, defaultMicrophone: source } = wireplumber;

	return (
		<menubutton cssClasses={['wireplumber']}>
			<image iconName={createBinding(sink, 'volumeIcon')} />

			<popover>
				<box cssClasses={['wireplumber', 'popover']} orientation={Gtk.Orientation.VERTICAL}>
					<box cssClasses={['wireplumber', 'volume']}>
						<image iconName={createBinding(sink, 'volumeIcon')} />
						<slider
							cssClasses={['volume-slider']}
							onValueChanged={({ value }) => (sink.volume = value)}
							value={createBinding(sink, 'volume')}
							widthRequest={200}
							hexpand
						/>
						<label label={createBinding(sink, 'volume').as(p => `${Math.floor(p * 100)}%`)} />
					</box>

					<Gtk.Separator visible />

					<box orientation={Gtk.Orientation.VERTICAL}>
						<For each={sinks}>
							{sink => (
								<button
									cssClasses={createBinding(sink, 'is_default').as(b => {
										const classes = ['wireplumber', 'device', 'sink'];
										if (b) {
											classes.push('active');
										}
										return classes;
									})}
									// TODO: figure out how switch sinks without executing a command.
									onClicked={async () =>
										await execAsync(['wpctl', 'set-default', sink.id.toString()])
									}
								>
									<box>
										<image iconName="audio-speakers-symbolic" />
										<label label={`${sink.id}. ${sink.description || sink.name}`} xalign={0} />
									</box>
								</button>
							)}
						</For>
					</box>

					<Gtk.Separator visible />

					<box cssClasses={['wireplumber', 'volume']}>
						<image iconName={createBinding(source, 'volumeIcon')} />
						<slider
							cssClasses={['volume-slider']}
							onValueChanged={({ value }) => (source.volume = value)}
							value={createBinding(source, 'volume')}
							widthRequest={200}
							hexpand
						/>
						<label label={createBinding(source, 'volume').as(p => `${Math.floor(p * 100)}%`)} />
					</box>

					<Gtk.Separator visible />

					<box orientation={Gtk.Orientation.VERTICAL}>
						<For each={sources}>
							{source => (
								<button
									cssClasses={createBinding(source, 'is_default').as(b => {
										const classes = ['wireplumber', 'device', 'source'];
										if (b) {
											classes.push('active');
										}
										return classes;
									})}
									// TODO: figure out how switch sources without executing a command.
									onClicked={async () =>
										await execAsync(['wpctl', 'set-default', source.id.toString()])
									}
								>
									<box>
										<image iconName="audio-input-microphone-high-symbolic" />
										<label
											label={`${source.id}. ${source.description || source.name}`}
											xalign={0}
										/>
									</box>
								</button>
							)}
						</For>
					</box>
				</box>
			</popover>
		</menubutton>
	);
}

interface ActionItemProps {
	name: string;
	text: string;
	iconName?: string;
	onActivate: () => Promise<void> | void;
}

function createActionItem({ name, text, iconName, onActivate }: ActionItemProps): [Gio.SimpleAction, Gio.MenuItem] {
	const action = new Gio.SimpleAction({
		enabled: true,
		name: name,
	});
	action.connect('activate', onActivate);

	const item = Gio.MenuItem.new(text, 'pm.' + name);
	if (iconName !== undefined) {
		// TODO: figure out if this even works.
		const icon = Gio.Icon.new_for_string(iconName);
		item.set_icon(icon);
	}

	return [action, item];
}

function Actions() {
	const actions = new Gio.SimpleActionGroup();
	const menuModel = new Gio.Menu();

	function addItem([action, item]: [Gio.SimpleAction, Gio.MenuItem]): void {
		actions.add_action(action);
		menuModel.append_item(item);
	}

	addItem(
		createActionItem({
			name: 'shutdown',
			text: 'Shutdown',
			iconName: 'system-shutdown-symbolic',
			onActivate: async () => {
				await execAsync(['systemctl', 'poweroff']);
			},
		}),
	);

	addItem(
		createActionItem({
			name: 'reboot',
			text: 'Reboot',
			iconName: 'system-reboot-symbolic',
			onActivate: async () => {
				await execAsync(['systemctl', 'reboot']);
			},
		}),
	);

	addItem(
		createActionItem({
			name: 'suspend',
			text: 'Suspend',
			iconName: 'weather-clear-night-symbolic',
			onActivate: async () => {
				await execAsync(['systemctl', 'suspend']);
			},
		}),
	);

	// TODO: what one of these logouts do we want to keep?
	// NOTE: it might be better to put these in a submenu.
	addItem(
		createActionItem({
			name: 'logout-session',
			text: 'Logout (Session)',
			iconName: 'system-log-out-symbolic',
			onActivate: async () => {
				const xdgSessionId = GLib.getenv('XDG_SESSION_ID') ?? undefined;
				if (xdgSessionId === undefined) {
					return;
				}

				await execAsync(['loginctl', 'terminate-session', xdgSessionId]);
			},
		}),
	);
	addItem(
		createActionItem({
			name: 'logout-user',
			text: 'Logout (User)',
			iconName: 'system-log-out-symbolic',
			onActivate: async () => {
				const user = GLib.getenv('USER') ?? undefined;
				if (user === undefined) {
					return;
				}

				await execAsync(['loginctl', 'terminate-user', user]);
			},
		}),
	);

	addItem(
		createActionItem({
			name: 'lock',
			text: 'Lock',
			iconName: 'system-lock-screen-symbolic',
			onActivate: async () => {
				await execAsync(['loginctl', 'lock-session']);
			},
		}),
	);

	return (
		<menubutton>
			<image iconName="system-shutdown-symbolic" />
			<Gtk.PopoverMenu $={self => self.insert_action_group('pm', actions)} menuModel={menuModel} />
		</menubutton>
	);
}

function Bar(monitor: Gdk.Monitor) {
	return (
		<window
			visible
			name="bar"
			cssClasses={['bar']}
			gdkmonitor={monitor}
			exclusivity={Astal.Exclusivity.EXCLUSIVE}
			anchor={Astal.WindowAnchor.TOP | Astal.WindowAnchor.LEFT | Astal.WindowAnchor.RIGHT}
			application={app}
		>
			<centerbox>
				<box $type="start">
					<Media />
					<Workspaces monitor={monitor.get_connector() ?? ''} />
				</box>

				<box $type="center">
					<Clock />
				</box>

				<box $type="end">
					<SysTray />
					<BluetoothIndicator />
					<VolumeIndicator />
					<BatteryLevel />
					<NotificationsIndicator />
					<Actions />
				</box>
			</centerbox>
		</window>
	);
}

export { Bar };
