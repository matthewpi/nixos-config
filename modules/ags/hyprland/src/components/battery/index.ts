import Widget from 'resource:///com/github/Aylur/ags/widget.js';

const battery = await Service.import('battery');

function BatteryIcon() {
	return Widget.Box({
		visible: battery.bind('available'),
		child: Widget.Icon({ icon: battery.bind('icon_name'), size: 24 }),
		class_name: battery.bind('charging').as(ch => (ch ? 'battery charging' : 'battery')),
		tooltipText: battery.bind('percent').as(p => `${p}%`),
	});
}

export { BatteryIcon };
