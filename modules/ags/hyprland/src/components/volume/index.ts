import Widget from 'resource:///com/github/Aylur/ags/widget.js';

import Audio from 'resource:///com/github/Aylur/ags/service/audio.js';

import Gtk from 'gi://Gtk?version=3.0';

// TODO: enum?
type VolumeIconValue = 101 | 67 | 34 | 1 | 0;

type VolumeChildren = {
	[name in VolumeIconValue]: Gtk.Widget;
};

/**
 * ?
 */
function Volume() {
	return Widget.Box({
		className: 'volume',
		css: 'min-width: 180px',
		children: [
			Widget.Stack<VolumeChildren, unknown>({
				className: 'volume-icon',
				children: {
					101: Widget.Icon('audio-volume-overamplified-symbolic'),
					67: Widget.Icon('audio-volume-high-symbolic'),
					34: Widget.Icon('audio-volume-medium-symbolic'),
					1: Widget.Icon('audio-volume-low-symbolic'),
					0: Widget.Icon('audio-volume-muted-symbolic'),
				},
				setup: self => {
					self.hook(
						Audio,
						() => {
							const speaker = Audio.speaker;
							if (speaker === undefined) {
								return;
							}

							// `speaker.is_muted` is only true when the volume is set to 0,
							// while `speaker.stream.is_muted` handles the audio output being
							// muted separately of volume control.
							if (speaker.is_muted || (speaker.stream?.is_muted ?? false)) {
								self.shown = 0;
								return;
							}

							// Find the icon to show for the current volume.
							const show = ([101, 67, 34, 1, 0] as VolumeIconValue[]).find(
								threshold => threshold <= speaker.volume * 100,
							);

							// Show the correct icon, defaulting to audio muted if a matching icon
							// couldn't be found.
							self.shown = show ?? 0;
						},
						'speaker-changed',
					);
				},
			}),
			Widget.Slider({
				className: 'volume-slider',
				hexpand: true,
				drawValue: false,
				setup: self => {
					self.hook(
						Audio,
						self => {
							const speaker = Audio.speaker;
							if (speaker === undefined) {
								self.value = 0;
								return;
							}

							self.value = speaker.volume;
						},
						'speaker-changed',
					);

					self.on_change = self => {
						const speaker = Audio.speaker;
						if (speaker === undefined) {
							return;
						}

						speaker.volume = self.value;
					};
				},
			}),
		],
	});
}

export { Volume };
