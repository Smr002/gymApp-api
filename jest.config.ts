import type { Config } from 'jest';
const config: Config = {
  preset: 'ts-jest',
  testEnvironment: 'node',
  roots: ['<rootDir>/tests'],
  moduleNameMapper: {
    '^@features/(.*)$': '<rootDir>/src/features/$1',
    '^@shared/(.*)$':   '<rootDir>/src/shared/$1',
    '^@infra/(.*)$':    '<rootDir>/src/infrastructure/$1',
    '^@config/(.*)$':   '<rootDir>/src/config/$1',
    '^@utils/(.*)$':    '<rootDir>/src/utils/$1',
  },
  collectCoverageFrom: ['src/**/*.ts'],
  coverageDirectory: 'coverage',
};
export default config;
