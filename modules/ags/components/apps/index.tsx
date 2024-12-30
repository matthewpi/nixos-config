import { Variable } from 'astal';
import { App, Astal, Gdk, Gtk } from 'astal/gtk4';
import { execAsync } from 'astal/process';
import Apps from 'gi://AstalApps';

const MAX_ITEMS = 12;

function hide() {
	App.get_window('launcher')?.hide();
}

function getRandomNumber(max: number): number {
	return Math.floor(Math.random() * max);
}

async function launch(app: Apps.Application): Promise<void> {
	const cmd = [
		'systemd-run',
		'--user',
		'--collect',
		'--no-block',
		'--slice=app',
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
}

function AppButton({ app }: { app: Apps.Application }) {
	return (
		<button
			cssClasses={['app']}
			onClicked={() => {
				hide();
				launch(app);
			}}
		>
			<box>
				<image iconName={app.iconName} />
				<box valign={Gtk.Align.CENTER} vertical>
					{/* TODO: truncate? */}
					<label cssClasses={['name']} xalign={0} label={app.name} />
					{app.description && <label cssClasses={['description']} wrap xalign={0} label={app.description} />}
				</box>
			</box>
		</button>
	);
}

function Launcher() {
	const apps = new Apps.Apps();

	const text = Variable('');
	const list = text(text => searchApps(text).slice(0, MAX_ITEMS));

	function searchApps(query: string) {
		// Filter out terminal applications.
		return apps.fuzzy_query(query).filter(app => app.get_key('Terminal') !== 'true');
	}

	function onEnter() {
		const results = searchApps(text.get());
		const result = results?.[0];
		if (result === undefined) {
			return;
		}

		launch(result);
		hide();
	}

	return (
		<window
			// `name` must go before `application`.
			name="launcher"
			application={App}
			cssClasses={['launcher']}
			anchor={Astal.WindowAnchor.TOP}
			exclusivity={Astal.Exclusivity.IGNORE}
			// onShow={() => text.set('')}
			keymode={Astal.Keymode.ON_DEMAND}
			onKeyPressed={(self, keyval) => {
				if (keyval === Gdk.KEY_Escape) {
					self.hide();
				}
			}}
		>
			<box>
				{/* <eventbox widthRequest={4000} expand onClick={hide} /> */}
				<box hexpand={false} vertical>
					{/* <eventbox heightRequest={100} onClick={hide} /> */}
					<box widthRequest={500} cssClasses={['launcher']} vertical>
						<entry
							placeholderText="Search applications..."
							text={text()}
							onChanged={self => text.set(self.text)}
							onActivate={onEnter}
						/>
						<box spacing={6} vertical>
							{list.as(list => list.map(app => <AppButton app={app} />))}
						</box>
						<box
							halign={Gtk.Align.CENTER}
							cssClasses={['not-found']}
							vertical
							visible={list.as(l => l.length === 0)}
						>
							<image iconName="system-search-symbolic" />
							<label label="No match found" />
						</box>
					</box>
					{/* <eventbox expand onClick={hide} /> */}
				</box>
				{/* <eventbox widthRequest={4000} expand onClick={hide} /> */}
			</box>
		</window>
	);
}

export { Launcher };
