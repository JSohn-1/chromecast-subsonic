/** @type {import('ts-jest').JestConfigWithTsJest} **/
// eslint-disable-next-line no-undef
module.exports = {
	testEnvironment: 'node',
	transform: {
		'^.+.tsx?$': ['ts-jest',{}],
	},
	globals: {
		SUBSONIC_URL: 'http://localhost:4533'
	},
};
