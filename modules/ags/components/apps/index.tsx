import { createState, For } from 'ags';
import { execAsync } from 'ags/process';
import Adw from 'gi://Adw';
import Astal from 'gi://Astal?version=4.0';
import AstalApps from 'gi://AstalApps?version=0.1';
import Gdk from 'gi://Gdk?version=4.0';
import Graphene from 'gi://Graphene?version=1.0';
import Gtk from 'gi://Gtk?version=4.0';
import Pango from 'gi://Pango?version=1.0';

function getRandomNumber(max: number): number {
	return Math.floor(Math.random() * max);
}

function AppLauncher() {
	let launcherWindow: Astal.Window;
	let contentBox: Gtk.Box;
	let searchEntry: Gtk.Entry;

	const apps = new AstalApps.Apps();
	const [list, setList] = createState(getApps(''));

	function getApps(query: string): AstalApps.Application[] {
		return (
			apps
				// Filter apps using the search query.
				.fuzzy_query(query)
				// Filter out terminal applications.
				.filter(app => app.get_key('Terminal') !== 'true')
		);
	}

	function searchApps(query: string): void {
		setList(getApps(query));
	}

	function onKey(_event: Gtk.EventControllerKey, keyval: number, _: number, _mod: number) {
		if (keyval === Gdk.KEY_Escape) {
			launcherWindow.visible = false;
			return;
		}
	}

	function onClick(_e: Gtk.GestureClick, _: number, x: number, y: number) {
		const [, rect] = contentBox.compute_bounds(launcherWindow);
		const position = new Graphene.Point({ x, y });
		if (!rect.contains_point(position)) {
			launcherWindow.visible = false;
			return true;
		}

		return;
	}

	// If enter is pressed from within the search entry, launch the first
	// application in the list.
	function onEnter() {
		const result = list.get()[0];
		if (result === undefined) {
			return;
		}

		launch(result);
	}

	/**
	 * https://systemd.io/DESKTOP_ENVIRONMENTS/#xdg-standardization-for-applications
	 */
	async function launch(app: AstalApps.Application): Promise<void> {
		const cmd = [
			'systemd-run',
			'--user',
			'--collect',
			'--no-block',
			'--slice=app-graphical',
			`--unit=app-${app.name}@${getRandomNumber(32767)}`,
		];

		// If the application is VSCodium or Zed, set `Type=forking`.
		//
		// Both these editors fork themselves so they can provide multiple windows
		// and manage their child processes.
		switch (app.name) {
			case 'VSCodium':
			case 'Zed':
				cmd.push('--property=Type=forking');
				break;
		}

		// Add the app's executable and flags to the command.
		cmd.push(...app.executable.split(/\s+/).filter(str => !str.startsWith('%') && !str.startsWith('@')));

		await execAsync(cmd).catch(err => {
			print(err);
		});

		// Increase the app's "frequency" so common apps get preferred over non-common
		// ones when using `fuzzy_query`.
		app.frequency++;

		// Hide the window once we launch an application.
		launcherWindow.hide();
	}

	return (
		<window
			$={ref => (launcherWindow = ref)}
			name="launcher"
			cssClasses={['launcher']}
			exclusivity={Astal.Exclusivity.IGNORE}
			keymode={Astal.Keymode.EXCLUSIVE}
			anchor={
				Astal.WindowAnchor.TOP | Astal.WindowAnchor.BOTTOM | Astal.WindowAnchor.LEFT | Astal.WindowAnchor.RIGHT
			}
			onNotifyVisible={({ visible }) => {
				if (visible) {
					// Focus the entry whenever the app launcher is focused.
					searchEntry.grab_focus();
					return;
				}

				// Clear the entry's text.
				searchEntry.set_text('');
			}}
		>
			<Gtk.EventControllerKey onKeyPressed={onKey} />
			<Gtk.GestureClick onPressed={onClick} />

			<Adw.Clamp maximumSize={700}>
				<box
					$={ref => (contentBox = ref)}
					cssClasses={['launcher']}
					orientation={Gtk.Orientation.VERTICAL}
					valign={Gtk.Align.CENTER}
					halign={Gtk.Align.CENTER}
					widthRequest={700}
				>
					<entry
						$={ref => (searchEntry = ref)}
						onNotifyText={({ text }) => searchApps(text)}
						placeholderText="Search applications..."
						onActivate={onEnter}
					/>

					<scrolledwindow
						propagateNaturalHeight
						propagateNaturalWidth
						maxContentHeight={500}
						minContentHeight={500}
					>
						<box spacing={6} orientation={Gtk.Orientation.VERTICAL}>
							<For each={list}>
								{app => (
									<button cssClasses={['app']} onClicked={() => launch(app)}>
										<box>
											<image iconName={app.iconName} iconSize={Gtk.IconSize.LARGE} />
											<box valign={Gtk.Align.CENTER} orientation={Gtk.Orientation.VERTICAL}>
												<label
													cssClasses={['name']}
													xalign={0}
													label={app.name}
													ellipsize={Pango.EllipsizeMode.END}
												/>
												{app.description && (
													<label
														cssClasses={['description']}
														wrap
														xalign={0}
														label={app.description}
													/>
												)}
											</box>
										</box>
									</button>
								)}
							</For>
						</box>
					</scrolledwindow>

					<box
						visible={list.as(l => l.length === 0)}
						halign={Gtk.Align.CENTER}
						cssClasses={['not-found']}
						orientation={Gtk.Orientation.VERTICAL}
					>
						<image iconName="system-search-symbolic" />
						<label label="No match found" />
					</box>
				</box>
			</Adw.Clamp>
		</window>
	);
}

export { AppLauncher };
