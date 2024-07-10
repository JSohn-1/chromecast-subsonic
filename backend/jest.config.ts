import type {Config} from '@jest/types';

const config: Config.InitialOptions = {
	verbose: true,
	transformIgnorePatterns: [
		'<rootDir>/node_modules/(?!(@mapbox/mapbox-gl-draw' +
		'|some-custom-package' +
		')/)',
	],
	preset: 'ts-jest',
};

export default config;

