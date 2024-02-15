import Widget from 'resource:///com/github/Aylur/ags/widget.js';

import Mpris from 'resource:///com/github/Aylur/ags/service/mpris.js';

function Media() {
	return Widget.Button({
		className: 'media',
		onPrimaryClick: () => Mpris.getPlayer('')?.playPause(),
		onScrollUp: () => Mpris.getPlayer('')?.next(),
		onScrollDown: () => Mpris.getPlayer('')?.previous(),
		child: Widget.Box({
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

					if (mpris === null) {
						children.push(
							Widget.Label({
								className: 'media-label',
								label: 'Nothing is playing',
							}),
						);
					} else {
						const boxChildren = [
							Widget.Label({
								className: 'media-title',
								label: mpris.track_title,
							}),
						];

						if (mpris.track_artists.length > 0) {
							boxChildren.push(
								Widget.Label({
									className: 'media-artists',
									label: `By ${mpris.track_artists.join(', ')}`.trim(),
								}),
							);
						}

						children.push(
							Widget.Box({
								className: 'media-label',
								vertical: true,
								homogeneous: false,
								children: boxChildren,
							}),
						);
					}

					self.children = children;
				});
			},
		}),
	});
}

export { Media };
