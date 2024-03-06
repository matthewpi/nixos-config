import Widget from 'resource:///com/github/Aylur/ags/widget.js';

import Mpris from 'resource:///com/github/Aylur/ags/service/mpris.js';

import Gtk from 'gi://Gtk?version=3.0';

function Media() {
	return Widget.Button({
		className: 'media',
		onPrimaryClick: () => Mpris.getPlayer('')?.playPause(),
		onScrollUp: () => Mpris.getPlayer('')?.next(),
		onScrollDown: () => Mpris.getPlayer('')?.previous(),
		child: Widget.Box({
			valign: Gtk.Align.CENTER,
			vexpand: true,

			setup: self => {
				self.hook(Mpris, () => {
					const mpris = Mpris.getPlayer('');

					const children = [];
					switch (mpris?.play_back_status ?? '') {
						case 'Paused':
							children.push(
								Widget.Box({
									className: 'media-icon',
									child: Widget.Icon({ icon: 'media-playback-pause', size: 20 }),
								}),
							);
							break;
						case 'Playing':
							children.push(
								Widget.Box({
									className: 'media-icon',
									child: Widget.Icon({ icon: 'media-playback-start', size: 20 }),
								}),
							);
							break;
					}

					const boxChildren = [];
					if (mpris === null) {
						boxChildren.push(
							Widget.Label({
								className: 'media-label nothing',
								label: 'Nothing is playing',
							}),
						);
					} else {
						boxChildren.push(
							Widget.Label({
								className: 'media-title',
								label: mpris.track_title,
							}),
						);

						if (mpris.track_artists.length > 0) {
							boxChildren.push(
								Widget.Label({
									className: 'media-artists',
									label: `By ${mpris.track_artists.join(', ')}`.trim(),
								}),
							);
						}
					}

					children.push(
						Widget.Box({
							className: 'media-label',
							vertical: true,
							homogeneous: false,
							valign: Gtk.Align.CENTER,
							vexpand: true,
							children: boxChildren,
						}),
					);

					self.children = children;
				});
			},
		}),
	});
}

export { Media };
