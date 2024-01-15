import Widget from 'resource:///com/github/Aylur/ags/widget.js';
// import { Variable } from 'resource:///com/github/Aylur/ags/variable.js';

/**
 * ?
 */
function Clock() {
	return Widget.Button({
		className: 'clock',
		child: Widget.Box({
			className: 'clock-box',
			children: [TimeWithZone(), TimeWithZone('Etc/UTC')],
		}),
	});
}

/**
 * ?
 */
function TimeWithZone(timeZone?: string) {
	return Widget.Box({
		className: 'clock-display',

		setup: self => {
			self.poll(1000, () => {
				const date = new Date();

				self.children = [
					Widget.Label({
						label: date.toLocaleTimeString('en-CA', {
							hour12: false,
							hour: '2-digit',
							minute: '2-digit',
							second: '2-digit',
							timeZone,
						}),
					}),
					Widget.Label({
						className: 'timezone',
						label: date
							.toLocaleDateString('en-CA', {
								day: '2-digit',
								timeZone,
								timeZoneName: 'short',
							})
							.slice(3), // 3 = ` ${timeZone}`, 4 = timeZone
					}),
				];
			});
		},
	});
}

// function TimeVariable(timeZone?: string) {
// 	return new Variable('', {
// 		poll: [
// 			1000,
// 			() => {
// 				const date = new Date();
//
// 				return date.toLocaleTimeString('en-CA', {
// 					hour12: false,
// 					hour: '2-digit',
// 					minute: '2-digit',
// 					second: '2-digit',
// 					timeZone,
// 				});
// 			},
// 		],
// 	});
// }

export { Clock };
