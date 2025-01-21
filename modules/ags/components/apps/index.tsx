import { Variable } from 'astal';
import { App, Astal, Gdk, Gtk } from 'astal/gtk4';
import { execAsync } from 'astal/process';
import Apps from 'gi://AstalApps';
import Pango from 'gi://Pango';

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

interface AppButtonProps {
	app: Apps.Application;
}

function AppButton({ app }: AppButtonProps) {
	return (
		<button
			cssClasses={['app']}
			onClicked={() => {
				hide();
				launch(app);
			}}
		>
			<box>
				<image iconName={app.iconName} iconSize={Gtk.IconSize.LARGE} />
				<box valign={Gtk.Align.CENTER} vertical>
					<label cssClasses={['name']} xalign={0} label={app.name} ellipsize={Pango.EllipsizeMode.END} />
					{app.description && <label cssClasses={['description']} wrap xalign={0} label={app.description} />}
				</box>
			</box>
		</button>
	);
}

function Launcher() {
	const apps = new Apps.Apps();

	// Since we updated to Gtk4, we need to use a EntryBuffer to control the
	// content of the entry widget. If we just use `onNotifyText`, we can get
	// the content as it changes, but we cannot change the content ourselves, like
	// to clear the entry whenever the window is closed for example.
	//
	// So instead we use an EntryBuffer and "watch" it's text property, updating
	// the `text` variable so we can live filter applications.
	const text = Variable('');
	const buffer = new Gtk.EntryBuffer();
	buffer.connect('inserted-text', self => text.set(self.text));
	buffer.connect('deleted-text', (self, position) => text.set(self.text.substring(0, position)));

	const list = text(text => searchApps(text).slice(0, MAX_ITEMS));

	function searchApps(query: string) {
		return (
			apps
				// Filter apps using the search query.
				.fuzzy_query(query)
				// Filter out terminal applications.
				.filter(app => app.get_key('Terminal') !== 'true')
		);
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
			anchor={Astal.WindowAnchor.TOP | Astal.WindowAnchor.BOTTOM}
			exclusivity={Astal.Exclusivity.IGNORE}
			onShow={() => (buffer.text = '')}
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
						<entry buffer={buffer} placeholderText="Search applications..." onActivate={onEnter} />
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
