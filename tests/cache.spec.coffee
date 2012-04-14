Cache = require('../cache').Cache

describe 'Cache', ->
  cache = new Cache()
  obj = { name: 'test' }

  it 'can store an object', ->
    cache.set 'test', 'test', obj
    expect(cache.values['test']['test']).toMatch obj

  it 'can tell if it is currently storing an object', ->
    expect(cache.contains 'test', 'test').toBe true
    expect(cache.contains 'test', 'foo').toBe false
    expect(cache.contains 'foo', 'test').toBe false

  it 'can return a stored object', ->
    expect(cache.get 'test', 'test').toMatch obj
    expect(cache.get 'test', 'foo').toBeUndefined()
    expect(cache.get 'foo', 'test').toBeUndefined()
