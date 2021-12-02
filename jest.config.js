module.exports = {
  globals: {
    'ts-jest': {
      tsconfig: 'tsconfig.json',
    },
  },
  preset: 'ts-jest',
  moduleFileExtensions: ["js", "ts", "json", "node"],
  testEnvironment: 'node',
};