import store from '../store';
import { increment, decrement } from '../features/counter/counterSlice';

describe('Redux Store', () => {
  it('should have initial state', () => {
    const state = store.getState();
    expect(state.counter.value).toBe(0);
  });

  it('should increment the counter value', () => {
    store.dispatch(increment());
    const state = store.getState();
    expect(state.counter.value).toBe(1);
  });

  it('should decrement the counter value', () => {
    store.dispatch(increment());
    store.dispatch(decrement());
    const state = store.getState();
    expect(state.counter.value).toBe(0);
  });
});

