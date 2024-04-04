import App from 'resource:///com/github/Aylur/ags/app.js';
import Service from 'resource:///com/github/Aylur/ags/service.js';
import Widget from 'resource:///com/github/Aylur/ags/widget.js';

const greetd = await Service.import('greetd');

const name = Widget.Entry({
	placeholder_text: 'Username',
	on_accept: () => password.grab_focus(),
});

const password = Widget.Entry({
	placeholder_text: 'Password',
	visibility: false,
	on_accept: () => {
		greetd
			.login(name.text ?? '', password.text ?? '', 'Hyprland')
			.catch(err => (response.label = JSON.stringify(err)));
	},
});

const response = Widget.Label();

const window = Widget.Window({
	name: 'hello-world',
	css: 'background-color: transparent;',
	anchor: ['top', 'left', 'right', 'bottom'],
	child: Widget.Box({
		vertical: true,
		hpack: 'center',
		vpack: 'center',
		hexpand: true,
		vexpand: true,
		children: [name, password, response],
	}),
});

// exporting the config so ags can manage the windows
App.config({
	style: `${App.configDir}/style.css`,
	windows: [window],
});
