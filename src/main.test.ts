import { sayHello } from './main';

describe('sayHello', () => {
  it('check correct return value', () => {
    expect(sayHello()).toBe('hello world');
  });
});
